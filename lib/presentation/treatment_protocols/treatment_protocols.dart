import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/antivenom_info_card.dart';
import './widgets/emergency_contact_button.dart';
import './widgets/offline_indicator.dart';
import './widgets/quick_actions_bar.dart';
import './widgets/timer_widget.dart';
import './widgets/treatment_step_card.dart';

class TreatmentProtocols extends StatefulWidget {
  const TreatmentProtocols({Key? key}) : super(key: key);

  @override
  State<TreatmentProtocols> createState() => _TreatmentProtocolsState();
}

class _TreatmentProtocolsState extends State<TreatmentProtocols>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final DateTime _biteTime =
      DateTime.now().subtract(const Duration(minutes: 15));
  bool _isOffline = false;

  // Mock treatment steps data
  final List<Map<String, dynamic>> _treatmentSteps = [
    {
      "id": 1,
      "stepNumber": 1,
      "title": "Ensure Scene Safety",
      "description":
          "Move patient and yourself to a safe location away from the snake. Do not attempt to capture or kill the snake.",
      "priority": "immediate",
      "iconName": "security",
      "isCompleted": false,
    },
    {
      "id": 2,
      "stepNumber": 2,
      "title": "Call Emergency Services",
      "description":
          "Immediately call 911 or local emergency services. Inform them of snakebite emergency and request antivenom if available.",
      "priority": "immediate",
      "iconName": "phone",
      "isCompleted": false,
    },
    {
      "id": 3,
      "stepNumber": 3,
      "title": "Keep Patient Calm",
      "description":
          "Have patient lie down and remain as still as possible. Keep bitten limb below heart level if possible.",
      "priority": "immediate",
      "iconName": "self_improvement",
      "isCompleted": false,
    },
    {
      "id": 4,
      "stepNumber": 4,
      "title": "Remove Jewelry & Clothing",
      "description":
          "Remove rings, watches, and tight clothing from affected limb before swelling begins.",
      "priority": "immediate",
      "iconName": "watch_off",
      "isCompleted": false,
    },
    {
      "id": 5,
      "stepNumber": 5,
      "title": "Clean and Cover Wound",
      "description":
          "Gently clean bite area with soap and water. Cover with clean, dry bandage. Do not apply ice or tourniquet.",
      "priority": "ongoing",
      "iconName": "healing",
      "isCompleted": false,
    },
    {
      "id": 6,
      "stepNumber": 6,
      "title": "Monitor Vital Signs",
      "description":
          "Continuously monitor breathing, pulse, and consciousness. Watch for signs of allergic reaction or shock.",
      "priority": "monitoring",
      "iconName": "monitor_heart",
      "isCompleted": false,
    },
    {
      "id": 7,
      "stepNumber": 7,
      "title": "Document Symptoms",
      "description":
          "Record time of bite, symptoms, and any changes in patient condition for medical professionals.",
      "priority": "monitoring",
      "iconName": "description",
      "isCompleted": false,
    },
  ];

  // Mock antivenom data
  final Map<String, dynamic> _antivenomData = {
    "type": "CroFab (Crotalidae Polyvalent Immune Fab)",
    "availability": "Available at Level 1 Trauma Centers",
    "administration":
        "IV infusion - 4-6 vials initial dose, additional as needed",
    "contraindications": "Known allergy to sheep proteins",
    "sideEffects": "Possible allergic reactions, serum sickness",
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _checkConnectivity();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _checkConnectivity() {
    // Mock offline status for demonstration
    setState(() {
      _isOffline = DateTime.now().millisecond % 2 == 0;
    });
  }

  void _toggleStepCompletion(int stepId) {
    setState(() {
      final stepIndex =
          _treatmentSteps.indexWhere((step) => (step['id'] as int) == stepId);
      if (stepIndex != -1) {
        _treatmentSteps[stepIndex]['isCompleted'] =
            !(_treatmentSteps[stepIndex]['isCompleted'] as bool);
      }
    });

    // Haptic feedback
    HapticFeedback.lightImpact();
  }

  void _callEmergencyServices() {
    HapticFeedback.heavyImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Calling Emergency Services...'),
        backgroundColor: AppTheme.lightTheme.colorScheme.error,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _contactHospital() {
    HapticFeedback.mediumImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Contacting nearest hospital with antivenom...'),
        backgroundColor: AppTheme.lightTheme.colorScheme.error,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _shareProtocol() {
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Sharing treatment protocol...'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _printInstructions() {
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Preparing instructions for printing...'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  Future<bool> _onWillPop() async {
    return await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(
              'Exit Treatment Protocol?',
              style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            content: Text(
              'Are you sure you want to exit? This is an emergency protocol.',
              style: AppTheme.lightTheme.textTheme.bodyMedium,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Stay'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: TextButton.styleFrom(
                  foregroundColor: AppTheme.lightTheme.colorScheme.error,
                ),
                child: const Text('Exit'),
              ),
            ],
          ),
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
        appBar: AppBar(
          title: Text(
            'Treatment Protocol',
            style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: AppTheme.lightTheme.colorScheme.surface,
          elevation: 2,
          shadowColor: AppTheme.shadowColor,
          leading: IconButton(
            onPressed: () async {
              if (await _onWillPop()) {
                Navigator.pop(context);
              }
            },
            icon: CustomIconWidget(
              iconName: 'arrow_back',
              color: AppTheme.lightTheme.colorScheme.onSurface,
              size: 20.sp,
            ),
          ),
          actions: [
            Container(
              margin: EdgeInsets.only(right: 2.w),
              padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.secondary
                    .withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color: AppTheme.lightTheme.colorScheme.secondary,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CustomIconWidget(
                    iconName: 'verified',
                    color: AppTheme.lightTheme.colorScheme.secondary,
                    size: 14.sp,
                  ),
                  SizedBox(width: 1.w),
                  Text(
                    'CERTIFIED',
                    style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                      color: AppTheme.lightTheme.colorScheme.secondary,
                      fontWeight: FontWeight.bold,
                      fontSize: 9.sp,
                    ),
                  ),
                ],
              ),
            ),
          ],
          bottom: TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: 'First Aid'),
              Tab(text: 'Antivenom'),
              Tab(text: 'Monitoring'),
            ],
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              // Offline indicator
              OfflineIndicator(isOffline: _isOffline),

              // Emergency contact button
              EmergencyContactButton(
                onPressed: _callEmergencyServices,
              ),

              // Timer widget
              TimerWidget(biteTime: _biteTime),

              // Tab content - Give it a fixed height to prevent overflow
              SizedBox(
                height: 400, // Fixed height for the tab content
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    // First Aid Tab
                    _buildFirstAidTab(),

                    // Antivenom Tab
                    _buildAntivenomTab(),

                    // Monitoring Tab
                    _buildMonitoringTab(),
                  ],
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: QuickActionsBar(
          onCallEmergency: _callEmergencyServices,
          onShareProtocol: _shareProtocol,
          onPrintInstructions: _printInstructions,
          onDone: () {
            Navigator.pushNamedAndRemoveUntil(
              context,
              '/landing-page',
              (route) => false,
            );
          },
        ),
      ),
    );
  }

  Widget _buildFirstAidTab() {
    final immediateSteps = _treatmentSteps
        .where(
            (step) => (step['priority'] as String).toLowerCase() == 'immediate')
        .toList();
    final ongoingSteps = _treatmentSteps
        .where(
            (step) => (step['priority'] as String).toLowerCase() == 'ongoing')
        .toList();

    return ListView(
      padding: EdgeInsets.only(bottom: 2.h),
      children: [
        // Immediate steps header
        Container(
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
          child: Row(
            children: [
              CustomIconWidget(
                iconName: 'emergency',
                color: AppTheme.lightTheme.colorScheme.error,
                size: 20.sp,
              ),
              SizedBox(width: 2.w),
              Text(
                'IMMEDIATE ACTIONS',
                style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.error,
                  fontWeight: FontWeight.bold,
                  fontSize: 16.sp,
                ),
              ),
            ],
          ),
        ),

        // Immediate steps
        ...immediateSteps
            .map((step) => TreatmentStepCard(
                  stepNumber: step['stepNumber'] as int,
                  title: step['title'] as String,
                  description: step['description'] as String,
                  priority: step['priority'] as String,
                  iconName: step['iconName'] as String,
                  isCompleted: step['isCompleted'] as bool,
                  onToggleComplete: () =>
                      _toggleStepCompletion(step['id'] as int),
                ))
            .toList(),

        // Ongoing care header
        Container(
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
          margin: EdgeInsets.only(top: 2.h),
          child: Row(
            children: [
              CustomIconWidget(
                iconName: 'medical_services',
                color: const Color(0xFFFF6F00),
                size: 20.sp,
              ),
              SizedBox(width: 2.w),
              Text(
                'ONGOING CARE',
                style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                  color: const Color(0xFFFF6F00),
                  fontWeight: FontWeight.bold,
                  fontSize: 16.sp,
                ),
              ),
            ],
          ),
        ),

        // Ongoing steps
        ...ongoingSteps
            .map((step) => TreatmentStepCard(
                  stepNumber: step['stepNumber'] as int,
                  title: step['title'] as String,
                  description: step['description'] as String,
                  priority: step['priority'] as String,
                  iconName: step['iconName'] as String,
                  isCompleted: step['isCompleted'] as bool,
                  onToggleComplete: () =>
                      _toggleStepCompletion(step['id'] as int),
                ))
            .toList(),
      ],
    );
  }

  Widget _buildAntivenomTab() {
    return ListView(
      padding: EdgeInsets.only(bottom: 2.h),
      children: [
        SizedBox(height: 2.h),

        // Antivenom info card
        AntivenomInfoCard(
          antivenomData: _antivenomData,
          onContactHospital: _contactHospital,
        ),

        // Additional information
        Container(
          margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
          padding: EdgeInsets.all(4.w),
          decoration: BoxDecoration(
            color:
                AppTheme.lightTheme.colorScheme.tertiary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppTheme.lightTheme.colorScheme.tertiary
                  .withValues(alpha: 0.3),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CustomIconWidget(
                    iconName: 'info',
                    color: AppTheme.lightTheme.colorScheme.tertiary,
                    size: 18.sp,
                  ),
                  SizedBox(width: 2.w),
                  Text(
                    'Important Information',
                    style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                      color: AppTheme.lightTheme.colorScheme.tertiary,
                      fontWeight: FontWeight.bold,
                      fontSize: 14.sp,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 2.h),
              Text(
                '• Antivenom is most effective when administered within 4-6 hours of bite\n'
                '• Multiple vials may be required depending on severity\n'
                '• Patient should be monitored for allergic reactions\n'
                '• Not all hospitals carry antivenom - call ahead to confirm availability',
                style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                  fontSize: 12.sp,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMonitoringTab() {
    final monitoringSteps = _treatmentSteps
        .where((step) =>
            (step['priority'] as String).toLowerCase() == 'monitoring')
        .toList();

    return ListView(
      padding: EdgeInsets.only(bottom: 2.h),
      children: [
        // Monitoring header
        Container(
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
          child: Row(
            children: [
              CustomIconWidget(
                iconName: 'monitor_heart',
                color: AppTheme.lightTheme.colorScheme.tertiary,
                size: 20.sp,
              ),
              SizedBox(width: 2.w),
              Text(
                'CONTINUOUS MONITORING',
                style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.tertiary,
                  fontWeight: FontWeight.bold,
                  fontSize: 16.sp,
                ),
              ),
            ],
          ),
        ),

        // Monitoring steps
        ...monitoringSteps
            .map((step) => TreatmentStepCard(
                  stepNumber: step['stepNumber'] as int,
                  title: step['title'] as String,
                  description: step['description'] as String,
                  priority: step['priority'] as String,
                  iconName: step['iconName'] as String,
                  isCompleted: step['isCompleted'] as bool,
                  onToggleComplete: () =>
                      _toggleStepCompletion(step['id'] as int),
                ))
            .toList(),

        // Warning signs card
        Container(
          margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
          padding: EdgeInsets.all(4.w),
          decoration: BoxDecoration(
            color: AppTheme.lightTheme.colorScheme.error.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppTheme.lightTheme.colorScheme.error,
              width: 2,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CustomIconWidget(
                    iconName: 'warning',
                    color: AppTheme.lightTheme.colorScheme.error,
                    size: 20.sp,
                  ),
                  SizedBox(width: 2.w),
                  Text(
                    'CRITICAL WARNING SIGNS',
                    style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                      color: AppTheme.lightTheme.colorScheme.error,
                      fontWeight: FontWeight.bold,
                      fontSize: 14.sp,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 2.h),
              Text(
                'Call 911 immediately if patient experiences:\n'
                '• Difficulty breathing or swallowing\n'
                '• Rapid swelling beyond bite site\n'
                '• Severe nausea, vomiting, or diarrhea\n'
                '• Dizziness, fainting, or confusion\n'
                '• Rapid or irregular heartbeat\n'
                '• Excessive bleeding or bruising',
                style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                  fontSize: 12.sp,
                  height: 1.4,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
