import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/connectivity_status_widget.dart';
import './widgets/message_bubble_widget.dart';
import './widgets/message_input_widget.dart';
import './widgets/quick_action_button_widget.dart';

class ChatAssistant extends StatefulWidget {
  const ChatAssistant({Key? key}) : super(key: key);

  @override
  State<ChatAssistant> createState() => _ChatAssistantState();
}

class _ChatAssistantState extends State<ChatAssistant>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final RefreshController _refreshController = RefreshController();

  bool _isOnline = false;
  bool _isRecording = false;
  bool _isLoading = false;
  StreamSubscription<ConnectivityResult>? _connectivitySubscription;

  final List<Map<String, dynamic>> _messages = [];

  // Mock local database for offline responses
  final List<Map<String, dynamic>> _localDatabase = [
    {
      "query": "identify symptoms",
      "response":
          "Common snakebite symptoms include: puncture wounds, swelling, pain, nausea, vomiting, difficulty breathing, and changes in heart rate. Seek immediate medical attention.",
      "category": "symptoms"
    },
    {
      "query": "first aid steps",
      "response":
          "1. Keep victim calm and still\n2. Remove jewelry/tight clothing\n3. Position bite below heart level\n4. Clean wound gently\n5. Apply loose bandage\n6. Seek immediate medical help\n\nDO NOT: Cut wound, suck venom, apply ice, or use tourniquet.",
      "category": "first_aid"
    },
    {
      "query": "antivenom availability",
      "response":
          "Antivenoms are available at major hospitals and emergency centers. Common types:\n• Polyvalent antivenom (multiple species)\n• CroFab (North American pit vipers)\n• Coral snake antivenom\n\nContact nearest hospital for specific availability.",
      "category": "antivenom"
    },
    {
      "query": "find nearest hospital",
      "response":
          "Emergency contacts:\n• Call 911 (US) or local emergency number\n• Poison Control: 1-800-222-1222\n• Use GPS to locate nearest trauma center\n• Inform them of snakebite for preparation",
      "category": "emergency"
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this, initialIndex: 4);
    _initializeConnectivity();
    _loadInitialMessages();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _messageController.dispose();
    _scrollController.dispose();
    _refreshController.dispose();
    _connectivitySubscription?.cancel();
    super.dispose();
  }

  Future<void> _initializeConnectivity() async {
    final ConnectivityResult connectivityResult =
        await Connectivity().checkConnectivity();
    _updateConnectionStatus(connectivityResult);

    _connectivitySubscription = Connectivity()
        .onConnectivityChanged
        .listen((result) => _updateConnectionStatus(result));
  }

  void _updateConnectionStatus(ConnectivityResult connectivityResult) {
    setState(() {
      _isOnline = connectivityResult != ConnectivityResult.none;
    });

    if (_isOnline) {
      Fluttertoast.showToast(
        msg: "Connected - AI Medical Assistant available",
        backgroundColor: AppTheme.successLight,
        textColor: Colors.white,
      );
    } else {
      Fluttertoast.showToast(
        msg: "Offline mode - Using local database",
        backgroundColor: AppTheme.warningLight,
        textColor: Colors.white,
      );
    }
  }

  void _loadInitialMessages() {
    setState(() {
      _messages.addAll([
        {
          "message":
              "Welcome to SnakeBite AI Assistant! I'm here to help with emergency snake identification and treatment guidance.",
          "isUser": false,
          "source": _isOnline ? "AI Medical Assistant" : "Local Database",
          "timestamp": DateTime.now().subtract(const Duration(minutes: 1)),
        },
        {
          "message":
              "You can ask me about symptoms, first aid procedures, antivenom information, or use the quick actions below.",
          "isUser": false,
          "source": _isOnline ? "AI Medical Assistant" : "Local Database",
          "timestamp": DateTime.now(),
        },
      ]);
    });
  }

  Future<void> _sendMessage() async {
    final message = _messageController.text.trim();
    if (message.isEmpty) return;

    setState(() {
      _messages.add({
        "message": message,
        "isUser": true,
        "source": "User",
        "timestamp": DateTime.now(),
      });
      _isLoading = true;
    });

    _messageController.clear();
    _scrollToBottom();

    // Simulate processing delay
    await Future.delayed(const Duration(milliseconds: 500));

    if (_isOnline) {
      await _processOnlineQuery(message);
    } else {
      await _processOfflineQuery(message);
    }

    setState(() {
      _isLoading = false;
    });
    _scrollToBottom();
  }

  Future<void> _processOnlineQuery(String query) async {
    // Simulate API call to LLaMA backend
    await Future.delayed(const Duration(seconds: 1));

    String response = _generateAIResponse(query);

    setState(() {
      _messages.add({
        "message": response,
        "isUser": false,
        "source": "AI Medical Assistant",
        "timestamp": DateTime.now(),
      });
    });
  }

  Future<void> _processOfflineQuery(String query) async {
    String response = _searchLocalDatabase(query);

    setState(() {
      _messages.add({
        "message": response,
        "isUser": false,
        "source": "Local Database",
        "timestamp": DateTime.now(),
      });
    });
  }

  String _searchLocalDatabase(String query) {
    final lowerQuery = query.toLowerCase();

    for (final entry in _localDatabase) {
      if (lowerQuery.contains(entry["query"]) ||
          entry["query"].contains(lowerQuery.split(' ').first)) {
        return entry["response"];
      }
    }

    return "I found some general guidance: For any snakebite emergency, keep the victim calm, remove tight clothing/jewelry, clean the wound gently, and seek immediate medical attention. Do not cut the wound or apply ice. Call emergency services immediately.";
  }

  String _generateAIResponse(String query) {
    final lowerQuery = query.toLowerCase();

    if (lowerQuery.contains('symptom')) {
      return "Based on current medical protocols, snakebite symptoms can vary significantly by species. Early signs include puncture marks, localized pain and swelling, nausea, and potential systemic effects like difficulty breathing or altered heart rate. The severity and progression depend on the snake species, venom amount, and victim's health. Immediate medical evaluation is crucial for proper assessment and potential antivenom administration.";
    } else if (lowerQuery.contains('first aid') ||
        lowerQuery.contains('treatment')) {
      return "Current emergency protocols recommend: 1) Keep victim calm and immobile, 2) Remove constricting items before swelling, 3) Position bite below heart level if possible, 4) Clean wound with soap and water, 5) Apply loose bandage above bite, 6) Mark swelling progression, 7) Transport to medical facility immediately. Avoid traditional remedies like cutting, suction, ice, or tourniquets as these can worsen outcomes.";
    } else if (lowerQuery.contains('antivenom') ||
        lowerQuery.contains('hospital')) {
      return "Antivenom availability varies by region and snake species. Major trauma centers typically stock polyvalent antivenoms effective against multiple local species. Contact your regional poison control center or emergency services for specific availability. Time is critical - antivenom is most effective within 4-6 hours of envenomation. Provide medical staff with snake identification if safely possible.";
    } else {
      return "I'm here to provide evidence-based guidance for snakebite emergencies. I can help with symptom identification, first aid procedures, antivenom information, and emergency protocols. For immediate life-threatening situations, please call emergency services first, then use this assistant for additional guidance while awaiting medical care.";
    }
  }

  void _handleVoiceInput() {
    setState(() {
      _isRecording = !_isRecording;
    });

    if (_isRecording) {
      Fluttertoast.showToast(
        msg: "Voice recording started...",
        backgroundColor: AppTheme.lightTheme.primaryColor,
        textColor: Colors.white,
      );

      // Simulate voice recording
      Future.delayed(const Duration(seconds: 3), () {
        if (_isRecording) {
          setState(() {
            _isRecording = false;
            _messageController.text =
                "What are the symptoms of a venomous snakebite?";
          });
          Fluttertoast.showToast(
            msg: "Voice input processed",
            backgroundColor: AppTheme.successLight,
            textColor: Colors.white,
          );
        }
      });
    } else {
      Fluttertoast.showToast(
        msg: "Voice recording stopped",
        backgroundColor: AppTheme.warningLight,
        textColor: Colors.white,
      );
    }
  }

  void _handleQuickAction(String action) {
    _messageController.text = action;
    _sendMessage();
  }

  void _showMessageOptions(String message) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.all(4.w),
        decoration: BoxDecoration(
          color: AppTheme.lightTheme.colorScheme.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(4.w)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12.w,
              height: 0.5.h,
              decoration: BoxDecoration(
                color: AppTheme.outlineLight,
                borderRadius: BorderRadius.circular(1.w),
              ),
            ),
            SizedBox(height: 3.h),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'copy',
                color: AppTheme.lightTheme.primaryColor,
                size: 6.w,
              ),
              title: Text(
                'Copy Text',
                style: AppTheme.lightTheme.textTheme.bodyMedium,
              ),
              onTap: () {
                Clipboard.setData(ClipboardData(text: message));
                Navigator.pop(context);
                Fluttertoast.showToast(
                  msg: "Message copied to clipboard",
                  backgroundColor: AppTheme.successLight,
                  textColor: Colors.white,
                );
              },
            ),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'share',
                color: AppTheme.lightTheme.primaryColor,
                size: 6.w,
              ),
              title: Text(
                'Share Response',
                style: AppTheme.lightTheme.textTheme.bodyMedium,
              ),
              onTap: () {
                Navigator.pop(context);
                Fluttertoast.showToast(
                  msg: "Share functionality activated",
                  backgroundColor: AppTheme.lightTheme.primaryColor,
                  textColor: Colors.white,
                );
              },
            ),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'report',
                color: AppTheme.errorLight,
                size: 6.w,
              ),
              title: Text(
                'Report Issue',
                style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                  color: AppTheme.errorLight,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                Fluttertoast.showToast(
                  msg: "Issue reported for review",
                  backgroundColor: AppTheme.errorLight,
                  textColor: Colors.white,
                );
              },
            ),
            SizedBox(height: 2.h),
          ],
        ),
      ),
    );
  }

  Future<void> _refreshMessages() async {
    await Future.delayed(const Duration(seconds: 1));

    if (_isOnline) {
      setState(() {
        _messages.insert(0, {
          "message": "Conversation synced with cloud backup",
          "isUser": false,
          "source": "AI Medical Assistant",
          "timestamp": DateTime.now(),
        });
      });
    }

    _refreshController.refreshCompleted();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildTabBar(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildPlaceholderTab('Home Dashboard'),
                _buildPlaceholderTab('Camera Capture'),
                _buildPlaceholderTab('Species Results'),
                _buildPlaceholderTab('Treatment Protocols'),
                _buildChatTab(),
                _buildPlaceholderTab('History'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppTheme.lightTheme.colorScheme.surface,
      elevation: 2,
      shadowColor: AppTheme.shadowColor,
      title: Row(
        children: [
          CustomIconWidget(
            iconName: 'medical_services',
            color: AppTheme.lightTheme.primaryColor,
            size: 6.w,
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'SnakeBite AI Assistant',
                  style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'Emergency Medical Support',
                  style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                    color: AppTheme.textMediumEmphasisLight,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        ConnectivityStatusWidget(isOnline: _isOnline),
        SizedBox(width: 4.w),
      ],
    );
  }

  Widget _buildTabBar() {
    return Container(
      color: AppTheme.lightTheme.colorScheme.surface,
      child: TabBar(
        controller: _tabController,
        isScrollable: true,
        indicatorColor: AppTheme.lightTheme.primaryColor,
        labelColor: AppTheme.lightTheme.primaryColor,
        unselectedLabelColor: AppTheme.textMediumEmphasisLight,
        labelStyle: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: AppTheme.lightTheme.textTheme.labelMedium,
        tabs: const [
          Tab(text: 'Home'),
          Tab(text: 'Camera'),
          Tab(text: 'Results'),
          Tab(text: 'Treatment'),
          Tab(text: 'Chat'),
          Tab(text: 'History'),
        ],
      ),
    );
  }

  Widget _buildChatTab() {
    return Column(
      children: [
        _buildQuickActions(),
        Expanded(
          child: RefreshIndicator(
            onRefresh: _refreshMessages,
            color: AppTheme.lightTheme.primaryColor,
            child: ListView.builder(
              controller: _scrollController,
              padding: EdgeInsets.symmetric(vertical: 2.h),
              itemCount: _messages.length + (_isLoading ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == _messages.length && _isLoading) {
                  return _buildLoadingIndicator();
                }

                final message = _messages[index];
                return MessageBubbleWidget(
                  message: message["message"],
                  isUser: message["isUser"],
                  source: message["source"],
                  timestamp: message["timestamp"],
                  onLongPress: () => _showMessageOptions(message["message"]),
                );
              },
            ),
          ),
        ),
        MessageInputWidget(
          controller: _messageController,
          onSend: _sendMessage,
          onVoiceInput: _handleVoiceInput,
          isRecording: _isRecording,
        ),
      ],
    );
  }

  Widget _buildQuickActions() {
    return Container(
      padding: EdgeInsets.all(4.w),
      color: AppTheme.lightTheme.colorScheme.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Emergency Actions',
            style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 2.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              QuickActionButtonWidget(
                title: 'Identify Symptoms',
                iconName: 'search',
                onTap: () => _handleQuickAction('Identify symptoms'),
              ),
              QuickActionButtonWidget(
                title: 'Find Hospital',
                iconName: 'local_hospital',
                onTap: () => _handleQuickAction('Find nearest hospital'),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              QuickActionButtonWidget(
                title: 'Antivenom Info',
                iconName: 'medication',
                onTap: () => _handleQuickAction('Antivenom availability'),
              ),
              QuickActionButtonWidget(
                title: 'First Aid Steps',
                iconName: 'healing',
                onTap: () => _handleQuickAction('First aid steps'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 1.h, horizontal: 4.w),
      child: Row(
        children: [
          Container(
            width: 8.w,
            height: 8.w,
            decoration: BoxDecoration(
              color:
                  _isOnline ? AppTheme.secondaryLight : AppTheme.tertiaryLight,
              shape: BoxShape.circle,
            ),
            child: CustomIconWidget(
              iconName: _isOnline ? 'smart_toy' : 'storage',
              color: Colors.white,
              size: 4.w,
            ),
          ),
          SizedBox(width: 2.w),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.surface,
              borderRadius: BorderRadius.circular(4.w),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.shadowColor,
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 4.w,
                  height: 4.w,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      _isOnline
                          ? AppTheme.secondaryLight
                          : AppTheme.tertiaryLight,
                    ),
                  ),
                ),
                SizedBox(width: 3.w),
                Text(
                  _isOnline ? 'AI is thinking...' : 'Searching database...',
                  style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textMediumEmphasisLight,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholderTab(String tabName) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CustomIconWidget(
            iconName: 'construction',
            color: AppTheme.textMediumEmphasisLight,
            size: 15.w,
          ),
          SizedBox(height: 3.h),
          Text(
            '$tabName Screen',
            style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
              color: AppTheme.textMediumEmphasisLight,
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            'This screen will be implemented in the full application',
            textAlign: TextAlign.center,
            style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
              color: AppTheme.textDisabledLight,
            ),
          ),
        ],
      ),
    );
  }
}

class RefreshController {
  void refreshCompleted() {}
  void dispose() {}
}
