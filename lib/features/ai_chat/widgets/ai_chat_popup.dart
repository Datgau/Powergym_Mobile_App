import 'package:flutter/material.dart';
import '../models/chat_models.dart';
import '../services/ai_chat_service.dart';
import 'chat_bubble.dart';
import 'chat_cards.dart';

class AiChatPopup extends StatefulWidget {
  final Function(int)? onTabChange;
  
  const AiChatPopup({super.key, this.onTabChange});

  @override
  State<AiChatPopup> createState() => _AiChatPopupState();
}

class _AiChatPopupState extends State<AiChatPopup>
    with SingleTickerProviderStateMixin {
  final List<MessageWithCards> _messages = [];
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final AiChatService _aiChatService = AiChatService();
  bool _isLoading = false;
  bool _isVisible = false;

  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  static final ChatMessage _welcomeMessage = ChatMessage(
    role: 'assistant',
    content: 'Hello! I\'m PowerGym\'s AI Assistant. I can help you discover membership packages, gym services, trainers, and schedule workouts. How can I assist you today?',
    timestamp: DateTime.now(),
  );

  @override
  void initState() {
    super.initState();
    _messages.add(MessageWithCards(message: _welcomeMessage));
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _togglePopup() {
    setState(() {
      _isVisible = !_isVisible;
    });
    
    if (_isVisible) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }

  void _handleTabChange(int index) {
    // Close popup first
    _togglePopup();
    // Then change tab
    if (widget.onTabChange != null) {
      widget.onTabChange!(index);
    }
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
    return Stack(
      children: [
        // Floating Action Button
        if (!_isVisible)
          Positioned(
            bottom: 24,
            right: 24,
            child: Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF0999B8), Color(0xFF00B4FF), Color(0xFF1366BA)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF0999B8).withOpacity(0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: FloatingActionButton(
                onPressed: _togglePopup,
                backgroundColor: Colors.transparent,
                elevation: 0,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    const Icon(
                      Icons.psychology,
                      color: Colors.white,
                      size: 28,
                    ),
                    Positioned(
                      top: 0,
                      right: 0,
                      child: Transform.translate(
                        offset: const Offset(8, -8), // (x, y)
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.white, width: 1),
                          ),
                          child: const Text(
                            'Power AI',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 6,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

        // Chat Popup
        if (_isVisible)
          Positioned(
            bottom: 24,
            right: 24,
            child: AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                final screenWidth = MediaQuery.of(context).size.width;
                final screenHeight = MediaQuery.of(context).size.height;
                
                // Responsive sizing
                final popupWidth = screenWidth > 400 ? 380.0 : screenWidth - 48;
                final popupHeight = screenHeight > 650 ? 600.0 : screenHeight - 100;
                
                return Transform.scale(
                  scale: _scaleAnimation.value,
                  child: Opacity(
                    opacity: _fadeAnimation.value,
                    child: Container(
                      width: popupWidth,
                      height: popupHeight,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF0999B8), Color(0xFF00B4FF), Color(0xFF1366BA)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Container(
                        margin: const EdgeInsets.all(3), // Border width
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(17),
                        ),
                        child: Column(
                          children: [
                            // Header
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: const BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [Color(0xFF0999B8), Color(0xFF00B4FF), Color(0xFF1366BA)],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(17),
                                  topRight: Radius.circular(17),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: const Icon(
                                      Icons.smart_toy,
                                      color: Colors.white,
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
                                            color: Colors.white,
                                          ),
                                        ),
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.circle,
                                              color: Colors.greenAccent,
                                              size: 8,
                                            ),
                                            SizedBox(width: 4),
                                            Text(
                                              'Online',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.white70,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  // New Chat Button
                                  Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: IconButton(
                                      icon: const Icon(Icons.refresh, color: Colors.white, size: 18),
                                      onPressed: _newChat,
                                      tooltip: 'New conversation',
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  // Close Button
                                  Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: IconButton(
                                      icon: const Icon(Icons.close, color: Colors.white, size: 20),
                                      onPressed: _togglePopup,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Messages
                            Expanded(
                              child: Container(
                                decoration: const BoxDecoration(
                                  color: Color(0xFFF8F9FA),
                                ),
                                child: ListView.builder(
                                  controller: _scrollController,
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  itemCount: _messages.length + (_isLoading ? 1 : 0),
                                  itemBuilder: (context, index) {
                                    if (index == _messages.length && _isLoading) {
                                      return Container(
                                        padding: const EdgeInsets.all(16),
                                        child: Row(
                                          children: [
                                            Container(
                                              width: 20,
                                              height: 20,
                                              child: const CircularProgressIndicator(
                                                strokeWidth: 2,
                                                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF045668)),
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            const Text(
                                              'Processing...',
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
                                            child: Row(
                                              children: [
                                                Text(
                                                  '🏋️',
                                                  style: TextStyle(fontSize: 16),
                                                ),
                                                SizedBox(width: 8),
                                                Text(
                                                  'Recommended Services',
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.bold,
                                                    color: Color(0xFF045668),
                                                    letterSpacing: 0.5,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          ...messageWithCards.services!.asMap().entries.map((entry) {
                                            final index = entry.key;
                                            final service = entry.value;
                                            return AnimatedContainer(
                                              duration: Duration(milliseconds: 300 + (index * 100)),
                                              curve: Curves.easeOutBack,
                                              child: Padding(
                                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                                child: ServiceCardWidget(
                                                  service: service,
                                                  onTabChange: _handleTabChange,
                                                ),
                                              ),
                                            );
                                          }),
                                        ],

                                        // Membership cards
                                        if (messageWithCards.memberships != null && messageWithCards.memberships!.isNotEmpty) ...[
                                          const Padding(
                                            padding: EdgeInsets.fromLTRB(16, 12, 16, 8),
                                            child: Row(
                                              children: [
                                                Text(
                                                  '🎫',
                                                  style: TextStyle(fontSize: 16),
                                                ),
                                                SizedBox(width: 8),
                                                Text(
                                                  'Membership Packages',
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.bold,
                                                    color: Color(0xFF045668),
                                                    letterSpacing: 0.5,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          ...messageWithCards.memberships!.asMap().entries.map((entry) {
                                            final index = entry.key;
                                            final membership = entry.value;
                                            return AnimatedContainer(
                                              duration: Duration(milliseconds: 300 + (index * 100)),
                                              curve: Curves.easeOutBack,
                                              child: Padding(
                                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                                child: MembershipCardWidget(
                                                  membership: membership,
                                                  onTabChange: _handleTabChange,
                                                ),
                                              ),
                                            );
                                          }),
                                        ],

                                        // Trainer cards
                                        if (messageWithCards.trainers != null && messageWithCards.trainers!.isNotEmpty) ...[
                                          const Padding(
                                            padding: EdgeInsets.fromLTRB(16, 12, 16, 8),
                                            child: Row(
                                              children: [
                                                Text(
                                                  '👤',
                                                  style: TextStyle(fontSize: 16),
                                                ),
                                                SizedBox(width: 8),
                                                Text(
                                                  'Trainers',
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.bold,
                                                    color: Color(0xFF045668),
                                                    letterSpacing: 0.5,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          ...messageWithCards.trainers!.asMap().entries.map((entry) {
                                            final index = entry.key;
                                            final trainer = entry.value;
                                            return AnimatedContainer(
                                              duration: Duration(milliseconds: 300 + (index * 100)),
                                              curve: Curves.easeOutBack,
                                              child: Padding(
                                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                                child: TrainerCardWidget(
                                                  trainer: trainer,
                                                  onTabChange: _handleTabChange,
                                                ),
                                              ),
                                            );
                                          }),
                                        ],
                                      ],
                                    );
                                  },
                                ),
                              ),
                            ),

                            // Input area
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.only(
                                  bottomLeft: Radius.circular(17),
                                  bottomRight: Radius.circular(17),
                                ),
                                border: Border(
                                  top: BorderSide(color: Color(0xFFE2E8F0)),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF1F5F9),
                                        borderRadius: BorderRadius.circular(24),
                                        border: Border.all(
                                          color: const Color(0xFFE2E8F0),
                                        ),
                                      ),
                                      child: TextField(
                                        controller: _textController,
                                        keyboardType: TextInputType.multiline,
                                        textCapitalization: TextCapitalization.sentences,
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
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}