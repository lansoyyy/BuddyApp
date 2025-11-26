import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

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
    required String description,
    required String inspectionStatus,
    required String urgencyLevel,
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
}
