import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class MessageBubbleWidget extends StatelessWidget {
  final String message;
  final bool isUser;
  final String source;
  final DateTime timestamp;
  final VoidCallback? onLongPress;

  const MessageBubbleWidget({
    Key? key,
    required this.message,
    required this.isUser,
    required this.source,
    required this.timestamp,
    this.onLongPress,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: onLongPress,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 0.5.h, horizontal: 4.w),
        child: Row(
          mainAxisAlignment:
              isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!isUser) ...[
              Container(
                width: 8.w,
                height: 8.w,
                decoration: BoxDecoration(
                  color: _getSourceColor(),
                  shape: BoxShape.circle,
                ),
                child: CustomIconWidget(
                  iconName:
                      source == 'Local Database' ? 'storage' : 'smart_toy',
                  color: Colors.white,
                  size: 4.w,
                ),
              ),
              SizedBox(width: 2.w),
            ],
            Flexible(
              child: Container(
                constraints: BoxConstraints(maxWidth: 75.w),
                padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                decoration: BoxDecoration(
                  color: _getBubbleColor(),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(isUser ? 4.w : 1.w),
                    topRight: Radius.circular(isUser ? 1.w : 4.w),
                    bottomLeft: Radius.circular(4.w),
                    bottomRight: Radius.circular(4.w),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.shadowColor,
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (!isUser) ...[
                      Text(
                        source,
                        style:
                            AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                          color: _getSourceColor(),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 0.5.h),
                    ],
                    Text(
                      message,
                      style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                        color: isUser
                            ? Colors.white
                            : AppTheme.textHighEmphasisLight,
                      ),
                    ),
                    SizedBox(height: 1.h),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _formatTime(timestamp),
                          style: AppTheme.lightTheme.textTheme.labelSmall
                              ?.copyWith(
                            color: isUser
                                ? Colors.white.withValues(alpha: 0.7)
                                : AppTheme.textMediumEmphasisLight,
                          ),
                        ),
                        if (isUser) ...[
                          SizedBox(width: 1.w),
                          CustomIconWidget(
                            iconName: 'done_all',
                            color: Colors.white.withValues(alpha: 0.7),
                            size: 3.w,
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ),
            if (isUser) ...[
              SizedBox(width: 2.w),
              Container(
                width: 8.w,
                height: 8.w,
                decoration: BoxDecoration(
                  color: AppTheme.lightTheme.primaryColor,
                  shape: BoxShape.circle,
                ),
                child: CustomIconWidget(
                  iconName: 'person',
                  color: Colors.white,
                  size: 4.w,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _getBubbleColor() {
    if (isUser) return AppTheme.lightTheme.primaryColor;
    if (source == 'Local Database')
      return AppTheme.tertiaryLight.withValues(alpha: 0.1);
    return AppTheme.secondaryLight.withValues(alpha: 0.1);
  }

  Color _getSourceColor() {
    if (source == 'Local Database') return AppTheme.tertiaryLight;
    return AppTheme.secondaryLight;
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else {
      return '${time.month}/${time.day}/${time.year}';
    }
  }
}
