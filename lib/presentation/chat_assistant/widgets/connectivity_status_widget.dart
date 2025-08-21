import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';

class ConnectivityStatusWidget extends StatelessWidget {
  final bool isOnline;

  const ConnectivityStatusWidget({
    Key? key,
    required this.isOnline,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.5.h),
      decoration: BoxDecoration(
        color: isOnline
            ? AppTheme.successLight.withValues(alpha: 0.1)
            : AppTheme.warningLight.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4.w),
        border: Border.all(
          color: isOnline ? AppTheme.successLight : AppTheme.warningLight,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 2.w,
            height: 2.w,
            decoration: BoxDecoration(
              color: isOnline ? AppTheme.successLight : AppTheme.warningLight,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: 2.w),
          Text(
            isOnline ? 'Online' : 'Offline',
            style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
              color: isOnline ? AppTheme.successLight : AppTheme.warningLight,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
