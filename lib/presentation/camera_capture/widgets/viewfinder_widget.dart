import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class ViewfinderWidget extends StatelessWidget {
  final String compositionHint;
  final Color hintColor;

  const ViewfinderWidget({
    Key? key,
    required this.compositionHint,
    required this.hintColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Viewfinder Frame
          Container(
            width: 70.w,
            height: 50.h,
            decoration: BoxDecoration(
              border: Border.all(
                color: hintColor,
                width: 3,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Stack(
              children: [
                // Corner Guides
                Positioned(
                  top: 0,
                  left: 0,
                  child: Container(
                    width: 8.w,
                    height: 8.w,
                    decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(color: hintColor, width: 4),
                        left: BorderSide(color: hintColor, width: 4),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 0,
                  right: 0,
                  child: Container(
                    width: 8.w,
                    height: 8.w,
                    decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(color: hintColor, width: 4),
                        right: BorderSide(color: hintColor, width: 4),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  child: Container(
                    width: 8.w,
                    height: 8.w,
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: hintColor, width: 4),
                        left: BorderSide(color: hintColor, width: 4),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 8.w,
                    height: 8.w,
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: hintColor, width: 4),
                        right: BorderSide(color: hintColor, width: 4),
                      ),
                    ),
                  ),
                ),

                // Center Focus Point
                Center(
                  child: Container(
                    width: 4.w,
                    height: 4.w,
                    decoration: BoxDecoration(
                      color: hintColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 3.h),

          // Composition Hint
          if (compositionHint.isNotEmpty)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(25),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CustomIconWidget(
                    iconName: _getHintIcon(compositionHint),
                    color: hintColor,
                    size: 4.w,
                  ),
                  SizedBox(width: 2.w),
                  Text(
                    compositionHint,
                    style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                      color: Colors.white,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  String _getHintIcon(String hint) {
    if (hint.contains('closer')) return 'zoom_in';
    if (hint.contains('steady')) return 'center_focus_strong';
    if (hint.contains('Good')) return 'check_circle';
    return 'info';
  }
}
