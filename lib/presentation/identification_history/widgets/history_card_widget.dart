import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class HistoryCardWidget extends StatelessWidget {
  final Map<String, dynamic> identification;
  final VoidCallback? onTap;
  final VoidCallback? onViewDetails;
  final VoidCallback? onShare;
  final VoidCallback? onDelete;
  final VoidCallback? onCallPoisonControl;
  final VoidCallback? onViewTreatment;
  final VoidCallback? onReportBite;
  final bool isSelected;

  const HistoryCardWidget({
    Key? key,
    required this.identification,
    this.onTap,
    this.onViewDetails,
    this.onShare,
    this.onDelete,
    this.onCallPoisonControl,
    this.onViewTreatment,
    this.onReportBite,
    this.isSelected = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isVenomous = identification['isVenomous'] ?? false;
    final double confidence = (identification['confidence'] ?? 0.0).toDouble();
    final String speciesName =
        identification['speciesName'] ?? 'Unknown Species';
    final String imageUrl = identification['imageUrl'] ?? '';
    final String location = identification['location'] ?? 'Unknown Location';
    final DateTime timestamp = identification['timestamp'] ?? DateTime.now();

    return Dismissible(
      key: Key(identification['id'].toString()),
      background: _buildSwipeBackground(isLeft: false),
      secondaryBackground: _buildSwipeBackground(isLeft: true),
      onDismissed: (direction) {
        if (direction == DismissDirection.startToEnd) {
          // Right swipe - Quick actions
          _showQuickActions(context);
        } else {
          // Left swipe - Emergency actions
          _showEmergencyActions(context);
        }
      },
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isVenomous
                ? AppTheme.lightTheme.primaryColor
                : AppTheme.lightTheme.colorScheme.secondary,
            width: isSelected ? 3 : 2,
          ),
          boxShadow: [
            BoxShadow(
              color: AppTheme.shadowColor,
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: EdgeInsets.all(4.w),
              child: Row(
                children: [
                  // Snake thumbnail
                  Container(
                    width: 20.w,
                    height: 20.w,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Theme.of(context).dividerColor,
                        width: 1,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: imageUrl.isNotEmpty
                          ? CustomImageWidget(
                              imageUrl: imageUrl,
                              width: 20.w,
                              height: 20.w,
                              fit: BoxFit.cover,
                            )
                          : Container(
                              color: Theme.of(context).colorScheme.surface,
                              child: Center(
                                child: CustomIconWidget(
                                  iconName: 'image',
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant,
                                  size: 8.w,
                                ),
                              ),
                            ),
                    ),
                  ),
                  SizedBox(width: 4.w),

                  // Species information
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Species name and venomous indicator
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                speciesName,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 2.w, vertical: 0.5.h),
                              decoration: BoxDecoration(
                                color: isVenomous
                                    ? AppTheme.lightTheme.primaryColor
                                        .withValues(alpha: 0.1)
                                    : AppTheme.lightTheme.colorScheme.secondary
                                        .withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                isVenomous ? 'VENOMOUS' : 'NON-VENOMOUS',
                                style: Theme.of(context)
                                    .textTheme
                                    .labelSmall
                                    ?.copyWith(
                                      color: isVenomous
                                          ? AppTheme.lightTheme.primaryColor
                                          : AppTheme
                                              .lightTheme.colorScheme.secondary,
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 1.h),

                        // Confidence percentage
                        Row(
                          children: [
                            CustomIconWidget(
                              iconName: 'analytics',
                              color: Theme.of(context).colorScheme.primary,
                              size: 4.w,
                            ),
                            SizedBox(width: 2.w),
                            Text(
                              'Confidence: ${confidence.toStringAsFixed(1)}%',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.w500,
                                    color: _getConfidenceColor(confidence),
                                  ),
                            ),
                          ],
                        ),
                        SizedBox(height: 0.5.h),

                        // Location
                        Row(
                          children: [
                            CustomIconWidget(
                              iconName: 'location_on',
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                              size: 4.w,
                            ),
                            SizedBox(width: 2.w),
                            Expanded(
                              child: Text(
                                location,
                                style: Theme.of(context).textTheme.bodySmall,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 0.5.h),

                        // Timestamp
                        Row(
                          children: [
                            CustomIconWidget(
                              iconName: 'access_time',
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                              size: 4.w,
                            ),
                            SizedBox(width: 2.w),
                            Text(
                              _formatTimestamp(timestamp),
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Selection indicator
                  if (isSelected)
                    Container(
                      margin: EdgeInsets.only(left: 2.w),
                      child: CustomIconWidget(
                        iconName: 'check_circle',
                        color: AppTheme.lightTheme.colorScheme.primary,
                        size: 6.w,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSwipeBackground({required bool isLeft}) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      decoration: BoxDecoration(
        color: isLeft
            ? AppTheme.lightTheme.primaryColor.withValues(alpha: 0.1)
            : AppTheme.lightTheme.colorScheme.secondary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Align(
        alignment: isLeft ? Alignment.centerRight : Alignment.centerLeft,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 6.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CustomIconWidget(
                iconName: isLeft ? 'emergency' : 'more_horiz',
                color: isLeft
                    ? AppTheme.lightTheme.primaryColor
                    : AppTheme.lightTheme.colorScheme.secondary,
                size: 8.w,
              ),
              SizedBox(height: 1.h),
              Text(
                isLeft ? 'Emergency' : 'Actions',
                style: TextStyle(
                  color: isLeft
                      ? AppTheme.lightTheme.primaryColor
                      : AppTheme.lightTheme.colorScheme.secondary,
                  fontWeight: FontWeight.w600,
                  fontSize: 12.sp,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showQuickActions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(6.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12.w,
              height: 0.5.h,
              decoration: BoxDecoration(
                color: Theme.of(context).dividerColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            SizedBox(height: 3.h),
            Text(
              'Quick Actions',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            SizedBox(height: 3.h),
            _buildActionTile(
              context,
              icon: 'visibility',
              title: 'View Details',
              onTap: onViewDetails,
            ),
            _buildActionTile(
              context,
              icon: 'share',
              title: 'Share Results',
              onTap: onShare,
            ),
            _buildActionTile(
              context,
              icon: 'delete',
              title: 'Delete Record',
              onTap: onDelete,
              isDestructive: true,
            ),
          ],
        ),
      ),
    );
  }

  void _showEmergencyActions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(6.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12.w,
              height: 0.5.h,
              decoration: BoxDecoration(
                color: Theme.of(context).dividerColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            SizedBox(height: 3.h),
            Text(
              'Emergency Actions',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppTheme.lightTheme.primaryColor,
                  ),
            ),
            SizedBox(height: 3.h),
            _buildActionTile(
              context,
              icon: 'phone',
              title: 'Call Poison Control',
              onTap: onCallPoisonControl,
              isEmergency: true,
            ),
            _buildActionTile(
              context,
              icon: 'medical_services',
              title: 'View Treatment',
              onTap: onViewTreatment,
              isEmergency: true,
            ),
            _buildActionTile(
              context,
              icon: 'report',
              title: 'Report Bite',
              onTap: onReportBite,
              isEmergency: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionTile(
    BuildContext context, {
    required String icon,
    required String title,
    VoidCallback? onTap,
    bool isDestructive = false,
    bool isEmergency = false,
  }) {
    Color color = Theme.of(context).colorScheme.onSurface;
    if (isDestructive) color = AppTheme.lightTheme.colorScheme.error;
    if (isEmergency) color = AppTheme.lightTheme.primaryColor;

    return ListTile(
      leading: CustomIconWidget(
        iconName: icon,
        color: color,
        size: 6.w,
      ),
      title: Text(
        title,
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: color,
              fontWeight: isEmergency ? FontWeight.w600 : FontWeight.w400,
            ),
      ),
      onTap: () {
        Navigator.pop(context);
        onTap?.call();
      },
    );
  }

  Color _getConfidenceColor(double confidence) {
    if (confidence >= 90) return AppTheme.lightTheme.colorScheme.secondary;
    if (confidence >= 70) return Colors.orange;
    return AppTheme.lightTheme.colorScheme.error;
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}
