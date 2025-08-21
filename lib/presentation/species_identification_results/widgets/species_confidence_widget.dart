import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class SpeciesConfidenceWidget extends StatelessWidget {
  final double confidence;
  final bool isVenomous;

  const SpeciesConfidenceWidget({
    Key? key,
    required this.confidence,
    required this.isVenomous,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Color confidenceColor = _getConfidenceColor();
    final String confidenceText = _getConfidenceText();

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(4.w),
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: confidenceColor.withValues(alpha: 0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.shadowColor,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Confidence Level',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                decoration: BoxDecoration(
                  color: confidenceColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: confidenceColor,
                    width: 1,
                  ),
                ),
                child: Text(
                  '${confidence.toStringAsFixed(1)}%',
                  style: AppTheme.confidenceStyle(
                    isLight: Theme.of(context).brightness == Brightness.light,
                  ).copyWith(
                    color: confidenceColor,
                    fontSize: 14.sp,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          Container(
            width: double.infinity,
            height: 1.h,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color:
                  Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: confidence / 100,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  gradient: LinearGradient(
                    colors: [
                      confidenceColor.withValues(alpha: 0.7),
                      confidenceColor,
                    ],
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: 1.h),
          Row(
            children: [
              CustomIconWidget(
                iconName: confidence >= 85
                    ? 'check_circle'
                    : confidence >= 70
                        ? 'info'
                        : 'warning',
                color: confidenceColor,
                size: 16,
              ),
              SizedBox(width: 2.w),
              Expanded(
                child: Text(
                  confidenceText,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: confidenceColor,
                        fontWeight: FontWeight.w500,
                      ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getConfidenceColor() {
    if (confidence >= 85) {
      return isVenomous
          ? AppTheme.lightTheme.primaryColor
          : AppTheme.lightTheme.colorScheme.secondary;
    } else if (confidence >= 70) {
      return const Color(0xFFFF9800); // Orange for medium confidence
    } else {
      return AppTheme.lightTheme.colorScheme.error;
    }
  }

  String _getConfidenceText() {
    if (confidence >= 85) {
      return 'High confidence - Reliable identification';
    } else if (confidence >= 70) {
      return 'Medium confidence - Consider alternatives';
    } else {
      return 'Low confidence - Seek expert verification';
    }
  }
}
