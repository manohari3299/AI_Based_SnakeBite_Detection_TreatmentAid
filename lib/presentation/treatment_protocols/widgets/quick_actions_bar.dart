import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../../core/app_export.dart';

class QuickActionsBar extends StatelessWidget {
  final VoidCallback onCallEmergency;
  final VoidCallback onShareProtocol;
  final VoidCallback onPrintInstructions;
  final VoidCallback? onDone;

  const QuickActionsBar({
    Key? key,
    required this.onCallEmergency,
    required this.onShareProtocol,
    required this.onPrintInstructions,
    this.onDone,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: AppTheme.shadowColor,
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: _buildActionButton(
                  label: 'Call 911',
                  iconName: 'phone',
                  color: AppTheme.lightTheme.colorScheme.error,
                  onPressed: onCallEmergency,
                ),
              ),
              SizedBox(width: 2.w),
              Expanded(
                child: _buildActionButton(
                  label: 'Share',
                  iconName: 'share',
                  color: AppTheme.lightTheme.colorScheme.tertiary,
                  onPressed: onShareProtocol,
                ),
              ),
              SizedBox(width: 2.w),
              Expanded(
                child: _buildActionButton(
                  label: 'Print',
                  iconName: 'print',
                  color: AppTheme.lightTheme.colorScheme.secondary,
                  onPressed: onPrintInstructions,
                ),
              ),
            ],
          ),
          if (onDone != null) ...[
            SizedBox(height: 2.h),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: onDone,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.lightTheme.colorScheme.secondary.withValues(alpha: 0.1),
                  foregroundColor: AppTheme.lightTheme.colorScheme.secondary,
                  elevation: 0,
                  padding: EdgeInsets.symmetric(vertical: 1.5.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: BorderSide(
                      color: AppTheme.lightTheme.colorScheme.secondary,
                      width: 1.5,
                    ),
                  ),
                ),
                icon: CustomIconWidget(
                  iconName: 'check_circle',
                  color: AppTheme.lightTheme.colorScheme.secondary,
                  size: 18.sp,
                ),
                label: Text(
                  'Done',
                  style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.secondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required String label,
    required String iconName,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color.withValues(alpha: 0.1),
        foregroundColor: color,
        elevation: 0,
        padding: EdgeInsets.symmetric(vertical: 1.5.h),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: color, width: 1),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CustomIconWidget(
            iconName: iconName,
            color: color,
            size: 18.sp,
          ),
          SizedBox(height: 0.5.h),
          Text(
            label,
            style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w500,
              fontSize: 10.sp,
            ),
          ),
        ],
      ),
    );
  }
}
