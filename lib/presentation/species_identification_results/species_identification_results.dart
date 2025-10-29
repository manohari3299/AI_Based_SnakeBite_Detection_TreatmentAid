import 'dart:io';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../services/history_service.dart';
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
  String? _imagePath;

  // Default/mock identification results data (used as fallback)
  Map<String, dynamic> _identificationResult = {
    "id": 1,
    "commonName": "Unknown Species",
    "scientificName": "Processing...",
    "family": "Unknown",
    "subfamily": "Unknown",
    "genus": "Unknown",
    "venomous": false,
    "confidence": 0.0,
    "distribution": "Data not available",
    "characteristics": "Analyzing image...",
    "habitat": "Data not available",
    "warningMessage": "Unable to identify species from image",
    "imageUrl": "",
  };

  List<Map<String, dynamic>> _alternativeSpecies = [];

  @override
  void initState() {
    super.initState();
    _checkConnectivity();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    
    // Only process arguments once
    if (_imagePath == null) {
      // Get navigation arguments
      final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      
      if (args != null) {
        debugPrint('Received arguments: ${args.keys}');
        
        final imagePath = args['imagePath'] as String?;
        final apiResult = args['apiResult'] as Map<String, dynamic>?;
        
        debugPrint('Image path: $imagePath');
        debugPrint('API result: $apiResult');
        
        if (imagePath != null) {
          setState(() {
            _imagePath = imagePath;
          });
        }
        
        // Process API result if available
        if (apiResult != null) {
          _processApiResult(apiResult);
        }
      } else {
        debugPrint('No arguments received');
      }
    }
  }

  void _processApiResult(Map<String, dynamic> apiResult) {
    setState(() {
      // API returns: {pred_class, confidence, metadata, treatment_info}
      final confidence = (apiResult['confidence'] ?? 0.0) as double;
      final metadata = apiResult['metadata'] as Map<String, dynamic>?;
      
      if (metadata != null) {
        _identificationResult = {
          "id": apiResult['pred_class'] ?? 0,
          "commonName": metadata['common_name'] ?? metadata['binomial_name'] ?? 'Unknown Species',
          "scientificName": metadata['binomial_name'] ?? metadata['scientific_name'] ?? 'Unknown',
          "family": metadata['family'] ?? 'Unknown',
          "subfamily": metadata['subfamily'] ?? 'Unknown',
          "genus": metadata['genus'] ?? 'Unknown',
          "venomous": metadata['venomous']?.toString().toLowerCase() == 'true' || 
                      metadata['venomous']?.toString() == '1' ||
                      metadata['venomous'] == true,
          "confidence": confidence * 100,
          "distribution": metadata['distribution'] ?? metadata['geographic_range'] ?? 'Data not available',
          "characteristics": metadata['characteristics'] ?? metadata['description'] ?? 'No description available',
          "habitat": metadata['habitat'] ?? 'Data not available',
          "warningMessage": metadata['warning_message'] ?? (
            (metadata['venomous']?.toString().toLowerCase() == 'true' || metadata['venomous'] == true)
                ? 'This species is venomous - seek immediate medical attention if bitten'
                : 'This species is non-venomous'
          ),
          "imageUrl": _imagePath ?? '',
        };
        
        // No alternative predictions in this API response format
        // The API returns single prediction, not a list
        _alternativeSpecies = [];
      } else {
        // Fallback if no metadata
        _identificationResult = {
          "id": apiResult['pred_class'] ?? 0,
          "commonName": "Species ID: ${apiResult['pred_class']}",
          "scientificName": "Unknown",
          "family": "Unknown",
          "subfamily": "Unknown",
          "genus": "Unknown",
          "venomous": false,
          "confidence": confidence * 100,
          "distribution": "Data not available",
          "characteristics": "Species identified but detailed information not available",
          "habitat": "Data not available",
          "warningMessage": "Unable to retrieve species details",
          "imageUrl": _imagePath ?? '',
        };
        _alternativeSpecies = [];
      }
    });
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

  Future<void> _saveToHistory() async {
    // Prepare identification data for history
    final historyData = {
      'speciesName': _identificationResult['commonName'],
      'scientificName': _identificationResult['scientificName'],
      'isVenomous': _identificationResult['venomous'] ?? false,
      'confidence': _identificationResult['confidence'],
      'imageUrl': _imagePath ?? '',
      'location': 'Unknown', // You can add location detection later
      'family': _identificationResult['family'],
      'treatment': _identificationResult['venomous'] == true 
          ? 'Immediate medical attention required' 
          : 'No medical treatment needed',
    };
    
    // Save to history service
    await HistoryService().saveIdentification(historyData);
    
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
                            // Display local file image if available, otherwise use network image
                            Builder(
                              builder: (context) {
                                debugPrint('Building image widget. Path: $_imagePath');
                                
                                if (_imagePath != null && _imagePath!.isNotEmpty) {
                                  final file = File(_imagePath!);
                                  final exists = file.existsSync();
                                  debugPrint('File exists: $exists');
                                  
                                  return Image.file(
                                    file,
                                    width: double.infinity,
                                    height: double.infinity,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      debugPrint('Image error: $error');
                                      return Container(
                                        color: Colors.grey[300],
                                        child: Center(
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                Icons.broken_image,
                                                size: 50,
                                                color: Colors.grey[600],
                                              ),
                                              SizedBox(height: 8),
                                              Text(
                                                'Failed to load image',
                                                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                                              ),
                                              Padding(
                                                padding: EdgeInsets.all(8),
                                                child: Text(
                                                  error.toString(),
                                                  style: TextStyle(fontSize: 10, color: Colors.red),
                                                  textAlign: TextAlign.center,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  );
                                } else if (_identificationResult['imageUrl'] != null &&
                                    _identificationResult['imageUrl'].toString().isNotEmpty) {
                                  debugPrint('Using network image: ${_identificationResult['imageUrl']}');
                                  return CustomImageWidget(
                                    imageUrl: _identificationResult['imageUrl'] ?? '',
                                    width: double.infinity,
                                    height: double.infinity,
                                    fit: BoxFit.cover,
                                  );
                                } else {
                                  debugPrint('No image available');
                                  return Container(
                                    color: Colors.grey[300],
                                    child: Center(
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.image_not_supported,
                                            size: 50,
                                            color: Colors.grey[600],
                                          ),
                                          SizedBox(height: 8),
                                          Text(
                                            'No image available',
                                            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }
                              },
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

                          SizedBox(height: 2.h),

                          // Done Button
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: () {
                                Navigator.pushNamedAndRemoveUntil(
                                  context,
                                  '/home-dashboard',
                                  (route) => false,
                                );
                              },
                              icon: CustomIconWidget(
                                iconName: 'check_circle',
                                color: AppTheme.lightTheme.colorScheme.secondary,
                                size: 18,
                              ),
                              label: Text(
                                'Done',
                                style: Theme.of(context)
                                    .textTheme
                                    .labelLarge
                                    ?.copyWith(
                                      color: AppTheme.lightTheme.colorScheme.secondary,
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                              style: OutlinedButton.styleFrom(
                                padding: EdgeInsets.symmetric(vertical: 2.h),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                side: BorderSide(
                                  color: AppTheme.lightTheme.colorScheme.secondary,
                                  width: 1.5,
                                ),
                              ),
                            ),
                          ),

                          SizedBox(height: 4.h),
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
