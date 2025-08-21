import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/alternative_species_widget.dart';
import './widgets/emergency_warning_widget.dart';
import './widgets/species_confidence_widget.dart';
import './widgets/species_info_card_widget.dart';

class SpeciesIdentificationResults extends StatefulWidget {
  const SpeciesIdentificationResults({Key? key}) : super(key: key);

  @override
  State<SpeciesIdentificationResults> createState() =>
      _SpeciesIdentificationResultsState();
}

class _SpeciesIdentificationResultsState
    extends State<SpeciesIdentificationResults> {
  bool _isOfflineMode = false;
  bool _isLoading = false;

  // Mock identification results data
  final Map<String, dynamic> _identificationResult = {
    "id": 1,
    "commonName": "Eastern Diamondback Rattlesnake",
    "scientificName": "Crotalus adamanteus",
    "family": "Viperidae",
    "subfamily": "Crotalinae",
    "genus": "Crotalus",
    "venomous": true,
    "confidence": 87.5,
    "distribution":
        "Southeastern United States, from North Carolina to Florida and west to Louisiana",
    "characteristics":
        "Large, heavy-bodied snake with distinctive diamond-shaped patterns along the back. Gray to brown coloration with dark diamond patterns outlined in white or yellow. Prominent rattle at tail end.",
    "habitat":
        "Pine forests, coastal plains, scrublands, and palmetto thickets",
    "warningMessage":
        "Extremely dangerous - possesses potent hemotoxic venom that can cause severe tissue damage and death",
    "imageUrl":
        "https://images.pexels.com/photos/33535/snake-rainbow-boa-reptile-scale.jpg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1",
  };

  final List<Map<String, dynamic>> _alternativeSpecies = [
    {
      "id": 2,
      "commonName": "Timber Rattlesnake",
      "scientificName": "Crotalus horridus",
      "family": "Viperidae",
      "subfamily": "Crotalinae",
      "genus": "Crotalus",
      "venomous": true,
      "confidence": 72.3,
      "distribution": "Eastern United States",
      "characteristics": "Yellow to brown with dark crossbands",
    },
    {
      "id": 3,
      "commonName": "Eastern Hognose Snake",
      "scientificName": "Heterodon platirhinos",
      "family": "Colubridae",
      "subfamily": "Xenodontinae",
      "genus": "Heterodon",
      "venomous": false,
      "confidence": 68.1,
      "distribution": "Eastern North America",
      "characteristics": "Upturned snout, variable coloration with blotches",
    },
    {
      "id": 4,
      "commonName": "Pine Snake",
      "scientificName": "Pituophis melanoleucus",
      "family": "Colubridae",
      "subfamily": "Colubrinae",
      "genus": "Pituophis",
      "venomous": false,
      "confidence": 61.7,
      "distribution": "Eastern United States",
      "characteristics": "Large, powerful constrictor with keeled scales",
    },
  ];

  @override
  void initState() {
    super.initState();
    _checkConnectivity();
  }

  Future<void> _checkConnectivity() async {
    // Simulate connectivity check
    await Future.delayed(const Duration(milliseconds: 500));
    setState(() {
      _isOfflineMode = false; // Simulating online mode
    });
  }

  Future<void> _refreshAnalysis() async {
    setState(() {
      _isLoading = true;
    });

    // Simulate re-analysis
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _isLoading = false;
    });
  }

  void _onAlternativeSpeciesSelected(Map<String, dynamic> species) {
    // Update the main result with selected alternative
    setState(() {
      _identificationResult.addAll(species);
    });
  }

  void _shareResults() {
    // Share functionality would be implemented here
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Sharing identification results...'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  void _saveToHistory() {
    // Save to history functionality would be implemented here
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Saved to identification history'),
        backgroundColor: AppTheme.lightTheme.colorScheme.secondary,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isVenomous = _identificationResult['venomous'] ?? false;
    final double confidence =
        (_identificationResult['confidence'] ?? 0.0).toDouble();
    final bool showAlternatives = confidence < 85;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: 1,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: CustomIconWidget(
            iconName: 'arrow_back',
            color: Theme.of(context).colorScheme.onSurface,
            size: 24,
          ),
        ),
        title: Text(
          'Identification Results',
          style: Theme.of(context).appBarTheme.titleTextStyle,
        ),
        actions: [
          if (_isOfflineMode)
            Container(
              margin: EdgeInsets.only(right: 2.w),
              padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.h),
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.secondary
                    .withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CustomIconWidget(
                    iconName: 'offline_bolt',
                    color: AppTheme.lightTheme.colorScheme.secondary,
                    size: 16,
                  ),
                  SizedBox(width: 1.w),
                  Text(
                    'Offline',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: AppTheme.lightTheme.colorScheme.secondary,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ],
              ),
            ),
          IconButton(
            onPressed: _shareResults,
            icon: CustomIconWidget(
              iconName: 'share',
              color: Theme.of(context).colorScheme.onSurface,
              size: 24,
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshAnalysis,
        color: Theme.of(context).colorScheme.primary,
        child: _isLoading
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      'Re-analyzing image...',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                  ],
                ),
              )
            : SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 2.h),

                    // Hero Image Section
                    Container(
                      width: double.infinity,
                      height: 30.h,
                      margin: EdgeInsets.symmetric(horizontal: 4.w),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.shadowColor,
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Stack(
                          children: [
                            CustomImageWidget(
                              imageUrl: _identificationResult['imageUrl'] ?? '',
                              width: double.infinity,
                              height: double.infinity,
                              fit: BoxFit.cover,
                            ),
                            // Confidence badge overlay
                            Positioned(
                              top: 2.h,
                              right: 4.w,
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 3.w, vertical: 1.h),
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.7),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  '${confidence.toStringAsFixed(1)}%',
                                  style: AppTheme.confidenceStyle(
                                    isLight: true,
                                  ).copyWith(
                                    color: Colors.white,
                                    fontSize: 14.sp,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(height: 2.h),

                    // Emergency Warning (if venomous)
                    EmergencyWarningWidget(
                      isVenomous: isVenomous,
                      warningMessage: _identificationResult['warningMessage'],
                    ),

                    // Confidence Level
                    SpeciesConfidenceWidget(
                      confidence: confidence,
                      isVenomous: isVenomous,
                    ),

                    // Species Information Card
                    SpeciesInfoCardWidget(
                      speciesData: _identificationResult,
                    ),

                    // Alternative Species (if confidence < 85%)
                    if (showAlternatives)
                      AlternativeSpeciesWidget(
                        alternativeSpecies: _alternativeSpecies,
                        onSpeciesSelected: _onAlternativeSpeciesSelected,
                      ),

                    SizedBox(height: 3.h),

                    // Bottom Action Buttons
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 4.w),
                      child: Column(
                        children: [
                          // Primary Action Button
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: () {
                                Navigator.pushNamed(
                                    context, '/treatment-protocols');
                              },
                              icon: CustomIconWidget(
                                iconName: 'medical_services',
                                color: Colors.white,
                                size: 20,
                              ),
                              label: Text(
                                isVenomous
                                    ? 'VIEW EMERGENCY TREATMENT'
                                    : 'VIEW TREATMENT INFO',
                                style: Theme.of(context)
                                    .textTheme
                                    .labelLarge
                                    ?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                    ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: isVenomous
                                    ? AppTheme.lightTheme.primaryColor
                                    : AppTheme.lightTheme.colorScheme.secondary,
                                padding: EdgeInsets.symmetric(vertical: 2.5.h),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),

                          SizedBox(height: 2.h),

                          // Secondary Actions Row
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: _saveToHistory,
                                  icon: CustomIconWidget(
                                    iconName: 'bookmark',
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                    size: 18,
                                  ),
                                  label: Text(
                                    'Save to History',
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelMedium
                                        ?.copyWith(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary,
                                          fontWeight: FontWeight.w600,
                                        ),
                                  ),
                                  style: OutlinedButton.styleFrom(
                                    padding:
                                        EdgeInsets.symmetric(vertical: 2.h),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(width: 3.w),
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: () {
                                    Navigator.pushNamed(
                                        context, '/chat-assistant');
                                  },
                                  icon: CustomIconWidget(
                                    iconName: 'chat',
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                    size: 18,
                                  ),
                                  label: Text(
                                    'Ask Assistant',
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelMedium
                                        ?.copyWith(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary,
                                          fontWeight: FontWeight.w600,
                                        ),
                                  ),
                                  style: OutlinedButton.styleFrom(
                                    padding:
                                        EdgeInsets.symmetric(vertical: 2.h),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 4.h),
                  ],
                ),
              ),
      ),
    );
  }
}
