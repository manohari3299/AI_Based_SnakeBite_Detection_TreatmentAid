import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({Key? key}) : super(key: key);

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _navigateToCamera() {
    Navigator.pushNamed(context, '/camera-capture');
  }

  void _navigateToChatAssistant() {
    Navigator.pushNamed(context, '/chat-assistant');
  }

  void _navigateToHistory() {
    Navigator.pushNamed(context, '/identification-history');
  }

  void _navigateToTreatmentProtocols() {
    Navigator.pushNamed(context, '/treatment-protocols');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 3.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: 2.h),

                    // App Logo and Title
                    _buildHeader(),

                    SizedBox(height: 4.h),

                    // Emergency Notice
                    _buildEmergencyNotice(),

                    SizedBox(height: 5.h),

                    // Main Action: Camera Button (Large)
                    _buildCameraButton(),

                    SizedBox(height: 3.h),

                    // Secondary Action: AI Assistant Button
                    _buildAIAssistantButton(),

                    SizedBox(height: 4.h),

                    // Quick Access Section
                    _buildQuickAccessSection(),

                    SizedBox(height: 3.h),

                    // Info Section
                    _buildInfoSection(),

                    SizedBox(height: 2.h),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        // App Icon/Logo
        Container(
          width: 20.w,
          height: 20.w,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppTheme.lightTheme.colorScheme.primary,
                AppTheme.lightTheme.colorScheme.secondary,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.3),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: CustomIconWidget(
            iconName: 'medical_services',
            color: Colors.white,
            size: 10.w,
          ),
        ),
        SizedBox(height: 2.h),
        Text(
          'SnakeBite AI',
          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppTheme.lightTheme.colorScheme.primary,
              ),
        ),
        SizedBox(height: 0.5.h),
        Text(
          'Emergency Snake Identification & Treatment Aid',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.textMediumEmphasisLight,
              ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildEmergencyNotice() {
    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(3.w),
        border: Border.all(
          color: AppTheme.lightTheme.colorScheme.error,
          width: 2,
        ),
      ),
      child: Row(
        children: [
          CustomIconWidget(
            iconName: 'warning',
            color: AppTheme.lightTheme.colorScheme.error,
            size: 6.w,
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'MEDICAL EMERGENCY?',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.lightTheme.colorScheme.error,
                      ),
                ),
                SizedBox(height: 0.5.h),
                Text(
                  'Call 911 or your local emergency number first!',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.lightTheme.colorScheme.onErrorContainer,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCameraButton() {
    return InkWell(
      onTap: _navigateToCamera,
      borderRadius: BorderRadius.circular(4.w),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 4.h),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppTheme.lightTheme.colorScheme.primary,
              AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.8),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(4.w),
          boxShadow: [
            BoxShadow(
              color: AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.4),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(4.w),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: CustomIconWidget(
                iconName: 'camera_alt',
                color: Colors.white,
                size: 15.w,
              ),
            ),
            SizedBox(height: 2.h),
            Text(
              'CAPTURE SNAKE',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 1.2,
                  ),
            ),
            SizedBox(height: 1.h),
            Text(
              'Take a photo to identify snake species',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAIAssistantButton() {
    return InkWell(
      onTap: _navigateToChatAssistant,
      borderRadius: BorderRadius.circular(4.w),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 3.h),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppTheme.lightTheme.colorScheme.secondary,
              AppTheme.lightTheme.colorScheme.secondary.withValues(alpha: 0.8),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(4.w),
          boxShadow: [
            BoxShadow(
              color: AppTheme.lightTheme.colorScheme.secondary.withValues(alpha: 0.4),
              blurRadius: 15,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(2.w),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: CustomIconWidget(
                iconName: 'chat',
                color: Colors.white,
                size: 8.w,
              ),
            ),
            SizedBox(width: 4.w),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'AI ASSISTANT',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 1.0,
                      ),
                ),
                SizedBox(height: 0.5.h),
                Text(
                  'Get instant medical guidance',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickAccessSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 2.w),
          child: Text(
            'Quick Access',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),
        SizedBox(height: 2.h),
        Row(
          children: [
            Expanded(
              child: _buildQuickAccessCard(
                title: 'History',
                icon: 'history',
                color: AppTheme.lightTheme.colorScheme.tertiary,
                onTap: _navigateToHistory,
              ),
            ),
            SizedBox(width: 3.w),
            Expanded(
              child: _buildQuickAccessCard(
                title: 'Treatment',
                icon: 'healing',
                color: AppTheme.lightTheme.colorScheme.tertiary,
                onTap: _navigateToTreatmentProtocols,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickAccessCard({
    required String title,
    required String icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(3.w),
      child: Container(
        padding: EdgeInsets.all(4.w),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(3.w),
          border: Border.all(
            color: color.withValues(alpha: 0.3),
            width: 1.5,
          ),
        ),
        child: Column(
          children: [
            CustomIconWidget(
              iconName: icon,
              color: color,
              size: 10.w,
            ),
            SizedBox(height: 1.5.h),
            Text(
              title,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSection() {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(3.w),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CustomIconWidget(
                iconName: 'info',
                color: AppTheme.lightTheme.colorScheme.primary,
                size: 5.w,
              ),
              SizedBox(width: 2.w),
              Text(
                'How It Works',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          _buildInfoStep('1', 'Capture a photo of the snake or bite mark'),
          SizedBox(height: 1.h),
          _buildInfoStep('2', 'AI identifies the snake species instantly'),
          SizedBox(height: 1.h),
          _buildInfoStep('3', 'Get treatment protocols and first aid steps'),
          SizedBox(height: 1.h),
          _buildInfoStep('4', 'Chat with AI for additional guidance'),
        ],
      ),
    );
  }

  Widget _buildInfoStep(String number, String text) {
    return Row(
      children: [
        Container(
          width: 6.w,
          height: 6.w,
          decoration: BoxDecoration(
            color: AppTheme.lightTheme.colorScheme.primary,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              number,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
        ),
        SizedBox(width: 3.w),
        Expanded(
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.textMediumEmphasisLight,
                ),
          ),
        ),
      ],
    );
  }
}
