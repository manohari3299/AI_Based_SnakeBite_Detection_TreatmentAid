import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../services/history_service.dart';
import './widgets/empty_state_widget.dart';
import './widgets/filter_chips_widget.dart';
import './widgets/history_card_widget.dart';
import './widgets/offline_indicator_widget.dart';
import './widgets/search_bar_widget.dart';

class IdentificationHistory extends StatefulWidget {
  const IdentificationHistory({Key? key}) : super(key: key);

  @override
  State<IdentificationHistory> createState() => _IdentificationHistoryState();
}

class _IdentificationHistoryState extends State<IdentificationHistory>
    with TickerProviderStateMixin {
  late TabController _tabController;
  String _searchQuery = '';
  String _selectedFilter = 'all';
  bool _isSelectionMode = false;
  Set<String> _selectedItems = {};
  bool _isOnline = true;
  int _pendingSyncCount = 0;

  // Real identification history loaded from storage
  List<Map<String, dynamic>> _identificationHistory = [];
  bool _isLoadingHistory = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this, initialIndex: 1);
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    setState(() {
      _isLoadingHistory = true;
    });

    try {
      final history = await HistoryService().getHistory();
      setState(() {
        _identificationHistory = history.map((item) {
          // Convert timestamp string back to DateTime if it's stored as string
          if (item['timestamp'] is String) {
            item['timestamp'] = DateTime.parse(item['timestamp']);
          }
          return item;
        }).toList();
        _isLoadingHistory = false;
      });
    } catch (e) {
      print('Error loading history: $e');
      setState(() {
        _isLoadingHistory = false;
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get _filteredHistory {
    List<Map<String, dynamic>> filtered = _identificationHistory;

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((item) {
        final speciesName = (item['speciesName'] ?? '').toLowerCase();
        final location = (item['location'] ?? '').toLowerCase();
        final scientificName = (item['scientificName'] ?? '').toLowerCase();
        final query = _searchQuery.toLowerCase();

        return speciesName.contains(query) ||
            location.contains(query) ||
            scientificName.contains(query);
      }).toList();
    }

    // Apply category filter
    switch (_selectedFilter) {
      case 'venomous':
        filtered =
            filtered.where((item) => item['isVenomous'] == true).toList();
        break;
      case 'recent':
        final twentyFourHoursAgo =
            DateTime.now().subtract(const Duration(hours: 24));
        filtered = filtered.where((item) {
          final timestamp = item['timestamp'] as DateTime;
          return timestamp.isAfter(twentyFourHoursAgo);
        }).toList();
        break;
      case 'high_confidence':
        filtered = filtered.where((item) {
          final confidence = (item['confidence'] ?? 0.0).toDouble();
          return confidence > 90.0;
        }).toList();
        break;
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          // Tab bar
          Container(
            color: Theme.of(context).appBarTheme.backgroundColor,
            child: TabBar(
              controller: _tabController,
              tabs: const [
                Tab(text: 'Dashboard'),
                Tab(text: 'History'),
              ],
              onTap: (index) {
                if (index == 0) {
                  Navigator.pushReplacementNamed(context, '/landing-page');
                }
              },
            ),
          ),

          // Search bar
          SearchBarWidget(
            searchQuery: _searchQuery,
            onSearchChanged: (query) {
              setState(() {
                _searchQuery = query;
              });
            },
            onFilterTap: _showFilterDialog,
          ),

          // Filter chips
          FilterChipsWidget(
            selectedFilter: _selectedFilter,
            onFilterChanged: (filter) {
              setState(() {
                _selectedFilter = filter;
              });
            },
          ),

          SizedBox(height: 1.h),

          // Offline indicator
          OfflineIndicatorWidget(
            isOnline: _isOnline,
            pendingSyncCount: _pendingSyncCount,
          ),

          // Content
          Expanded(
            child: _isLoadingHistory
                ? Center(
                    child: CircularProgressIndicator(),
                  )
                : _filteredHistory.isEmpty
                    ? _buildEmptyState()
                    : _buildHistoryList(),
          ),
        ],
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Text(
        _isSelectionMode
            ? '${_selectedItems.length} selected'
            : 'Identification History',
      ),
      actions: [
        if (_isSelectionMode) ...[
          IconButton(
            onPressed: _shareSelectedItems,
            icon: CustomIconWidget(
              iconName: 'share',
              color: Theme.of(context).colorScheme.onSurface,
              size: 6.w,
            ),
          ),
          IconButton(
            onPressed: _exportSelectedItems,
            icon: CustomIconWidget(
              iconName: 'file_download',
              color: Theme.of(context).colorScheme.onSurface,
              size: 6.w,
            ),
          ),
          IconButton(
            onPressed: _deleteSelectedItems,
            icon: CustomIconWidget(
              iconName: 'delete',
              color: AppTheme.lightTheme.colorScheme.error,
              size: 6.w,
            ),
          ),
        ] else ...[
          IconButton(
            onPressed: _refreshHistory,
            icon: CustomIconWidget(
              iconName: 'refresh',
              color: Theme.of(context).colorScheme.onSurface,
              size: 6.w,
            ),
          ),
          PopupMenuButton<String>(
            onSelected: _handleMenuAction,
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'export_all',
                child: Text('Export All'),
              ),
              const PopupMenuItem(
                value: 'clear_history',
                child: Text('Clear History'),
              ),
              const PopupMenuItem(
                value: 'sync_settings',
                child: Text('Sync Settings'),
              ),
            ],
            icon: CustomIconWidget(
              iconName: 'more_vert',
              color: Theme.of(context).colorScheme.onSurface,
              size: 6.w,
            ),
          ),
        ],
      ],
      leading: _isSelectionMode
          ? IconButton(
              onPressed: _exitSelectionMode,
              icon: CustomIconWidget(
                iconName: 'close',
                color: Theme.of(context).colorScheme.onSurface,
                size: 6.w,
              ),
            )
          : null,
    );
  }

  Widget _buildHistoryList() {
    return RefreshIndicator(
      onRefresh: _refreshHistory,
      child: ListView.builder(
        padding: EdgeInsets.only(bottom: 10.h),
        itemCount: _filteredHistory.length,
        itemBuilder: (context, index) {
          final identification = _filteredHistory[index];
          final isSelected = _selectedItems.contains(identification['id']);

          return HistoryCardWidget(
            identification: identification,
            isSelected: isSelected,
            onTap: () => _handleCardTap(identification),
            onViewDetails: () => _viewDetails(identification),
            onShare: () => _shareItem(identification),
            onDelete: () => _deleteItem(identification),
            onCallPoisonControl: () => _callPoisonControl(identification),
            onViewTreatment: () => _viewTreatment(identification),
            onReportBite: () => _reportBite(identification),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return EmptyStateWidget(
      onCameraCapture: () {
        Navigator.pushNamed(context, '/camera-capture');
      },
    );
  }

  Widget _buildFloatingActionButton() {
    return FloatingActionButton.extended(
      onPressed: () {
        Navigator.pushNamed(context, '/camera-capture');
      },
      icon: CustomIconWidget(
        iconName: 'camera_alt',
        color: Colors.white,
        size: 6.w,
      ),
      label: Text(
        'New ID',
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }

  void _handleCardTap(Map<String, dynamic> identification) {
    if (_isSelectionMode) {
      setState(() {
        final id = identification['id'];
        if (_selectedItems.contains(id)) {
          _selectedItems.remove(id);
        } else {
          _selectedItems.add(id);
        }

        if (_selectedItems.isEmpty) {
          _isSelectionMode = false;
        }
      });
    } else {
      _viewDetails(identification);
    }
  }

  void _viewDetails(Map<String, dynamic> identification) {
    Navigator.pushNamed(
      context,
      '/species-identification-results',
      arguments: identification,
    );
  }

  void _shareItem(Map<String, dynamic> identification) {
    // Implement share functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Sharing ${identification['speciesName']}'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _deleteItem(Map<String, dynamic> identification) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Identification'),
        content: Text(
            'Are you sure you want to delete this ${identification['speciesName']} identification?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              // Delete from history service
              await HistoryService().deleteIdentification(identification['id']);
              // Reload history
              await _loadHistory();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Identification deleted')),
              );
            },
            child: Text(
              'Delete',
              style: TextStyle(color: AppTheme.lightTheme.colorScheme.error),
            ),
          ),
        ],
      ),
    );
  }

  void _callPoisonControl(Map<String, dynamic> identification) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            CustomIconWidget(
              iconName: 'phone',
              color: AppTheme.lightTheme.primaryColor,
              size: 6.w,
            ),
            SizedBox(width: 3.w),
            const Text('Emergency Call'),
          ],
        ),
        content: const Text('Call Poison Control Center?\n\n1-800-222-1222'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Implement actual phone call
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Calling Poison Control...')),
              );
            },
            child: const Text('Call Now'),
          ),
        ],
      ),
    );
  }

  void _viewTreatment(Map<String, dynamic> identification) {
    Navigator.pushNamed(
      context,
      '/treatment-protocols',
      arguments: identification,
    );
  }

  void _reportBite(Map<String, dynamic> identification) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            CustomIconWidget(
              iconName: 'report',
              color: AppTheme.lightTheme.primaryColor,
              size: 6.w,
            ),
            SizedBox(width: 3.w),
            const Text('Report Bite'),
          ],
        ),
        content: const Text(
            'Report this snake bite to medical authorities and wildlife services?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Bite reported to authorities')),
              );
            },
            child: const Text('Report'),
          ),
        ],
      ),
    );
  }

  Future<void> _refreshHistory() async {
    // Reload history from storage
    await _loadHistory();

    setState(() {
      _isOnline = true;
      _pendingSyncCount = 0;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('History updated')),
    );
  }

  void _showFilterDialog() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(6.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 12.w,
                height: 0.5.h,
                decoration: BoxDecoration(
                  color: Theme.of(context).dividerColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            SizedBox(height: 3.h),
            Text(
              'Filter Options',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            SizedBox(height: 3.h),
            Text(
              'Sort by Date',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            SizedBox(height: 1.h),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {},
                    child: const Text('Newest First'),
                  ),
                ),
                SizedBox(width: 4.w),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {},
                    child: const Text('Oldest First'),
                  ),
                ),
              ],
            ),
            SizedBox(height: 3.h),
            Text(
              'Date Range',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            SizedBox(height: 1.h),
            OutlinedButton(
              onPressed: () {},
              child: const Text('Select Date Range'),
            ),
            SizedBox(height: 4.h),
          ],
        ),
      ),
    );
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'export_all':
        _exportAllHistory();
        break;
      case 'clear_history':
        _clearHistory();
        break;
      case 'sync_settings':
        _showSyncSettings();
        break;
    }
  }

  void _exportAllHistory() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Exporting all history...')),
    );
  }

  void _clearHistory() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear History'),
        content: const Text(
            'Are you sure you want to clear all identification history? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              // Clear history from service
              await HistoryService().clearHistory();
              // Reload history
              await _loadHistory();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('History cleared')),
              );
            },
            child: Text(
              'Clear All',
              style: TextStyle(color: AppTheme.lightTheme.colorScheme.error),
            ),
          ),
        ],
      ),
    );
  }

  void _showSyncSettings() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Opening sync settings...')),
    );
  }

  void _shareSelectedItems() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Sharing ${_selectedItems.length} items')),
    );
  }

  void _exportSelectedItems() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Exporting ${_selectedItems.length} items')),
    );
  }

  void _deleteSelectedItems() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Selected'),
        content: Text(
            'Are you sure you want to delete ${_selectedItems.length} selected items?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              // Delete from history service
              await HistoryService().deleteMultiple(_selectedItems);
              // Reload history
              await _loadHistory();
              setState(() {
                _selectedItems.clear();
                _isSelectionMode = false;
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Selected items deleted')),
              );
            },
            child: Text(
              'Delete',
              style: TextStyle(color: AppTheme.lightTheme.colorScheme.error),
            ),
          ),
        ],
      ),
    );
  }

  void _exitSelectionMode() {
    setState(() {
      _isSelectionMode = false;
      _selectedItems.clear();
    });
  }
}
