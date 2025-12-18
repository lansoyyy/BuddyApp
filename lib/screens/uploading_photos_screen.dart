import 'dart:io';
import 'package:flutter/material.dart';
import 'package:buddyapp/screens/dashboard_screen.dart';
import 'package:buddyapp/services/google_drive_service.dart';
import 'package:buddyapp/services/storage_service.dart';
import 'package:buddyapp/utils/watermark_position.dart';

class UploadingPhotosScreen extends StatefulWidget {
  final List<String> photos;
  final String workorderNumber;
  final String component;
  final String processStage;
  final String project;
  final String componentPart;
  final String componentStamp;
  final String description;
  final String inspectionStatus;
  final String urgencyLevel;
  final String driveAccessToken;
  final WatermarkPosition watermarkPosition;

  const UploadingPhotosScreen({
    super.key,
    required this.photos,
    required this.workorderNumber,
    required this.component,
    required this.processStage,
    required this.project,
    required this.componentPart,
    required this.componentStamp,
    required this.description,
    required this.inspectionStatus,
    required this.urgencyLevel,
    required this.watermarkPosition,
    this.driveAccessToken = '',
  });

  @override
  State<UploadingPhotosScreen> createState() => _UploadingPhotosScreenState();
}

class _UploadingPhotosScreenState extends State<UploadingPhotosScreen> {
  double _overallProgress = 0.0;
  int _currentUploadIndex = 0;
  final List<UploadStatus> _uploadStatuses = [];
  bool _isCancelled = false;
  GoogleDriveService? _driveService;
  String _userInitials = 'NA';
  int _existingPhotoCount = 0; // Offset for photo numbering to avoid duplicates
  String _fileNameTemplate = '{component}_Photo{photoNumber}_{initials}.jpg';

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    await _loadUserInitials();
    final storage = await StorageService.getInstance();
    _fileNameTemplate = storage.getSetting<String>(
          'fileNameTemplate',
          defaultValue: '{component}_Photo{photoNumber}_{initials}.jpg',
        ) ??
        '{component}_Photo{photoNumber}_{initials}.jpg';
    if (widget.driveAccessToken.isNotEmpty) {
      _driveService = GoogleDriveService(accessToken: widget.driveAccessToken);
      // Query existing photos to continue numbering and avoid duplicates
      try {
        _existingPhotoCount = await _driveService!.countExistingPhotos(
          workorderNumber: widget.workorderNumber,
          component: widget.component,
        );
      } catch (_) {
        _existingPhotoCount = 0;
      }
    }
    _initializeUploadStatuses();
    _startUpload();
  }

  Future<void> _loadUserInitials() async {
    try {
      final storage = await StorageService.getInstance();
      final userData = storage.getUserData();
      String initials = 'NA';
      if (userData != null) {
        final first = (userData['firstName'] as String?)?.trim();
        final last = (userData['lastName'] as String?)?.trim();
        if (first != null &&
            first.isNotEmpty &&
            last != null &&
            last.isNotEmpty) {
          initials = '${first[0].toUpperCase()}${last[0].toUpperCase()}';
        }
      }
      _userInitials = initials;
    } catch (_) {
      _userInitials = 'NA';
    }
  }

  String _buildFileName(int index) {
    String sanitize(String value) {
      final sanitized = value
          .replaceAll(RegExp(r'[^A-Za-z0-9]+'), '_')
          .replaceAll(RegExp(r'_+'), '_')
          .replaceAll(RegExp(r'^_+|_+$'), '');
      return sanitized.isEmpty ? 'NA' : sanitized;
    }

    final photoNumber = _existingPhotoCount + index + 1;

    final vars = <String, String>{
      'component': sanitize(widget.component),
      'photoNumber': photoNumber.toString(),
      'initials': sanitize(_userInitials),
      'workorderNumber': sanitize(widget.workorderNumber),
      'processStage': sanitize(widget.processStage),
      'project': sanitize(widget.project),
      'componentPart': sanitize(widget.componentPart),
      'componentStamp': sanitize(widget.componentStamp),
      'inspectionStatus': sanitize(widget.inspectionStatus),
      'urgencyLevel': sanitize(widget.urgencyLevel),
    };

    var name = _fileNameTemplate;
    vars.forEach((key, value) {
      name = name.replaceAll('{$key}', value);
    });

    name = name.trim();
    if (name.isEmpty) {
      name =
          '${vars['component']}_Photo${vars['photoNumber']}_${vars['initials']}.jpg';
    }

    final lower = name.toLowerCase();
    if (!lower.endsWith('.jpg') && !lower.endsWith('.jpeg')) {
      name = '$name.jpg';
    }

    return name;
  }

  void _initializeUploadStatuses() {
    for (int i = 0; i < widget.photos.length; i++) {
      _uploadStatuses.add(UploadStatus(
        fileName: _buildFileName(i),
        status: 'pending',
        progress: 0.0,
        photoPath: widget.photos[i],
      ));
    }
  }

  Future<void> _startUpload() async {
    if (_uploadStatuses.isEmpty) {
      return;
    }

    if (_driveService == null) {
      for (int i = 0; i < _uploadStatuses.length; i++) {
        if (_isCancelled) {
          break;
        }
        setState(() {
          _currentUploadIndex = i;
          _uploadStatuses[i].status = 'failed';
          _uploadStatuses[i].progress = 1.0;
          _recalculateOverallProgress();
        });
      }
      return;
    }

    for (int i = 0; i < _uploadStatuses.length; i++) {
      if (_isCancelled) {
        break;
      }

      final status = _uploadStatuses[i];
      setState(() {
        _currentUploadIndex = i;
        status.status = 'uploading';
        status.progress = 0.0;
      });

      try {
        await _driveService!.uploadPhoto(
          localPath: status.photoPath,
          fileName: status.fileName,
          workorderNumber: widget.workorderNumber,
          component: widget.component,
          processStage: widget.processStage,
          project: widget.project,
          componentPart: widget.componentPart,
          componentStamp: widget.componentStamp,
          description: widget.description,
          inspectionStatus: widget.inspectionStatus,
          urgencyLevel: widget.urgencyLevel,
          watermarkPosition: widget.watermarkPosition,
        );

        setState(() {
          status.progress = 1.0;
          status.status = 'completed';
          _recalculateOverallProgress();
        });
      } catch (e, st) {
        debugPrint('Drive upload failed for ${status.fileName}: $e');
        debugPrint('$st');
        setState(() {
          status.progress = 1.0;
          status.status = 'failed';
          _recalculateOverallProgress();
        });
      }
    }
  }

  void _cancelUpload() {
    setState(() {
      _isCancelled = true;
    });
    Navigator.pop(context);
  }

  Future<void> _retryFailedUpload(int index) async {
    if (_driveService == null || _isCancelled) {
      return;
    }

    final status = _uploadStatuses[index];
    setState(() {
      status.status = 'uploading';
      status.progress = 0.0;
    });

    try {
      await _driveService!.uploadPhoto(
        localPath: status.photoPath,
        fileName: status.fileName,
        workorderNumber: widget.workorderNumber,
        component: widget.component,
        processStage: widget.processStage,
        project: widget.project,
        componentPart: widget.componentPart,
        componentStamp: widget.componentStamp,
        description: widget.description,
        inspectionStatus: widget.inspectionStatus,
        urgencyLevel: widget.urgencyLevel,
        watermarkPosition: widget.watermarkPosition,
      );

      setState(() {
        status.progress = 1.0;
        status.status = 'completed';
        _recalculateOverallProgress();
      });
    } catch (e, st) {
      debugPrint('Drive re-upload failed for ${status.fileName}: $e');
      debugPrint('$st');
      setState(() {
        status.progress = 1.0;
        status.status = 'failed';
        _recalculateOverallProgress();
      });
    }
  }

  void _viewFiles() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const DashboardScreen()),
      (route) => false,
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _recalculateOverallProgress() {
    if (_uploadStatuses.isEmpty) {
      _overallProgress = 0.0;
      return;
    }

    double totalProgress = 0;
    for (final status in _uploadStatuses) {
      totalProgress += status.progress;
    }
    _overallProgress = totalProgress / _uploadStatuses.length;
  }

  @override
  Widget build(BuildContext context) {
    final uploadedCount =
        _uploadStatuses.where((s) => s.status == 'completed').length;
    final totalCount = _uploadStatuses.length;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        leading: IconButton(
          onPressed: _cancelUpload,
          icon: Icon(
            Icons.close,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        title: Text(
          'Uploading Photos',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Overall Progress
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Uploading $uploadedCount of $totalCount photos...',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                    ),
                    Text(
                      '${(_overallProgress * 100).toInt()}%',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: _overallProgress,
                    backgroundColor: Theme.of(context).colorScheme.surface,
                    valueColor: AlwaysStoppedAnimation<Color>(
                        Theme.of(context).colorScheme.primary),
                    minHeight: 8,
                  ),
                ),
              ],
            ),
          ),

          // Upload List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: _uploadStatuses.length,
              itemBuilder: (context, index) {
                final status = _uploadStatuses[index];
                return _buildUploadItem(status, index);
              },
            ),
          ),

          // Bottom Buttons
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 54,
                    child: OutlinedButton(
                      onPressed: _cancelUpload,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withOpacity(0.7),
                        side: BorderSide(
                            color: Theme.of(context).colorScheme.outline),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        'Cancel Upload',
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withOpacity(0.7),
                            ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SizedBox(
                    height: 54,
                    child: ElevatedButton(
                      onPressed: _overallProgress >= 1.0 ? _viewFiles : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor:
                            Theme.of(context).colorScheme.onPrimary,
                        disabledBackgroundColor:
                            Theme.of(context).colorScheme.surface,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        'Done',
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            fontWeight: FontWeight.w600, color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUploadItem(UploadStatus status, int index) {
    IconData statusIcon;
    Color statusColor;
    Widget? trailing;

    switch (status.status) {
      case 'completed':
        statusIcon = Icons.check_circle;
        statusColor = Colors.green;
        trailing = Icon(statusIcon, color: statusColor, size: 24);
        break;
      case 'failed':
        statusIcon = Icons.error;
        statusColor = Colors.red;
        trailing = GestureDetector(
          onTap: () => _retryFailedUpload(index),
          child: Text(
            'Tap to retry.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.red,
                  fontWeight: FontWeight.w600,
                ),
          ),
        );
        break;
      case 'uploading':
        statusIcon = Icons.refresh;
        statusColor = Theme.of(context).colorScheme.primary;
        trailing = SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(
                Theme.of(context).colorScheme.primary),
          ),
        );
        break;
      default:
        statusIcon = Icons.schedule;
        statusColor = Theme.of(context).colorScheme.onSurface.withOpacity(0.4);
        trailing = Icon(statusIcon, color: statusColor, size: 24);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).colorScheme.outline),
      ),
      child: Row(
        children: [
          // Thumbnail
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.file(
              File(status.photoPath),
              width: 56,
              height: 56,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 12),

          // File Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  status.fileName,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  status.status == 'completed'
                      ? 'Completed'
                      : status.status == 'failed'
                          ? 'Failed: Connection lost. Tap to retry.'
                          : 'Uploading...',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: status.status == 'failed'
                            ? Colors.red
                            : Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withOpacity(0.7),
                      ),
                ),
              ],
            ),
          ),

          // Status Icon or Progress
          trailing ?? const SizedBox(),
        ],
      ),
    );
  }
}

class UploadStatus {
  final String fileName;
  String status; // 'pending', 'uploading', 'completed', 'failed'
  double progress;
  final String photoPath;

  UploadStatus({
    required this.fileName,
    required this.status,
    required this.progress,
    required this.photoPath,
  });
}
