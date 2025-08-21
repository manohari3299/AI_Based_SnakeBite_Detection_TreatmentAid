import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/action_card_widget.dart';
import './widgets/emergency_contact_card_widget.dart';
import './widgets/recent_identification_item_widget.dart';
import './widgets/stats_card_widget.dart';
import './widgets/status_banner_widget.dart';

class HomeDashboard extends StatefulWidget {
  const HomeDashboard({Key? key}) : super(key: key);

  @override
  State<HomeDashboard> createState() => _HomeDashboardState();
}

class _HomeDashboardState extends State<HomeDashboard>
    with TickerProviderStateMixin {
  late TabController _tabController;
  bool _isOnline = true;

  // Mock data for recent identifications
  final List<Map<String, dynamic>> _recentIdentifications = [
    {
      "id": 1,
      "speciesName": "Eastern Diamondback Rattlesnake",
      "scientificName": "Crotalus adamanteus",
      "isVenomous": true,
      "confidence": 94.2,
      "timestamp": "2 hours ago",
      "imageUrl":
          "https://images.pexels.com/photos/33783/rattle-snake-toxic-dangerous-poisonous.jpg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1",
    },
    {
      "id": 2,
      "speciesName": "Eastern Rat Snake",
      "scientificName": "Pantherophis alleghaniensis",
      "isVenomous": false,
      "confidence": 87.8,
      "timestamp": "1 day ago",
      "imageUrl":
          "https://images.pexels.com/photos/86596/snake-reptile-python-animal-86596.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1",
    },
    {
      "id": 3,
      "speciesName": "Copperhead",
      "scientificName": "Agkistrodon contortrix",
      "isVenomous": true,
      "confidence": 91.5,
      "timestamp": "3 days ago",
      "imageUrl":
          "https://images.pexels.com/photos/4666748/pexels-photo-4666748.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1",
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _checkConnectivity();
    _setupConnectivityListener();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _checkConnectivity() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    setState(() {
      _isOnline = connectivityResult != ConnectivityResult.none;
    });
  }

  void _setupConnectivityListener() {
    Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
      setState(() {
        _isOnline = result != ConnectivityResult.none;
      });
    });
  }

  Future<void> _refreshData() async {
    // Simulate refresh delay
    await Future.delayed(const Duration(seconds: 2));
  }

  void _navigateToCamera() {
    Navigator.pushNamed(context, '/camera-capture');
  }

  void _navigateToGallery() {
    Navigator.pushNamed(context, '/camera-capture');
  }

  void _navigateToIdentificationDetails(Map<String, dynamic> identification) {
    Navigator.pushNamed(context, '/species-identification-results');
  }

  void _deleteIdentification(int id) {
    setState(() {
      _recentIdentifications.removeWhere((item) => item['id'] == id);
    });
  }

  void _navigateToEmergencyCapture() {
    Navigator.pushNamed(context, '/camera-capture');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Row(
          children: [
            CustomIconWidget(
              iconName: 'medical_services',
              color: AppTheme.lightTheme.colorScheme.primary,
              size: 6.w,
            ),
            SizedBox(width: 2.w),
            Text(
              'SnakeBite AI',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
        actions: [
          Container(
            margin: EdgeInsets.only(right: 4.w),
            padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.h),
            decoration: BoxDecoration(
              color: _isOnline
                  ? AppTheme.lightTheme.colorScheme.secondary
                  : AppTheme.lightTheme.colorScheme.error,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomIconWidget(
                  iconName: _isOnline ? 'wifi' : 'wifi_off',
                  color: Colors.white,
                  size: 4.w,
                ),
                SizedBox(width: 1.w),
                Text(
                  _isOnline ? 'Online' : 'Offline',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Home'),
            Tab(text: 'History'),
            Tab(text: 'Chat'),
            Tab(text: 'Settings'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildHomeTab(),
          _buildHistoryTab(),
          _buildChatTab(),
          _buildSettingsTab(),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _navigateToEmergencyCapture,
        backgroundColor: AppTheme.lightTheme.colorScheme.error,
        foregroundColor: Colors.white,
        icon: CustomIconWidget(
          iconName: 'camera_alt',
          color: Colors.white,
          size: 6.w,
        ),
        label: Text(
          'EMERGENCY',
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
        ),
      ),
    );
  }

  Widget _buildHomeTab() {
    return RefreshIndicator(
      onRefresh: _refreshData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 2.h),

            // Status Banner
            StatusBannerWidget(
              isOnline: _isOnline,
              lastUpdate: "Aug 20, 2025",
              modelVersion: "2.1.3",
            ),

            SizedBox(height: 2.h),

            // Hero Action Cards
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ActionCardWidget(
                    title: 'Take Photo',
                    iconName: 'camera_alt',
                    backgroundColor:
                        AppTheme.lightTheme.colorScheme.primaryContainer,
                    borderColor: AppTheme.lightTheme.colorScheme.primary,
                    onTap: _navigateToCamera,
                  ),
                  ActionCardWidget(
                    title: 'Upload from Gallery',
                    iconName: 'photo_library',
                    backgroundColor:
                        AppTheme.lightTheme.colorScheme.tertiaryContainer,
                    borderColor: AppTheme.lightTheme.colorScheme.tertiary,
                    onTap: _navigateToGallery,
                  ),
                ],
              ),
            ),

            SizedBox(height: 3.h),

            // Quick Stats
            StatsCardWidget(
              totalIdentifications: _recentIdentifications.length,
              averageConfidence: _recentIdentifications.isNotEmpty
                  ? (_recentIdentifications
                          .map((e) => e['confidence'] as double)
                          .reduce((a, b) => a + b) /
                      _recentIdentifications.length)
                  : 0.0,
            ),

            SizedBox(height: 3.h),

            // Emergency Contact
            const EmergencyContactCardWidget(),

            SizedBox(height: 3.h),

            // Recent Identifications
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              child: Text(
                'Recent Identifications',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),

            SizedBox(height: 1.h),

            _recentIdentifications.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _recentIdentifications.length,
                    itemBuilder: (context, index) {
                      final identification = _recentIdentifications[index];
                      return RecentIdentificationItemWidget(
                        identification: identification,
                        onTap: () =>
                            _navigateToIdentificationDetails(identification),
                        onDelete: () =>
                            _deleteIdentification(identification['id'] as int),
                      );
                    },
                  ),

            SizedBox(height: 10.h), // Space for FAB
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: EdgeInsets.all(8.w),
      child: Column(
        children: [
          CustomIconWidget(
            iconName: 'search',
            color:
                Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3),
            size: 20.w,
          ),
          SizedBox(height: 2.h),
          Text(
            'No identifications yet',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.7),
                ),
          ),
          SizedBox(height: 1.h),
          Text(
            'Start your first identification to help save lives',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.5),
                ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 3.h),
          ElevatedButton.icon(
            onPressed: _navigateToCamera,
            icon: CustomIconWidget(
              iconName: 'camera_alt',
              color: Colors.white,
              size: 5.w,
            ),
            label: const Text('Start First Identification'),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryTab() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CustomIconWidget(
            iconName: 'history',
            color: Theme.of(context).colorScheme.primary,
            size: 15.w,
          ),
          SizedBox(height: 2.h),
          Text(
            'Identification History',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          SizedBox(height: 1.h),
          Text(
            'View your complete identification history',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.7),
                ),
          ),
          SizedBox(height: 3.h),
          ElevatedButton(
            onPressed: () =>
                Navigator.pushNamed(context, '/identification-history'),
            child: const Text('View Full History'),
          ),
        ],
      ),
    );
  }

  Widget _buildChatTab() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CustomIconWidget(
            iconName: 'chat',
            color: Theme.of(context).colorScheme.primary,
            size: 15.w,
          ),
          SizedBox(height: 2.h),
          Text(
            'AI Chat Assistant',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          SizedBox(height: 1.h),
          Text(
            'Get instant answers about snake safety',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.7),
                ),
          ),
          SizedBox(height: 3.h),
          ElevatedButton(
            onPressed: () => Navigator.pushNamed(context, '/chat-assistant'),
            child: const Text('Start Chat'),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTab() {
    return Padding(
      padding: EdgeInsets.all(4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 2.h),
          Text(
            'Settings',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          SizedBox(height: 3.h),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: CustomIconWidget(
                    iconName: 'notifications',
                    color: Theme.of(context).colorScheme.primary,
                    size: 6.w,
                  ),
                  title: const Text('Emergency Notifications'),
                  subtitle: const Text('Get alerts for critical updates'),
                  trailing: Switch(
                    value: true,
                    onChanged: (value) {},
                  ),
                ),
                const Divider(),
                ListTile(
                  leading: CustomIconWidget(
                    iconName: 'dark_mode',
                    color: Theme.of(context).colorScheme.primary,
                    size: 6.w,
                  ),
                  title: const Text('Dark Mode'),
                  subtitle: const Text('Better for low-light conditions'),
                  trailing: Switch(
                    value: false,
                    onChanged: (value) {},
                  ),
                ),
                const Divider(),
                ListTile(
                  leading: CustomIconWidget(
                    iconName: 'language',
                    color: Theme.of(context).colorScheme.primary,
                    size: 6.w,
                  ),
                  title: const Text('Language'),
                  subtitle: const Text('English (US)'),
                  trailing: CustomIconWidget(
                    iconName: 'arrow_forward_ios',
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.5),
                    size: 4.w,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 2.h),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: CustomIconWidget(
                    iconName: 'info',
                    color: Theme.of(context).colorScheme.primary,
                    size: 6.w,
                  ),
                  title: const Text('About'),
                  subtitle: const Text('Version 2.1.3'),
                  trailing: CustomIconWidget(
                    iconName: 'arrow_forward_ios',
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.5),
                    size: 4.w,
                  ),
                ),
                const Divider(),
                ListTile(
                  leading: CustomIconWidget(
                    iconName: 'help',
                    color: Theme.of(context).colorScheme.primary,
                    size: 6.w,
                  ),
                  title: const Text('Help & Support'),
                  subtitle: const Text('Get help using the app'),
                  trailing: CustomIconWidget(
                    iconName: 'arrow_forward_ios',
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.5),
                    size: 4.w,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
