import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class SpeciesInfoCardWidget extends StatelessWidget {
  final Map<String, dynamic> speciesData;

  const SpeciesInfoCardWidget({
    Key? key,
    required this.speciesData,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isVenomous = speciesData['venomous'] ?? false;
    final Color statusColor = isVenomous
        ? AppTheme.lightTheme.primaryColor
        : AppTheme.lightTheme.colorScheme.secondary;

    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.shadowColor,
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status Banner
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
              border: Border(
                bottom: BorderSide(
                  color: statusColor.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                CustomIconWidget(
                  iconName: isVenomous ? 'dangerous' : 'verified',
                  color: statusColor,
                  size: 24,
                ),
                SizedBox(width: 3.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isVenomous
                            ? 'VENOMOUS SPECIES'
                            : 'NON-VENOMOUS SPECIES',
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                              color: statusColor,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.2,
                            ),
                      ),
                      SizedBox(height: 0.5.h),
                      Text(
                        isVenomous
                            ? 'Immediate medical attention required'
                            : 'Generally harmless to humans',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: statusColor.withValues(alpha: 0.8),
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Species Information
          Padding(
            padding: EdgeInsets.all(4.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Common Name
                Text(
                  speciesData['commonName'] ?? 'Unknown Species',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                ),
                SizedBox(height: 1.h),

                // Scientific Name
                Text(
                  speciesData['scientificName'] ?? 'Species unknown',
                  style: AppTheme.scientificNameStyle(
                    isLight: Theme.of(context).brightness == Brightness.light,
                  ).copyWith(
                    fontSize: 14.sp,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                SizedBox(height: 2.h),

                // Classification Details
                _buildInfoRow(
                  context,
                  'Family',
                  speciesData['family'] ?? 'Unknown',
                  'family_restroom',
                ),
                SizedBox(height: 1.h),
                _buildInfoRow(
                  context,
                  'Subfamily',
                  speciesData['subfamily'] ?? 'Unknown',
                  'category',
                ),
                SizedBox(height: 1.h),
                _buildInfoRow(
                  context,
                  'Genus',
                  speciesData['genus'] ?? 'Unknown',
                  'science',
                ),
                SizedBox(height: 2.h),

                // Geographic Distribution
                if (speciesData['distribution'] != null) ...[
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomIconWidget(
                        iconName: 'public',
                        color: Theme.of(context).colorScheme.primary,
                        size: 20,
                      ),
                      SizedBox(width: 3.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Geographic Distribution',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall
                                  ?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                            SizedBox(height: 0.5.h),
                            Text(
                              speciesData['distribution'],
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 2.h),
                ],

                // Physical Characteristics
                if (speciesData['characteristics'] != null) ...[
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomIconWidget(
                        iconName: 'visibility',
                        color: Theme.of(context).colorScheme.primary,
                        size: 20,
                      ),
                      SizedBox(width: 3.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Key Characteristics',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall
                                  ?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                            SizedBox(height: 0.5.h),
                            Text(
                              speciesData['characteristics'],
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
      BuildContext context, String label, String value, String iconName) {
    return Row(
      children: [
        CustomIconWidget(
          iconName: iconName,
          color: Theme.of(context).colorScheme.primary,
          size: 18,
        ),
        SizedBox(width: 3.w),
        Text(
          '$label: ',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        Expanded(
          child: Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      ],
    );
  }
}
