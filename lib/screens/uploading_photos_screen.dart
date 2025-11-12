import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:buddyapp/utils/app_colors.dart';
import 'package:buddyapp/utils/app_text_styles.dart';
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
        fileName: 'IMG_${DateTime.now().year}${DateTime.now().month.toString().padLeft(2, '0')}${DateTime.now().day.toString().padLeft(2, '0')}${(1432 - i).toString()}.jpg',
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
    final uploadedCount = _uploadStatuses.where((s) => s.status == 'completed').length;
    final totalCount = _uploadStatuses.length;

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: _cancelUpload,
          icon: const Icon(
            Icons.close,
            color: AppColors.textPrimary,
          ),
        ),
        title: Text(
          'Uploading Photos',
          style: AppTextStyles.h3.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
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
                      style: AppTextStyles.bodyLarge.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      '${(_overallProgress * 100).toInt()}%',
                      style: AppTextStyles.bodyLarge.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: _overallProgress,
                    backgroundColor: AppColors.grey200,
                    valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
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
                        foregroundColor: AppColors.textSecondary,
                        side: const BorderSide(color: AppColors.grey300),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        'Cancel Upload',
                        style: AppTextStyles.buttonLarge.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
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
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.white,
                        disabledBackgroundColor: AppColors.grey300,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        'View Files',
                        style: AppTextStyles.buttonLarge.copyWith(
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
        statusColor = AppColors.success;
        trailing = Icon(statusIcon, color: statusColor, size: 24);
        break;
      case 'failed':
        statusIcon = Icons.error;
        statusColor = AppColors.error;
        trailing = GestureDetector(
          onTap: () => _retryFailedUpload(index),
          child: Text(
            'Tap to retry.',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.error,
              fontWeight: FontWeight.w600,
            ),
          ),
        );
        break;
      case 'uploading':
        statusIcon = Icons.refresh;
        statusColor = AppColors.primary;
        trailing = SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
        );
        break;
      default:
        statusIcon = Icons.schedule;
        statusColor = AppColors.grey400;
        trailing = Icon(statusIcon, color: statusColor, size: 24);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.grey200),
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
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
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
                  style: AppTextStyles.bodySmall.copyWith(
                    color: status.status == 'failed'
                        ? AppColors.error
                        : AppColors.textSecondary,
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
