import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:native_exif/native_exif.dart';
import 'package:image/image.dart' as img;
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart' as geocoding;
import 'package:intl/intl.dart';
import 'package:buddyapp/utils/watermark_position.dart';
import 'package:buddyapp/services/storage_service.dart';

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

  Future<List<Map<String, String>>> listWorkorderFolders() async {
    final storage = await StorageService.getInstance();
    final workorderRootPath = storage.getSetting<String>(
          'driveWorkorderRootPath',
          defaultValue: 'Jobs',
        ) ??
        'Jobs';

    String? parentId;
    final segments = workorderRootPath
        .split('/')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    for (final segment in segments) {
      parentId = await _getOrCreateFolder(segment, parentId: parentId);
    }

    final jobsFolderId = parentId ?? await _getOrCreateFolder('Jobs');

    final uri = Uri.https(
      _baseUrl,
      '/drive/v3/files',
      <String, String>{
        'q':
            "'$jobsFolderId' in parents and mimeType = 'application/vnd.google-apps.folder' and trashed = false",
        'spaces': 'drive',
        'fields': 'files(id,name)',
        'pageSize': '1000',
      },
    );

    final response = await http.get(
      uri,
      headers: {'Authorization': 'Bearer $accessToken'},
    );

    if (response.statusCode != 200) {
      throw Exception(
          'Failed to list workorder folders: ${response.statusCode} ${response.body}');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final files = data['files'] as List<dynamic>? ?? <dynamic>[];

    final result = <Map<String, String>>[];
    for (final item in files) {
      if (item is Map<String, dynamic>) {
        final id = item['id'] as String?;
        final name = item['name'] as String?;
        if (id != null && name != null) {
          result.add(<String, String>{'id': id, 'name': name});
        }
      }
    }

    return result;
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
    final storage = await StorageService.getInstance();
    final folderTemplate = storage.getSetting<String>(
          'driveFolderTemplate',
          defaultValue: 'Jobs/{workorderNumber}/Photos/{processStage}',
        ) ??
        'Jobs/{workorderNumber}/Photos/{processStage}';

    final templateVars = <String, String>{
      'workorderNumber': workorderNumber,
      'component': component,
      'processStage': processStage,
      'project': project,
      'componentPart': componentPart,
      'componentStamp': componentStamp,
      'inspectionStatus': inspectionStatus,
      'urgencyLevel': urgencyLevel,
    };

    String resolveSegment(String segment) {
      var resolved = segment;
      templateVars.forEach((key, value) {
        resolved = resolved.replaceAll('{$key}', value);
      });
      resolved = resolved.replaceAll('/', '-').trim();
      return resolved;
    }

    String? parentId;
    final segments = folderTemplate
        .split('/')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    for (final segment in segments) {
      final name = resolveSegment(segment);
      if (name.isEmpty) {
        continue;
      }
      parentId = await _getOrCreateFolder(name, parentId: parentId);
    }

    final stageFolderId = parentId ?? await _getOrCreateFolder('Jobs');

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

  /// Counts existing photos for a given workorder and component to avoid duplicate naming
  Future<int> countExistingPhotos({
    required String workorderNumber,
    required String component,
  }) async {
    final escapedWorkorder = workorderNumber.replaceAll("'", "\\'");
    final escapedComponent = component.replaceAll("'", "\\'");
    final q =
        "mimeType contains 'image/' and appProperties has { key='workorderNumber' and value='$escapedWorkorder' } and appProperties has { key='component' and value='$escapedComponent' } and trashed = false";

    final uri = Uri.https(
      _baseUrl,
      '/drive/v3/files',
      <String, String>{
        'q': q,
        'spaces': 'drive',
        'fields': 'files(id)',
        'pageSize': '1000',
      },
    );

    final response = await http.get(
      uri,
      headers: {'Authorization': 'Bearer $accessToken'},
    );

    if (response.statusCode != 200) {
      return 0; // On error, return 0 to start from Photo1
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final files = data['files'] as List<dynamic>? ?? <dynamic>[];
    return files.length;
  }

  Future<List<Map<String, dynamic>>> listPhotosByWorkorderNumber(
      String workorderNumber) async {
    final escapedWorkorder = workorderNumber.replaceAll("'", "\\'");
    final q =
        "mimeType contains 'image/' and appProperties has { key='workorderNumber' and value='$escapedWorkorder' } and trashed = false";

    final uri = Uri.https(
      _baseUrl,
      '/drive/v3/files',
      <String, String>{
        'q': q,
        'spaces': 'drive',
        'fields': 'files(id,name,thumbnailLink,appProperties)',
        'pageSize': '1000',
      },
    );

    final response = await http.get(
      uri,
      headers: {'Authorization': 'Bearer $accessToken'},
    );

    if (response.statusCode != 200) {
      throw Exception(
          'Failed to list photos: ${response.statusCode} ${response.body}');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final files = data['files'] as List<dynamic>? ?? <dynamic>[];

    final result = <Map<String, dynamic>>[];
    for (final item in files) {
      if (item is Map<String, dynamic>) {
        result.add(item);
      }
    }

    return result;
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
      final storage = await StorageService.getInstance();
      final showStatus =
          storage.getSetting<bool>('watermarkShowStatus', defaultValue: true) ??
              true;
      final showTitle =
          storage.getSetting<bool>('watermarkShowTitle', defaultValue: true) ??
              true;
      final showDateTime = storage.getSetting<bool>('watermarkShowDateTime',
              defaultValue: true) ??
          true;
      final showLocation = storage.getSetting<bool>('watermarkShowLocation',
              defaultValue: true) ??
          true;
      final showWorkorder = storage.getSetting<bool>('watermarkShowWorkorder',
              defaultValue: true) ??
          true;

      final fontSize =
          storage.getSetting<int>('watermarkFontSize', defaultValue: 24) ?? 24;
      final textColorValue = storage.getSetting<int>(
            'watermarkTextColor',
            defaultValue: 0xFFFFFFFF,
          ) ??
          0xFFFFFFFF;
      final backgroundOpacity = storage.getSetting<double>(
            'watermarkBackgroundOpacity',
            defaultValue: 1.0,
          ) ??
          1.0;
      final showLogo =
          storage.getSetting<bool>('watermarkShowLogo', defaultValue: false) ??
              false;
      final logoPath = storage.getSetting<String>('watermarkLogoPath');
      final logoScale = storage.getSetting<double>(
            'watermarkLogoScale',
            defaultValue: 0.25,
          ) ??
          0.25;

      final ta = (textColorValue >> 24) & 0xFF;
      final tr = (textColorValue >> 16) & 0xFF;
      final tg = (textColorValue >> 8) & 0xFF;
      final tb = (textColorValue) & 0xFF;
      final textColor = img.ColorRgba8(tr, tg, tb, ta);

      final font = fontSize <= 14
          ? img.arial14
          : fontSize <= 24
              ? img.arial24
              : fontSize <= 36
                  ? img.arial48
                  : img.arial48;

      final charWidth = (fontSize * 0.55).round().clamp(6, 32);
      final maxChars = ((image.width / 2) - 40) ~/ charWidth;
      final lineHeight = (fontSize * 1.3).ceil().toDouble();

      String truncate(String text) {
        if (text.length <= maxChars) return text;
        return '${text.substring(0, maxChars - 3)}...';
      }

      final lines = <String>[];

      if (showStatus) {
        lines.add(
            truncate('Status: $inspectionStatus  |  Urgency: $urgencyLevel'));
      }

      if (showTitle) {
        final titleTemplate = storage.getSetting<String>(
              'watermarkTitleTemplate',
              defaultValue: '{fileName}',
            ) ??
            '{fileName}';

        final titleVars = <String, String>{
          'fileName': fileName,
          'workorderNumber': workorderNumber,
          'component': component,
          'processStage': processStage,
          'project': project,
          'componentPart': componentPart,
          'componentStamp': componentStamp,
          'inspectionStatus': inspectionStatus,
          'urgencyLevel': urgencyLevel,
          'description': description,
        };

        var title = titleTemplate;
        titleVars.forEach((key, value) {
          title = title.replaceAll('{$key}', value);
        });
        title = title.trim();
        if (title.isEmpty) {
          title = fileName;
        }

        lines.add(truncate(title));
      }

      if (showDateTime) {
        lines.add(truncate(dateStr));
      }

      if (showLocation && locationStr != null) {
        lines.add('Location:');
        for (final part in locationStr.split(', ')) {
          final trimmed = part.trim();
          if (trimmed.isNotEmpty) {
            lines.add(truncate(trimmed));
          }
        }
      }

      if (showWorkorder) {
        lines.add(
            truncate('WO: $workorderNumber  |  $component  |  $processStage'));
      }

      if (lines.isEmpty) {
        return;
      }

      const margin = 20;

      img.Image? logoImage;
      if (showLogo && logoPath != null && logoPath.isNotEmpty) {
        try {
          final logoBytes = await File(logoPath).readAsBytes();
          final decodedLogo = img.decodeImage(logoBytes);
          if (decodedLogo != null) {
            final maxLogoWidth = ((image.width / 2) - (margin * 2)).toInt();
            final targetWidth =
                (maxLogoWidth * logoScale).toInt().clamp(24, maxLogoWidth);
            logoImage = img.copyResize(decodedLogo, width: targetWidth);
          }
        } catch (_) {}
      }

      final logoBlockHeight =
          logoImage != null ? (logoImage.height + 8).toDouble() : 0.0;

      int startY;
      switch (watermarkPosition) {
        case WatermarkPosition.topLeft:
        case WatermarkPosition.topRight:
          startY = margin;
          break;
        case WatermarkPosition.bottomLeft:
        case WatermarkPosition.bottomRight:
          final textBlockHeight = (lineHeight * lines.length) + logoBlockHeight;
          final clampedHeight =
              textBlockHeight > image.height ? image.height : textBlockHeight;
          startY = (image.height - margin - clampedHeight).toInt();
          break;
      }

      final bgAlpha =
          (backgroundOpacity.clamp(0.0, 1.0) * 255).round().clamp(0, 255);

      int boxTop = startY - 4;
      if (boxTop < 0) {
        boxTop = 0;
      }
      final totalTextHeight = (lineHeight * lines.length) + logoBlockHeight;
      int boxBottom = (startY + totalTextHeight + 4).toInt();
      if (boxBottom >= image.height) {
        boxBottom = image.height - 1;
      }

      int x1;
      int x2;
      switch (watermarkPosition) {
        case WatermarkPosition.topLeft:
        case WatermarkPosition.bottomLeft:
          x1 = 0;
          x2 = (image.width / 2).toInt();
          break;
        case WatermarkPosition.topRight:
        case WatermarkPosition.bottomRight:
          x1 = (image.width / 2).toInt();
          x2 = image.width - 1;
          break;
      }

      if (bgAlpha > 0) {
        img.fillRect(
          image,
          x1: x1,
          y1: boxTop,
          x2: x2,
          y2: boxBottom,
          color: img.ColorRgba8(0, 0, 0, bgAlpha),
        );
      }

      if (showStatus && lines.isNotEmpty) {
        int? sr;
        int? sg;
        int? sb;
        switch (inspectionStatus.toLowerCase()) {
          case 'pass':
            sr = 34;
            sg = 197;
            sb = 94;
            break;
          case 'fail':
            sr = 239;
            sg = 68;
            sb = 68;
            break;
          case 'review':
            sr = 245;
            sg = 158;
            sb = 11;
            break;
        }

        if (sr != null && sg != null && sb != null) {
          final statusTop =
              (startY + logoBlockHeight - 4).toInt().clamp(0, image.height - 1);
          final statusBottom = (startY + logoBlockHeight + lineHeight + 4)
              .toInt()
              .clamp(0, image.height - 1);
          if (statusBottom > statusTop) {
            img.fillRect(
              image,
              x1: x1,
              y1: statusTop,
              x2: x2,
              y2: statusBottom,
              color: img.ColorRgba8(sr, sg, sb, bgAlpha),
            );
          }
        }
      }

      if (logoImage != null) {
        final logoX = (watermarkPosition == WatermarkPosition.topRight ||
                watermarkPosition == WatermarkPosition.bottomRight)
            ? (image.width - margin - logoImage.width)
            : margin;
        img.compositeImage(
          image,
          logoImage,
          dstX: logoX,
          dstY: startY,
          blend: img.BlendMode.alpha,
        );
      }

      final textStartY = startY + logoBlockHeight;
      for (int i = 0; i < lines.length; i++) {
        final y = (textStartY + i * lineHeight).toInt();
        switch (watermarkPosition) {
          case WatermarkPosition.topLeft:
          case WatermarkPosition.bottomLeft:
            img.drawString(
              image,
              lines[i],
              font: font,
              x: margin,
              y: y,
              color: textColor,
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
              color: textColor,
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
