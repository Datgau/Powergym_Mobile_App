import 'package:flutter/material.dart';
import '../models/chat_models.dart';
import '../services/ai_chat_service.dart';
import '../widgets/chat_bubble.dart';
import '../widgets/chat_cards.dart';

class AiChatScreen extends StatefulWidget {
  const AiChatScreen({super.key});

  @override
  State<AiChatScreen> createState() => _AiChatScreenState();
}

class _AiChatScreenState extends State<AiChatScreen> {
  final List<MessageWithCards> _messages = [];
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final AiChatService _aiChatService = AiChatService();
  bool _isLoading = false;

  static final ChatMessage _welcomeMessage = ChatMessage(
    role: 'assistant',
    content: 'Hello! I am the AI assistant of PowerGym. I can help you explore membership packages, gym services, personal trainers, and booking training sessions. What do you need help with today?',    timestamp: DateTime.now(),
  );

  @override
  void initState() {
    super.initState();
    _messages.add(MessageWithCards(message: _welcomeMessage));
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
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

  Future<void> _sendMessage() async {
    final text = _textController.text.trim();
    if (text.isEmpty || _isLoading) return;

    // Add user message
    final userMessage = ChatMessage(
      role: 'user',
      content: text,
      timestamp: DateTime.now(),
    );

    setState(() {
      _messages.add(MessageWithCards(message: userMessage));
      _isLoading = true;
    });

    _textController.clear();
    _scrollToBottom();

    try {
      final response = await _aiChatService.sendMessage(text);
      
      final assistantMessage = ChatMessage(
        role: 'assistant',
        content: response.text,
        timestamp: DateTime.now(),
      );

      setState(() {
        _messages.add(MessageWithCards(
          message: assistantMessage,
          services: response.services,
          memberships: response.memberships,
          trainers: response.trainers,
        ));
        _isLoading = false;
      });

      _scrollToBottom();
    } catch (e) {
      final errorMessage = ChatMessage(
        role: 'assistant',
        content: e.toString(),
        timestamp: DateTime.now(),
      );

      setState(() {
        _messages.add(MessageWithCards(message: errorMessage));
        _isLoading = false;
      });

      _scrollToBottom();
    }
  }

  void _newChat() {
    _aiChatService.resetSession();
    setState(() {
      _messages.clear();
      _messages.add(MessageWithCards(
        message: ChatMessage(
          role: 'assistant',
          content: _welcomeMessage.content,
          timestamp: DateTime.now(),
        ),
      ));
    });
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFF045668).withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.smart_toy,
                color: Color(0xFF045668),
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'PowerGym AI Assistant',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  Row(
                    children: [
                      Icon(
                        Icons.circle,
                        color: Colors.green,
                        size: 8,
                      ),
                      SizedBox(width: 4),
                      Text(
                        'Active',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Color(0xFF045668)),
            onPressed: _newChat,
            tooltip: 'New chat',
          ),
        ],
      ),
      body: Column(
        children: [
          // Messages
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(vertical: 16),
              itemCount: _messages.length + (_isLoading ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == _messages.length && _isLoading) {
                  return const Padding(
                    padding: EdgeInsets.all(16),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF045668)),
                          ),
                        ),
                        SizedBox(width: 12),
                        Text(
                          'Loading...',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                final messageWithCards = _messages[index];
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Chat bubble
                    ChatBubble(message: messageWithCards.message),
                    
                    // Service cards
                    if (messageWithCards.services != null && messageWithCards.services!.isNotEmpty) ...[
                      const Padding(
                        padding: EdgeInsets.fromLTRB(16, 12, 16, 8),
                        child: Text(
                          '🏋️ Recommended services',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      ...messageWithCards.services!.map((service) => 
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: ServiceCardWidget(service: service),
                        ),
                      ),
                    ],

                    // Membership cards
                    if (messageWithCards.memberships != null && messageWithCards.memberships!.isNotEmpty) ...[
                      const Padding(
                        padding: EdgeInsets.fromLTRB(16, 12, 16, 8),
                        child: Text(
                          '🎫 Membership package',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      ...messageWithCards.memberships!.map((membership) => 
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: MembershipCardWidget(membership: membership),
                        ),
                      ),
                    ],

                    // Trainer cards
                    if (messageWithCards.trainers != null && messageWithCards.trainers!.isNotEmpty) ...[
                      const Padding(
                        padding: EdgeInsets.fromLTRB(16, 12, 16, 8),
                        child: Text(
                          '👤 Trainer',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      ...messageWithCards.trainers!.map((trainer) => 
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: TrainerCardWidget(trainer: trainer),
                        ),
                      ),
                    ],
                  ],
                );
              },
            ),
          ),

          // Input area
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                top: BorderSide(color: Colors.grey[200]!),
              ),
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: TextField(
                        controller: _textController,
                        decoration: const InputDecoration(
                          hintText: 'Type a message...',
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                        maxLines: null,
                        textInputAction: TextInputAction.send,
                        onSubmitted: (_) => _sendMessage(),
                        enabled: !_isLoading,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF0999B8), Color(0xFF1366BA)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.send, color: Colors.white),
                      onPressed: _isLoading ? null : _sendMessage,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}