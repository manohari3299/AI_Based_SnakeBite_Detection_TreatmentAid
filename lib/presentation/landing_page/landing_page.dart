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
    // Check if we're on web/desktop with wider screen
    final isWideScreen = MediaQuery.of(context).size.width > 900;
    final maxWidth = isWideScreen ? 1200.0 : double.infinity;
    
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: Center(
              child: Container(
                constraints: BoxConstraints(maxWidth: maxWidth),
                child: SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: isWideScreen ? 48 : 6.w,
                      vertical: isWideScreen ? 40 : 3.h,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(height: isWideScreen ? 20 : 2.h),

                        // App Logo and Title
                        _buildHeader(isWideScreen),

                        SizedBox(height: isWideScreen ? 32 : 4.h),

                        // Emergency Notice
                        _buildEmergencyNotice(isWideScreen),

                        SizedBox(height: isWideScreen ? 40 : 5.h),

                        // Main Content Grid (for wide screens)
                        if (isWideScreen)
                          _buildWideScreenLayout()
                        else
                          _buildMobileLayout(),

                        SizedBox(height: isWideScreen ? 40 : 2.h),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWideScreenLayout() {
    return Column(
      children: [
        // Main actions in a grid
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: _buildCameraButton(true),
            ),
            const SizedBox(width: 24),
            Expanded(
              flex: 2,
              child: Column(
                children: [
                  _buildAIAssistantButton(true),
                  const SizedBox(height: 24),
                  _buildQuickAccessSection(true),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 40),
        _buildInfoSection(true),
      ],
    );
  }

  Widget _buildMobileLayout() {
    return Column(
      children: [
        _buildCameraButton(false),
        SizedBox(height: 3.h),
        _buildAIAssistantButton(false),
        SizedBox(height: 4.h),
        _buildQuickAccessSection(false),
        SizedBox(height: 3.h),
        _buildInfoSection(false),
      ],
    );
  }

  Widget _buildHeader([bool isWideScreen = false]) {
    final iconSize = isWideScreen ? 100.0 : 20.w;
    final iconInnerSize = isWideScreen ? 50.0 : 10.w;
    
    return Column(
      children: [
        // App Icon/Logo
        Container(
          width: iconSize,
          height: iconSize,
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
            size: iconInnerSize,
          ),
        ),
        SizedBox(height: isWideScreen ? 16 : 2.h),
        Text(
          'SnakeBite AI',
          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppTheme.lightTheme.colorScheme.primary,
                fontSize: isWideScreen ? 48 : null,
              ),
        ),
        SizedBox(height: isWideScreen ? 8 : 0.5.h),
        Text(
          'Emergency Snake Identification & Treatment Aid',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.textMediumEmphasisLight,
                fontSize: isWideScreen ? 18 : null,
              ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildEmergencyNotice([bool isWideScreen = false]) {
    final padding = isWideScreen ? 24.0 : 3.w;
    final iconSize = isWideScreen ? 32.0 : 6.w;
    final spacing = isWideScreen ? 16.0 : 3.w;
    
    return Container(
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(isWideScreen ? 16 : 3.w),
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
            size: iconSize,
          ),
          SizedBox(width: spacing),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'MEDICAL EMERGENCY?',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.lightTheme.colorScheme.error,
                        fontSize: isWideScreen ? 16 : null,
                      ),
                ),
                SizedBox(height: isWideScreen ? 4 : 0.5.h),
                Text(
                  'Call 911 or your local emergency number first!',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.lightTheme.colorScheme.onErrorContainer,
                        fontSize: isWideScreen ? 14 : null,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCameraButton([bool isWideScreen = false]) {
    final borderRadius = isWideScreen ? 24.0 : 4.w;
    final verticalPadding = isWideScreen ? 60.0 : 4.h;
    final iconPadding = isWideScreen ? 24.0 : 4.w;
    final iconSize = isWideScreen ? 80.0 : 15.w;
    
    return InkWell(
      onTap: _navigateToCamera,
      borderRadius: BorderRadius.circular(borderRadius),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: verticalPadding),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppTheme.lightTheme.colorScheme.primary,
              AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.8),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(borderRadius),
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
              padding: EdgeInsets.all(iconPadding),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: CustomIconWidget(
                iconName: 'camera_alt',
                color: Colors.white,
                size: iconSize,
              ),
            ),
            SizedBox(height: isWideScreen ? 16 : 2.h),
            Text(
              'CAPTURE SNAKE',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 1.2,
                    fontSize: isWideScreen ? 28 : null,
                  ),
            ),
            SizedBox(height: isWideScreen ? 8 : 1.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: isWideScreen ? 32 : 4.w),
              child: Text(
                'Take a photo of snake species or snake bite mark',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontSize: isWideScreen ? 16 : null,
                    ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAIAssistantButton([bool isWideScreen = false]) {
    final borderRadius = isWideScreen ? 20.0 : 4.w;
    final verticalPadding = isWideScreen ? 32.0 : 3.h;
    final iconPadding = isWideScreen ? 16.0 : 2.w;
    final iconSize = isWideScreen ? 40.0 : 8.w;
    final spacing = isWideScreen ? 16.0 : 4.w;
    
    return InkWell(
      onTap: _navigateToChatAssistant,
      borderRadius: BorderRadius.circular(borderRadius),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: verticalPadding),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppTheme.lightTheme.colorScheme.secondary,
              AppTheme.lightTheme.colorScheme.secondary.withValues(alpha: 0.8),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(borderRadius),
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
              padding: EdgeInsets.all(iconPadding),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: CustomIconWidget(
                iconName: 'chat',
                color: Colors.white,
                size: iconSize,
              ),
            ),
            SizedBox(width: spacing),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'AI ASSISTANT',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 1.0,
                          fontSize: isWideScreen ? 22 : null,
                        ),
                  ),
                  SizedBox(height: isWideScreen ? 4 : 0.5.h),
                  Text(
                    'Get instant medical guidance',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontSize: isWideScreen ? 14 : null,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickAccessSection([bool isWideScreen = false]) {
    final horizontalPadding = isWideScreen ? 16.0 : 2.w;
    final spacing = isWideScreen ? 16.0 : 3.w;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!isWideScreen)
          Padding(
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
            child: Text(
              'Quick Access',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
        SizedBox(height: isWideScreen ? 0 : 2.h),
        Row(
          children: [
            Expanded(
              child: _buildQuickAccessCard(
                title: 'History',
                icon: 'history',
                color: AppTheme.lightTheme.colorScheme.tertiary,
                onTap: _navigateToHistory,
                isWideScreen: isWideScreen,
              ),
            ),
            SizedBox(width: spacing),
            Expanded(
              child: _buildQuickAccessCard(
                title: 'Treatment',
                icon: 'healing',
                color: AppTheme.lightTheme.colorScheme.tertiary,
                onTap: _navigateToTreatmentProtocols,
                isWideScreen: isWideScreen,
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
    bool isWideScreen = false,
  }) {
    final borderRadius = isWideScreen ? 16.0 : 3.w;
    final padding = isWideScreen ? 24.0 : 4.w;
    final iconSize = isWideScreen ? 48.0 : 10.w;
    final spacing = isWideScreen ? 12.0 : 1.5.h;
    
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(borderRadius),
      child: Container(
        padding: EdgeInsets.all(padding),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(borderRadius),
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
              size: iconSize,
            ),
            SizedBox(height: spacing),
            Text(
              title,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: color,
                    fontSize: isWideScreen ? 16 : null,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSection([bool isWideScreen = false]) {
    final borderRadius = isWideScreen ? 16.0 : 3.w;
    final padding = isWideScreen ? 32.0 : 4.w;
    final iconSize = isWideScreen ? 24.0 : 5.w;
    final spacing = isWideScreen ? 16.0 : 2.w;
    final stepSpacing = isWideScreen ? 16.0 : 1.h;
    
    return Container(
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CustomIconWidget(
                iconName: 'info',
                color: AppTheme.lightTheme.colorScheme.primary,
                size: iconSize,
              ),
              SizedBox(width: spacing),
              Text(
                'How It Works',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: isWideScreen ? 18 : null,
                    ),
              ),
            ],
          ),
          SizedBox(height: isWideScreen ? 24 : 2.h),
          _buildInfoStep('1', 'Capture a photo of the snake or bite mark', isWideScreen),
          SizedBox(height: stepSpacing),
          _buildInfoStep('2', 'AI identifies the snake species instantly', isWideScreen),
          SizedBox(height: stepSpacing),
          _buildInfoStep('3', 'Get treatment protocols and first aid steps', isWideScreen),
          SizedBox(height: stepSpacing),
          _buildInfoStep('4', 'Chat with AI for additional guidance', isWideScreen),
        ],
      ),
    );
  }

  Widget _buildInfoStep(String number, String text, [bool isWideScreen = false]) {
    final size = isWideScreen ? 32.0 : 6.w;
    final spacing = isWideScreen ? 16.0 : 3.w;
    
    return Row(
      children: [
        Container(
          width: size,
          height: size,
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
                    fontSize: isWideScreen ? 14 : null,
                  ),
            ),
          ),
        ),
        SizedBox(width: spacing),
        Expanded(
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.textMediumEmphasisLight,
                  fontSize: isWideScreen ? 15 : null,
                ),
          ),
        ),
      ],
    );
  }
}
