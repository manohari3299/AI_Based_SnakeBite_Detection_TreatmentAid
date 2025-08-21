import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class CameraControlsWidget extends StatelessWidget {
  final VoidCallback onCapture;
  final VoidCallback onGallery;
  final VoidCallback onTorch;
  final bool isTorchOn;
  final String? lastImagePath;
  final bool isCapturing;

  const CameraControlsWidget({
    Key? key,
    required this.onCapture,
    required this.onGallery,
    required this.onTorch,
    required this.isTorchOn,
    this.lastImagePath,
    required this.isCapturing,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 3.h),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // Gallery Access
            GestureDetector(
              onTap: onGallery,
              child: Container(
                width: 15.w,
                height: 15.w,
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: lastImagePath != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: CustomImageWidget(
                          imageUrl: lastImagePath!,
                          width: 15.w,
                          height: 15.w,
                          fit: BoxFit.cover,
                        ),
                      )
                    : CustomIconWidget(
                        iconName: 'photo_library',
                        color: Colors.white,
                        size: 8.w,
                      ),
              ),
            ),

            // Capture Button
            GestureDetector(
              onTap: isCapturing ? null : onCapture,
              child: Container(
                width: 20.w,
                height: 20.w,
                decoration: BoxDecoration(
                  color: isCapturing
                      ? AppTheme.lightTheme.colorScheme.primary
                          .withValues(alpha: 0.7)
                      : AppTheme.lightTheme.colorScheme.primary,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 4),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: isCapturing
                    ? Center(
                        child: SizedBox(
                          width: 8.w,
                          height: 8.w,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 3,
                          ),
                        ),
                      )
                    : CustomIconWidget(
                        iconName: 'camera_alt',
                        color: Colors.white,
                        size: 10.w,
                      ),
              ),
            ),

            // Torch Toggle
            GestureDetector(
              onTap: onTorch,
              child: Container(
                width: 15.w,
                height: 15.w,
                decoration: BoxDecoration(
                  color: isTorchOn
                      ? Colors.yellow.withValues(alpha: 0.8)
                      : Colors.black.withValues(alpha: 0.6),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: CustomIconWidget(
                  iconName: isTorchOn ? 'flashlight_on' : 'flashlight_off',
                  color: isTorchOn ? Colors.black : Colors.white,
                  size: 8.w,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
