import 'dart:io';
import 'package:flutter/material.dart';
import 'package:buddyapp/utils/app_colors.dart';
import 'package:buddyapp/utils/app_text_styles.dart';
import 'package:buddyapp/screens/add_details_screen.dart';

class ReviewPhotosScreen extends StatefulWidget {
  final List<String> photos;
  final String workorderNumber;
  final String component;
  final String processStage;

  const ReviewPhotosScreen({
    super.key,
    required this.photos,
    required this.workorderNumber,
    required this.component,
    required this.processStage,
  });

  @override
  State<ReviewPhotosScreen> createState() => _ReviewPhotosScreenState();
}

class _ReviewPhotosScreenState extends State<ReviewPhotosScreen> {
  late List<String> _photos;

  @override
  void initState() {
    super.initState();
    _photos = List.from(widget.photos);
  }

  void _deletePhoto(int index) {
    setState(() {
      _photos.removeAt(index);
    });
  }

  void _viewFullScreen(String photoPath) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FullScreenPhotoView(photoPath: photoPath),
      ),
    );
  }

  void _navigateToAddDetails() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => AddDetailsScreen(
          photos: _photos,
          workorderNumber: widget.workorderNumber,
          component: widget.component,
          processStage: widget.processStage,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(
            Icons.arrow_back,
            color: AppColors.textPrimary,
          ),
        ),
        title: Text(
          'Review Photos',
          style: AppTextStyles.h3.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Instructions
          Padding(
            padding: const EdgeInsets.all(20),
            child: Text(
              'Tap a photo to view full-screen. Delete or retake any shots before proceeding.',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ),

          // Photo Grid
          Expanded(
            child: _photos.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.photo_library_outlined,
                          size: 80,
                          color: AppColors.grey300,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No photos captured',
                          style: AppTextStyles.bodyLarge.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 1,
                    ),
                    itemCount: _photos.length,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () => _viewFullScreen(_photos[index]),
                        onLongPress: () {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: Text(
                                'Delete Photo',
                                style: AppTextStyles.h3.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              content: Text(
                                'Are you sure you want to delete this photo?',
                                style: AppTextStyles.bodyMedium,
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: Text(
                                    'Cancel',
                                    style: AppTextStyles.bodyMedium.copyWith(
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                    _deletePhoto(index);
                                  },
                                  child: Text(
                                    'Delete',
                                    style: AppTextStyles.bodyMedium.copyWith(
                                      color: AppColors.error,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            image: DecorationImage(
                              image: FileImage(File(_photos[index])),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),

          // Next Button
          Padding(
            padding: const EdgeInsets.all(20),
            child: SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: _photos.isEmpty ? null : _navigateToAddDetails,
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
                  'Next: Add Details',
                  style: AppTextStyles.buttonLarge.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class FullScreenPhotoView extends StatelessWidget {
  final String photoPath;

  const FullScreenPhotoView({
    super.key,
    required this.photoPath,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(
            Icons.close,
            color: AppColors.white,
          ),
        ),
      ),
      body: Center(
        child: InteractiveViewer(
          minScale: 0.5,
          maxScale: 4.0,
          child: Image.file(File(photoPath)),
        ),
      ),
    );
  }
}
