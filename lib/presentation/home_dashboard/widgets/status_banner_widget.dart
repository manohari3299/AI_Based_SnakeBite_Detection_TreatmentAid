import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class StatusBannerWidget extends StatelessWidget {
  final bool isOnline;
  final String lastUpdate;
  final String modelVersion;

  const StatusBannerWidget({
    Key? key,
    required this.isOnline,
    required this.lastUpdate,
    required this.modelVersion,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return isOnline
        ? const SizedBox.shrink()
        : Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
            margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.errorContainer,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: AppTheme.lightTheme.colorScheme.error,
                width: 1,
              ),
            ),
            child: Row(
              children: [
                CustomIconWidget(
                  iconName: 'cloud_off',
                  color: AppTheme.lightTheme.colorScheme.error,
                  size: 5.w,
                ),
                SizedBox(width: 3.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Offline Mode Active',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              color: AppTheme.lightTheme.colorScheme.error,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      SizedBox(height: 0.5.h),
                      Text(
                        'Last update: $lastUpdate • Model v$modelVersion',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppTheme.lightTheme.colorScheme.error,
                            ),
                      ),
                    ],
                  ),
                ),
                CustomIconWidget(
                  iconName: 'sync',
                  color: AppTheme.lightTheme.colorScheme.error,
                  size: 5.w,
                ),
              ],
            ),
          );
  }
}
