import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class OfflineIndicatorWidget extends StatelessWidget {
  final bool isOnline;
  final int pendingSyncCount;

  const OfflineIndicatorWidget({
    Key? key,
    required this.isOnline,
    this.pendingSyncCount = 0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (isOnline && pendingSyncCount == 0) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
      decoration: BoxDecoration(
        color: isOnline
            ? AppTheme.lightTheme.colorScheme.secondary.withValues(alpha: 0.1)
            : Colors.orange.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isOnline
              ? AppTheme.lightTheme.colorScheme.secondary
              : Colors.orange,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          CustomIconWidget(
            iconName: isOnline ? 'cloud_sync' : 'cloud_off',
            color: isOnline
                ? AppTheme.lightTheme.colorScheme.secondary
                : Colors.orange,
            size: 5.w,
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isOnline ? 'Syncing...' : 'Offline Mode',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: isOnline
                            ? AppTheme.lightTheme.colorScheme.secondary
                            : Colors.orange,
                        fontWeight: FontWeight.w600,
                      ),
                ),
                if (pendingSyncCount > 0)
                  Text(
                    '$pendingSyncCount items pending sync',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
              ],
            ),
          ),
          if (!isOnline)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
              decoration: BoxDecoration(
                color: Colors.orange,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'LOCAL',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
        ],
      ),
    );
  }
}
