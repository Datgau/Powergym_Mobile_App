import 'package:uuid/uuid.dart';
import '../../../core/network/api.dart';
import '../models/chat_models.dart';

class AiChatService {
  static final AiChatService _instance = AiChatService._internal();
  factory AiChatService() => _instance;
  AiChatService._internal();

  String _sessionId = const Uuid().v4();

  String get sessionId => _sessionId;

  Future<ChatApiResponse> sendMessage(String message) async {
    try {
      final response = await Api.public.post('/chat/ask', data: {
        'message': message,
        'sessionId': _sessionId,
      });

      if (response.statusCode == 200) {
        return ChatApiResponse.fromJson(response.data);
      } else {
        throw Exception('Failed to send message: ${response.statusCode}');
      }
    } catch (e) {
      if (e.toString().contains('503')) {
        throw Exception('AI service is temporarily unavailable. Please try again later.');
      }
      throw Exception('Unable to connect to chatbot. Please try again later.');
    }
  }

  void resetSession() {
    _sessionId = const Uuid().v4();
  }
}