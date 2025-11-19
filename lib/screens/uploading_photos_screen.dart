import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:buddyapp/screens/dashboard_screen.dart';

class UploadingPhotosScreen extends StatefulWidget {
  final List<String> photos;
  final String workorderNumber;

  const UploadingPhotosScreen({
    super.key,
    required this.photos,
    required this.workorderNumber,
  });

  @override
  State<UploadingPhotosScreen> createState() => _UploadingPhotosScreenState();
}

class _UploadingPhotosScreenState extends State<UploadingPhotosScreen> {
  double _overallProgress = 0.0;
  int _currentUploadIndex = 0;
  final List<UploadStatus> _uploadStatuses = [];
  bool _isCancelled = false;
  Timer? _uploadTimer;

  @override
  void initState() {
    super.initState();
    _initializeUploadStatuses();
    _startUpload();
  }

  void _initializeUploadStatuses() {
    for (int i = 0; i < widget.photos.length; i++) {
      _uploadStatuses.add(UploadStatus(
        fileName:
            'IMG_${DateTime.now().year}${DateTime.now().month.toString().padLeft(2, '0')}${DateTime.now().day.toString().padLeft(2, '0')}${(1432 - i).toString()}.jpg',
        status: 'pending',
        progress: 0.0,
        photoPath: widget.photos[i],
      ));
    }
  }

  void _startUpload() {
    _uploadTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (_isCancelled) {
        timer.cancel();
        return;
      }

      setState(() {
        if (_currentUploadIndex < _uploadStatuses.length) {
          // Update current photo progress
          if (_uploadStatuses[_currentUploadIndex].progress < 1.0) {
            _uploadStatuses[_currentUploadIndex].progress += 0.02;
            _uploadStatuses[_currentUploadIndex].status = 'uploading';

            if (_uploadStatuses[_currentUploadIndex].progress >= 1.0) {
              _uploadStatuses[_currentUploadIndex].progress = 1.0;
              // Randomly set some as failed for demo
              if (_currentUploadIndex == 2) {
                _uploadStatuses[_currentUploadIndex].status = 'failed';
              } else {
                _uploadStatuses[_currentUploadIndex].status = 'completed';
              }
              _currentUploadIndex++;
            }
          }
        } else {
          // All uploads complete
          timer.cancel();
        }

        // Calculate overall progress
        double totalProgress = 0;
        for (var status in _uploadStatuses) {
          totalProgress += status.progress;
        }
        _overallProgress = totalProgress / _uploadStatuses.length;
      });
    });
  }

  void _cancelUpload() {
    setState(() {
      _isCancelled = true;
    });
    _uploadTimer?.cancel();
    Navigator.pop(context);
  }

  void _retryFailedUpload(int index) {
    setState(() {
      _uploadStatuses[index].status = 'uploading';
      _uploadStatuses[index].progress = 0.0;
    });

    Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (_uploadStatuses[index].progress < 1.0) {
        setState(() {
          _uploadStatuses[index].progress += 0.02;
        });
      } else {
        setState(() {
          _uploadStatuses[index].progress = 1.0;
          _uploadStatuses[index].status = 'completed';
        });
        timer.cancel();
      }
    });
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
    _uploadTimer?.cancel();
    super.dispose();
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
                        'View Files',
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
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
