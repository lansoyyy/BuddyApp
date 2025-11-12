import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:buddyapp/utils/app_colors.dart';
import 'package:buddyapp/utils/app_text_styles.dart';
import 'package:buddyapp/screens/review_photos_screen.dart';

class CameraCaptureScreen extends StatefulWidget {
  final String workorderNumber;
  final String component;
  final String processStage;

  const CameraCaptureScreen({
    super.key,
    required this.workorderNumber,
    required this.component,
    required this.processStage,
  });

  @override
  State<CameraCaptureScreen> createState() => _CameraCaptureScreenState();
}

class _CameraCaptureScreenState extends State<CameraCaptureScreen> {
  CameraController? _controller;
  List<CameraDescription>? _cameras;
  bool _isInitialized = false;
  bool _isFlashOn = false;
  List<String> _capturedPhotos = [];

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras!.isNotEmpty) {
        _controller = CameraController(
          _cameras![0],
          ResolutionPreset.high,
          enableAudio: false,
        );
        await _controller!.initialize();
        if (mounted) {
          setState(() {
            _isInitialized = true;
          });
        }
      }
    } catch (e) {
      debugPrint('Error initializing camera: $e');
    }
  }

  Future<void> _toggleFlash() async {
    if (_controller != null) {
      setState(() {
        _isFlashOn = !_isFlashOn;
      });
      await _controller!.setFlashMode(
        _isFlashOn ? FlashMode.torch : FlashMode.off,
      );
    }
  }

  Future<void> _capturePhoto() async {
    if (_controller != null && _controller!.value.isInitialized) {
      try {
        final image = await _controller!.takePicture();
        setState(() {
          _capturedPhotos.add(image.path);
        });
      } catch (e) {
        debugPrint('Error capturing photo: $e');
      }
    }
  }

  void _navigateToReview() {
    if (_capturedPhotos.isNotEmpty) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ReviewPhotosScreen(
            photos: _capturedPhotos,
            workorderNumber: widget.workorderNumber,
            component: widget.component,
            processStage: widget.processStage,
          ),
        ),
      );
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Camera Preview
          if (_isInitialized && _controller != null)
            SizedBox.expand(
              child: CameraPreview(_controller!),
            )
          else
            const Center(
              child: CircularProgressIndicator(
                color: AppColors.primary,
              ),
            ),

          // Top Info Card
          Positioned(
            top: 50,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF2C3E50).withOpacity(0.9),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Text(
                    'Workorder #${widget.workorderNumber}',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.white,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Turbine Blade Inspection',
                    style: AppTextStyles.h3.copyWith(
                      color: AppColors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Stage: ${widget.processStage}',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Close Button
          Positioned(
            top: 50,
            left: 20,
            child: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(
                Icons.close,
                color: AppColors.white,
                size: 28,
              ),
            ),
          ),

          // Flash Toggle Button
          Positioned(
            top: 50,
            right: 20,
            child: IconButton(
              onPressed: _toggleFlash,
              icon: Icon(
                _isFlashOn ? Icons.flash_on : Icons.flash_off,
                color: AppColors.white,
                size: 28,
              ),
            ),
          ),

          // Dashed Border Frame
          Positioned(
            top: 180,
            left: 20,
            right: 20,
            bottom: 200,
            child: CustomPaint(
              painter: DashedBorderPainter(),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Position Waybill in Frame',
                      style: AppTextStyles.h3.copyWith(
                        color: AppColors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40),
                      child: Text(
                        'Make sure all corners are visible and the document is flat.',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.white.withOpacity(0.9),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Bottom Controls
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Column(
              children: [
                Text(
                  'Align and capture',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.white,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Gallery Button
                    GestureDetector(
                      onTap: _navigateToReview,
                      child: Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.white.withOpacity(0.3),
                            width: 2,
                          ),
                        ),
                        child: Stack(
                          children: [
                            Center(
                              child: Icon(
                                Icons.photo_library,
                                color: AppColors.white,
                                size: 28,
                              ),
                            ),
                            if (_capturedPhotos.isNotEmpty)
                              Positioned(
                                top: 4,
                                right: 4,
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: const BoxDecoration(
                                    color: AppColors.primary,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Text(
                                    '${_capturedPhotos.length}',
                                    style: AppTextStyles.bodySmall.copyWith(
                                      color: AppColors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 40),
                    // Capture Button
                    GestureDetector(
                      onTap: _capturePhoto,
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.white,
                            width: 4,
                          ),
                        ),
                        child: Container(
                          margin: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(
                            color: AppColors.white,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 100),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class DashedBorderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primary
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    const dashWidth = 10.0;
    const dashSpace = 8.0;
    const cornerRadius = 12.0;

    final path = Path();
    
    // Top left corner
    path.moveTo(cornerRadius, 0);
    
    // Top line
    double distance = cornerRadius;
    while (distance < size.width - cornerRadius) {
      path.lineTo(distance + dashWidth, 0);
      distance += dashWidth + dashSpace;
      if (distance < size.width - cornerRadius) {
        path.moveTo(distance, 0);
      }
    }
    
    // Top right corner
    path.lineTo(size.width - cornerRadius, 0);
    path.arcToPoint(
      Offset(size.width, cornerRadius),
      radius: const Radius.circular(cornerRadius),
    );
    
    // Right line
    distance = cornerRadius;
    while (distance < size.height - cornerRadius) {
      path.lineTo(size.width, distance + dashWidth);
      distance += dashWidth + dashSpace;
      if (distance < size.height - cornerRadius) {
        path.moveTo(size.width, distance);
      }
    }
    
    // Bottom right corner
    path.lineTo(size.width, size.height - cornerRadius);
    path.arcToPoint(
      Offset(size.width - cornerRadius, size.height),
      radius: const Radius.circular(cornerRadius),
    );
    
    // Bottom line
    distance = size.width - cornerRadius;
    while (distance > cornerRadius) {
      path.lineTo(distance - dashWidth, size.height);
      distance -= dashWidth + dashSpace;
      if (distance > cornerRadius) {
        path.moveTo(distance, size.height);
      }
    }
    
    // Bottom left corner
    path.lineTo(cornerRadius, size.height);
    path.arcToPoint(
      Offset(0, size.height - cornerRadius),
      radius: const Radius.circular(cornerRadius),
    );
    
    // Left line
    distance = size.height - cornerRadius;
    while (distance > cornerRadius) {
      path.lineTo(0, distance - dashWidth);
      distance -= dashWidth + dashSpace;
      if (distance > cornerRadius) {
        path.moveTo(0, distance);
      }
    }
    
    // Complete the path
    path.lineTo(0, cornerRadius);
    path.arcToPoint(
      Offset(cornerRadius, 0),
      radius: const Radius.circular(cornerRadius),
    );

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
