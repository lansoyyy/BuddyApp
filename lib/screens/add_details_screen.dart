import 'dart:io';
import 'package:flutter/material.dart';
import 'package:buddyapp/utils/app_colors.dart';
import 'package:buddyapp/utils/app_text_styles.dart';
import 'package:buddyapp/screens/review_upload_screen.dart';

class AddDetailsScreen extends StatefulWidget {
  final List<String> photos;
  final String workorderNumber;
  final String component;
  final String processStage;

  const AddDetailsScreen({
    super.key,
    required this.photos,
    required this.workorderNumber,
    required this.component,
    required this.processStage,
  });

  @override
  State<AddDetailsScreen> createState() => _AddDetailsScreenState();
}

class _AddDetailsScreenState extends State<AddDetailsScreen> {
  int _selectedPhotoIndex = 0;
  String _selectedProject = 'Project Alpha - Q4';
  String _selectedComponent = 'Gearbox Assembly';
  String _inspectionStatus = 'Fail';
  String _urgencyLevel = 'Critical';
  final TextEditingController _descriptionController = TextEditingController();
  bool _applyToAll = false;

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  void _saveMetadata() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => ReviewUploadScreen(
          photos: widget.photos,
          workorderNumber: widget.workorderNumber,
          component: widget.component,
          processStage: widget.processStage,
          project: _selectedProject,
          componentPart: _selectedComponent,
          description: _descriptionController.text,
          inspectionStatus: _inspectionStatus,
          urgencyLevel: _urgencyLevel,
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
          'Add Details',
          style: AppTextStyles.h3.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Photo Thumbnails
            SizedBox(
              height: 120,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                itemCount: widget.photos.length,
                itemBuilder: (context, index) {
                  final isSelected = index == _selectedPhotoIndex;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedPhotoIndex = index;
                      });
                    },
                    child: Container(
                      width: 90,
                      margin: const EdgeInsets.only(right: 12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected ? AppColors.primary : Colors.transparent,
                          width: 3,
                        ),
                      ),
                      child: Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.file(
                              File(widget.photos[index]),
                              width: 90,
                              height: 104,
                              fit: BoxFit.cover,
                            ),
                          ),
                          if (isSelected)
                            Positioned(
                              top: 4,
                              right: 4,
                              child: Container(
                                padding: const EdgeInsets.all(2),
                                decoration: const BoxDecoration(
                                  color: AppColors.primary,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.check,
                                  color: AppColors.white,
                                  size: 16,
                                ),
                              ),
                            ),
                          Positioned(
                            bottom: 4,
                            left: 4,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.6),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                'Photo ${index + 1}',
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.white,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            // Large Preview
            Padding(
              padding: const EdgeInsets.all(16),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(
                  File(widget.photos[_selectedPhotoIndex]),
                  width: double.infinity,
                  height: 250,
                  fit: BoxFit.cover,
                ),
              ),
            ),

            // Form Fields
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Project/Work Order
                  Text(
                    'Project/Work Order',
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.grey100,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.grey300),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedProject,
                        isExpanded: true,
                        icon: const Icon(Icons.keyboard_arrow_down),
                        items: [
                          'Project Alpha - Q4',
                          'Project Beta - Q3',
                          'Project Gamma - Q2',
                        ].map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(
                              value,
                              style: AppTextStyles.bodyMedium,
                            ),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          if (newValue != null) {
                            setState(() {
                              _selectedProject = newValue;
                            });
                          }
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Component Part
                  Text(
                    'Component Part',
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.grey100,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.grey300),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedComponent,
                        isExpanded: true,
                        icon: const Icon(Icons.keyboard_arrow_down),
                        items: [
                          'Gearbox Assembly',
                          'Turbine Blade',
                          'Hydraulic System',
                        ].map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(
                              value,
                              style: AppTextStyles.bodyMedium,
                            ),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          if (newValue != null) {
                            setState(() {
                              _selectedComponent = newValue;
                            });
                          }
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Damage Description
                  Text(
                    'Damage Description',
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: AppColors.grey100,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.grey300),
                    ),
                    child: TextField(
                      controller: _descriptionController,
                      maxLines: 4,
                      decoration: InputDecoration(
                        hintText: 'e.g., Visible hairline crack on the main casing...',
                        hintStyle: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textTertiary,
                        ),
                        border: InputBorder.none,
                      ),
                      style: AppTextStyles.bodyMedium,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Inspection Status
                  Text(
                    'Inspection Status',
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _buildStatusButton('Pass', AppColors.success),
                      const SizedBox(width: 12),
                      _buildStatusButton('Fail', AppColors.error),
                      const SizedBox(width: 12),
                      _buildStatusButton('Review', AppColors.warning),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Urgency Level
                  Text(
                    'Urgency Level',
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _buildUrgencyButton('Critical', AppColors.error),
                      const SizedBox(width: 12),
                      _buildUrgencyButton('High', const Color(0xFFFF6B35)),
                      const SizedBox(width: 12),
                      _buildUrgencyButton('Medium', AppColors.warning),
                      const SizedBox(width: 12),
                      _buildUrgencyButton('Low', AppColors.textSecondary),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Save Button
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: _saveMetadata,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        'Save Metadata',
                        style: AppTextStyles.buttonLarge.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Apply to all photos
                  Center(
                    child: TextButton(
                      onPressed: () {
                        // Apply to all photos logic
                        _saveMetadata();
                      },
                      child: Text(
                        'Apply to all ${widget.photos.length} photos',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusButton(String label, Color color) {
    final isSelected = _inspectionStatus == label;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _inspectionStatus = label;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? color.withOpacity(0.1) : AppColors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? color : AppColors.grey300,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                label == 'Pass'
                    ? Icons.check_circle_outline
                    : label == 'Fail'
                        ? Icons.cancel_outlined
                        : Icons.info_outline,
                color: isSelected ? color : AppColors.textSecondary,
                size: 20,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: isSelected ? color : AppColors.textSecondary,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUrgencyButton(String label, Color color) {
    final isSelected = _urgencyLevel == label;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _urgencyLevel = label;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? color.withOpacity(0.1) : AppColors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? color : AppColors.grey300,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(
              color: isSelected ? color : AppColors.textSecondary,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
