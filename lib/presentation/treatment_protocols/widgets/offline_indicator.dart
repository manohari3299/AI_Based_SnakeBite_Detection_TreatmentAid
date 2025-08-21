import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../../core/app_export.dart';

class OfflineIndicator extends StatelessWidget {
  final bool isOffline;

  const OfflineIndicator({
    Key? key,
    required this.isOffline,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (!isOffline) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      color: AppTheme.lightTheme.colorScheme.secondary.withValues(alpha: 0.1),
      child: Row(
        children: [
          CustomIconWidget(
            iconName: 'offline_bolt',
            color: AppTheme.lightTheme.colorScheme.secondary,
            size: 16.sp,
          ),
          SizedBox(width: 2.w),
          Expanded(
            child: Text(
              'Offline Mode - All treatment data available locally',
              style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
                color: AppTheme.lightTheme.colorScheme.secondary,
                fontWeight: FontWeight.w500,
                fontSize: 11.sp,
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.secondary,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              'RELIABLE',
              style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 9.sp,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
