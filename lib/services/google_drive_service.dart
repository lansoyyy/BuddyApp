import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:native_exif/native_exif.dart';
import 'package:image/image.dart' as img;
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart' as geocoding;
import 'package:intl/intl.dart';
import 'package:buddyapp/utils/watermark_position.dart';

class GoogleDriveService {
  GoogleDriveService({required this.accessToken});

  final String accessToken;

  static const String _baseUrl = 'www.googleapis.com';

  Map<String, String> _jsonHeaders() {
    return {
      'Authorization': 'Bearer $accessToken',
      'Content-Type': 'application/json; charset=utf-8',
    };
  }

  Future<String> _getOrCreateFolder(String name, {String? parentId}) async {
    final existing = await _findFolder(name, parentId: parentId);
    if (existing.isNotEmpty) {
      final file = existing.first as Map<String, dynamic>;
      final id = file['id'] as String?;
      if (id != null && id.isNotEmpty) {
        return id;
      }
    }

    final body = <String, dynamic>{
      'name': name,
      'mimeType': 'application/vnd.google-apps.folder',
    };
    if (parentId != null && parentId.isNotEmpty) {
      body['parents'] = [parentId];
    }

    final uri = Uri.https(_baseUrl, '/drive/v3/files');
    final response = await http.post(
      uri,
      headers: _jsonHeaders(),
      body: jsonEncode(body),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(
          'Failed to create folder: ${response.statusCode} ${response.body}');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final id = data['id'] as String?;
    if (id == null || id.isEmpty) {
      throw Exception('Folder id missing in Google Drive response');
    }
    return id;
  }

  Future<List<dynamic>> _findFolder(String name, {String? parentId}) async {
    final parent = parentId ?? 'root';
    final escapedName = name.replaceAll("'", "\\'");
    final q =
        "name = '$escapedName' and mimeType = 'application/vnd.google-apps.folder' and '$parent' in parents and trashed = false";

    final uri = Uri.https(
      _baseUrl,
      '/drive/v3/files',
      <String, String>{
        'q': q,
        'spaces': 'drive',
        'fields': 'files(id,name)',
        'pageSize': '1',
      },
    );

    final response = await http.get(
      uri,
      headers: {'Authorization': 'Bearer $accessToken'},
    );

    if (response.statusCode != 200) {
      throw Exception(
          'Failed to query folders: ${response.statusCode} ${response.body}');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final files = data['files'] as List<dynamic>?;
    return files ?? <dynamic>[];
  }

  Future<void> uploadPhoto({
    required String localPath,
    required String fileName,
    required String workorderNumber,
    required String component,
    required String processStage,
    required String project,
    required String componentPart,
    required String componentStamp,
    required String description,
    required String inspectionStatus,
    required String urgencyLevel,
    required WatermarkPosition watermarkPosition,
  }) async {
    final jobsFolderId = await _getOrCreateFolder('Jobs');
    final workorderFolderId =
        await _getOrCreateFolder(workorderNumber, parentId: jobsFolderId);
    final photosFolderId =
        await _getOrCreateFolder('Photos', parentId: workorderFolderId);
    final stageFolderId =
        await _getOrCreateFolder(processStage, parentId: photosFolderId);

    final metadata = <String, dynamic>{
      'name': fileName,
      'mimeType': 'image/jpeg',
      'parents': [stageFolderId],
      'appProperties': <String, String>{
        'workorderNumber': workorderNumber,
        'component': component,
        'processStage': processStage,
        'project': project,
        'componentPart': componentPart,
        'componentStamp': componentStamp,
        'description': description,
        'inspectionStatus': inspectionStatus,
        'urgencyLevel': urgencyLevel,
      },
    };

    final createUri = Uri.https(_baseUrl, '/drive/v3/files');
    final createResponse = await http.post(
      createUri,
      headers: _jsonHeaders(),
      body: jsonEncode(metadata),
    );

    if (createResponse.statusCode < 200 || createResponse.statusCode >= 300) {
      throw Exception(
          'Failed to create file metadata: ${createResponse.statusCode} ${createResponse.body}');
    }

    final created = jsonDecode(createResponse.body) as Map<String, dynamic>;
    final fileId = created['id'] as String?;
    if (fileId == null || fileId.isEmpty) {
      throw Exception('File id missing after metadata creation');
    }

    await _applyWatermark(
      localPath: localPath,
      fileName: fileName,
      workorderNumber: workorderNumber,
      component: component,
      processStage: processStage,
      project: project,
      componentPart: componentPart,
      componentStamp: componentStamp,
      inspectionStatus: inspectionStatus,
      urgencyLevel: urgencyLevel,
      description: description,
      watermarkPosition: watermarkPosition,
    );

    try {
      final exif = await Exif.fromPath(localPath);
      final exifDescription =
          'Workorder: $workorderNumber; Component: $component; Stamp: $componentStamp; '
          'Stage: $processStage; Project: $project; Part: $componentPart; '
          'Status: $inspectionStatus; Urgency: $urgencyLevel; Desc: $description';

      await exif.writeAttributes(<String, String>{
        'ImageDescription': exifDescription,
        'UserComment': exifDescription,
      });

      await exif.close();
    } catch (_) {}

    final file = File(localPath);
    final bytes = await file.readAsBytes();

    final uploadUri = Uri.https(
      _baseUrl,
      '/upload/drive/v3/files/$fileId',
      <String, String>{'uploadType': 'media'},
    );

    final uploadResponse = await http.patch(
      uploadUri,
      headers: <String, String>{
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'image/jpeg',
      },
      body: bytes,
    );

    if (uploadResponse.statusCode < 200 || uploadResponse.statusCode >= 300) {
      throw Exception(
          'Failed to upload file content: ${uploadResponse.statusCode} ${uploadResponse.body}');
    }
  }

  Future<void> _applyWatermark({
    required String localPath,
    required String fileName,
    required String workorderNumber,
    required String component,
    required String processStage,
    required String project,
    required String componentPart,
    required String componentStamp,
    required String inspectionStatus,
    required String urgencyLevel,
    required String description,
    required WatermarkPosition watermarkPosition,
  }) async {
    try {
      final file = File(localPath);
      final bytes = await file.readAsBytes();
      final image = img.decodeImage(bytes);
      if (image == null) {
        return;
      }

      final now = DateTime.now();
      final dateStr = DateFormat('yyyy-MM-dd HH:mm:ss').format(now);
      final locationStr = await _getLocationString();

      final lines = <String>[
        fileName,
        dateStr,
      ];

      if (locationStr != null) {
        lines.add('Location:');
        for (final part in locationStr.split(', ')) {
          final trimmed = part.trim();
          if (trimmed.isNotEmpty) {
            lines.add(trimmed);
          }
        }
      }

      lines.add('WO: $workorderNumber  |  $component  |  $processStage');

      final font = img.arial24;
      const margin = 20;
      final lineHeight =
          24.0; // Using fixed height since font.height is not available

      int startY;
      switch (watermarkPosition) {
        case WatermarkPosition.topLeft:
        case WatermarkPosition.topRight:
          startY = margin;
          break;
        case WatermarkPosition.bottomLeft:
        case WatermarkPosition.bottomRight:
          final textBlockHeight = lineHeight * lines.length;
          final clampedHeight =
              textBlockHeight > image.height ? image.height : textBlockHeight;
          startY = (image.height - margin - clampedHeight).toInt();
          break;
      }

      for (int i = 0; i < lines.length; i++) {
        final y = (startY + i * lineHeight).toInt();
        switch (watermarkPosition) {
          case WatermarkPosition.topLeft:
          case WatermarkPosition.bottomLeft:
            img.drawString(
              image,
              lines[i],
              font: font,
              x: margin,
              y: y,
              color: img.ColorRgb8(255, 255, 255),
            );
            break;
          case WatermarkPosition.topRight:
          case WatermarkPosition.bottomRight:
            img.drawString(
              image,
              lines[i],
              font: font,
              x: image.width - margin,
              y: y,
              color: img.ColorRgb8(255, 255, 255),
              rightJustify: true,
            );
            break;
        }
      }

      final encoded = img.encodeJpg(image, quality: 95);
      await file.writeAsBytes(encoded, flush: true);
    } catch (_) {}
  }

  Future<String?> _getLocationString() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return null;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return null;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      String? address;
      try {
        final placemarks = await geocoding.placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        );

        if (placemarks.isNotEmpty) {
          final place = placemarks.first;
          final parts = <String>[];

          void addPart(String? part) {
            if (part != null && part.trim().isNotEmpty) {
              parts.add(part.trim());
            }
          }

          addPart(place.street);
          addPart(place.subLocality);
          addPart(place.locality);
          addPart(place.subAdministrativeArea);
          addPart(place.administrativeArea);
          addPart(place.country);

          if (parts.isNotEmpty) {
            address = parts.join(', ');
          }
        }
      } catch (_) {
        address = null;
      }

      if (address != null && address!.isNotEmpty) {
        return address;
      }

      return '${position.latitude.toStringAsFixed(5)}, '
          '${position.longitude.toStringAsFixed(5)}';
    } catch (_) {
      return null;
    }
  }
}
