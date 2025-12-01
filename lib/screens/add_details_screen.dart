import 'dart:io';
import 'package:flutter/material.dart';
import 'package:buddyapp/screens/review_upload_screen.dart';

class AddDetailsScreen extends StatefulWidget {
  final List<String> photos;
  final String workorderNumber;
  final String component;
  final String processStage;
  final String componentStamp;

  const AddDetailsScreen({
    super.key,
    required this.photos,
    required this.workorderNumber,
    required this.component,
    required this.processStage,
    required this.componentStamp,
  });

  @override
  State<AddDetailsScreen> createState() => _AddDetailsScreenState();
}

class _AddDetailsScreenState extends State<AddDetailsScreen> {
  int _selectedPhotoIndex = 0;
  String _selectedProject = 'Project Alpha - Q4';
  String _selectedComponent = 'Gearbox Assembly';
  String _inspectionStatus = 'Pass';
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
          componentStamp: widget.componentStamp,
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
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(
            Icons.arrow_back,
            color: Theme.of(context).iconTheme.color,
          ),
        ),
        title: Text(
          'Add Details',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                          color: isSelected
                              ? Theme.of(context).colorScheme.primary
                              : Colors.transparent,
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
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.primary,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.check,
                                  color:
                                      Theme.of(context).colorScheme.onPrimary,
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
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onPrimary,
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
                  // Damage Description
                  Text(
                    'Damage Description',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Theme.of(context).dividerColor),
                    ),
                    child: TextField(
                      controller: _descriptionController,
                      maxLines: 4,
                      decoration: InputDecoration(
                        hintText:
                            'e.g., Visible hairline crack on the main casing...',
                        hintStyle:
                            Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Theme.of(context).hintColor,
                                ),
                        border: InputBorder.none,
                      ),
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Inspection Status
                  Text(
                    'Inspection Status',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _buildStatusButton('Pass', Colors.green),
                      const SizedBox(width: 12),
                      _buildStatusButton('Fail', Colors.red),
                      const SizedBox(width: 12),
                      _buildStatusButton('Review', const Color(0xFFF59E0B)),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Urgency Level
                  Text(
                    'Urgency Level',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _buildUrgencyButton('Critical', Colors.red),
                      const SizedBox(width: 12),
                      _buildUrgencyButton('High', const Color(0xFFFF6B35)),
                      const SizedBox(width: 12),
                      _buildUrgencyButton('Medium', const Color(0xFFF59E0B)),
                      const SizedBox(width: 12),
                      _buildUrgencyButton('Low', Theme.of(context).hintColor),
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
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor:
                            Theme.of(context).colorScheme.onPrimary,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        'Save Metadata',
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: Colors.white),
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
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).colorScheme.primary,
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
            color: isSelected
                ? color.withOpacity(0.1)
                : Theme.of(context).cardTheme.color,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? color : Theme.of(context).dividerColor,
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
                color: isSelected ? color : Theme.of(context).hintColor,
                size: 20,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: isSelected ? color : Theme.of(context).hintColor,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.normal,
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
            color: isSelected
                ? color.withOpacity(0.1)
                : Theme.of(context).cardTheme.color,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? color : Theme.of(context).dividerColor,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: isSelected ? color : Theme.of(context).hintColor,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
