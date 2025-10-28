import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../services/api_service.dart';
import './widgets/connectivity_status_widget.dart';
import './widgets/message_bubble_widget.dart';
import './widgets/message_input_widget.dart';

class ChatAssistant extends StatefulWidget {
  const ChatAssistant({Key? key}) : super(key: key);

  @override
  State<ChatAssistant> createState() => _ChatAssistantState();
}

class _ChatAssistantState extends State<ChatAssistant> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final RefreshController _refreshController = RefreshController();
  final ApiService _apiService = ApiService();

  bool _isOnline = false;
  bool _isRecording = false;
  bool _isLoading = false;
  StreamSubscription<ConnectivityResult>? _connectivitySubscription;
  String? _conversationId;
  String? _currentSpeciesName;

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
    // ApiService is already initialized in main.dart, no need to initialize again
    _initializeConnectivity();
    _loadInitialMessages();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _refreshController.dispose();
    _connectivitySubscription?.cancel();
    super.dispose();
  }

  Future<void> _initializeConnectivity() async {
    try {
      final ConnectivityResult connectivityResult =
          await Connectivity().checkConnectivity();
      _updateConnectionStatus(connectivityResult);

      _connectivitySubscription = Connectivity()
          .onConnectivityChanged
          .listen((result) => _updateConnectionStatus(result));
    } catch (e) {
      debugPrint('Connectivity initialization error: $e');
      // Default to offline mode if connectivity check fails
      if (mounted) {
        setState(() {
          _isOnline = false;
        });
      }
    }
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
    // Delay slightly to ensure connectivity check completes
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
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
    try {
      debugPrint('🔍 Attempting online query: $query');
      
      // Call the FastAPI backend with LLM
      final response = await _apiService.chat(
        message: query,
        userId: 'user_${DateTime.now().millisecondsSinceEpoch}',
        conversationId: _conversationId,
        speciesName: _currentSpeciesName,
      );

      debugPrint('✅ Response received successfully');

      // Update conversation ID
      if (response.containsKey('conversation_id')) {
        _conversationId = response['conversation_id'] as String?;
      }

      // Update species context if provided
      if (response.containsKey('species_context')) {
        _currentSpeciesName = response['species_context'] as String?;
      }

      final assistantMessage = response['response'] as String? ?? 
          'Sorry, I could not process your request.';

      setState(() {
        _messages.add({
          "message": assistantMessage,
          "isUser": false,
          "source": "AI Medical Assistant (LLM)",
          "timestamp": DateTime.now(),
        });
      });
    } catch (e) {
      debugPrint('❌ Online query error: $e');
      debugPrint('❌ Error type: ${e.runtimeType}');
      
      // Fallback to local response if API fails
      setState(() {
        _messages.add({
          "message": "I'm having trouble connecting to the AI assistant. Here's some general guidance: ${_searchLocalDatabase(query)}",
          "isUser": false,
          "source": "Local Database (Fallback)",
          "timestamp": DateTime.now(),
        });
      });
    }
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
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppTheme.lightTheme.colorScheme.surface,
      elevation: 2,
      shadowColor: AppTheme.shadowColor,
      leading: IconButton(
        icon: CustomIconWidget(
          iconName: 'arrow_back',
          color: AppTheme.lightTheme.primaryColor,
          size: 6.w,
        ),
        onPressed: () => Navigator.pushReplacementNamed(context, '/landing-page'),
      ),
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
}

class RefreshController {
  void refreshCompleted() {}
  void dispose() {}
}
