import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:stomp_dart_client/stomp_dart_client.dart';
import '../../../core/storage/auth_storage.dart';

/// STOMP/WebSocket connection for user-specific gym notifications.
///
/// Topics:
///   /topic/user/{id}/notifications  → realtime gym notifications
class UserWebSocketService {
  StompClient? _client;
  bool _connected = false;

  final AuthStorage _storage = AuthStorage();

  // Callbacks
  void Function(Map<String, dynamic> payload)? onNotification;
  void Function()? onConnected;
  void Function()? onDisconnected;

  bool get isConnected => _connected;

  Future<void> connect(String userId) async {
    if (_connected) return;

    final token = await _storage.getToken();
    final wsUrl = kIsWeb
        ? 'http://localhost:8080/ws'
        : 'http://10.0.2.2:8080/ws';

    _client = StompClient(
      config: StompConfig.sockJS(
        url: wsUrl,
        onConnect: (frame) => _onConnect(frame, userId),
        onDisconnect: (_) {
          _connected = false;
          debugPrint('[UserWS] Disconnected');
          onDisconnected?.call();
        },
        onWebSocketError: (e) {
          debugPrint('[UserWS] Error: $e');
          _connected = false;
        },
        onStompError: (frame) {
          debugPrint('[UserWS] STOMP error: ${frame.body}');
        },
        reconnectDelay: const Duration(seconds: 5),
        connectionTimeout: const Duration(seconds: 10),
        stompConnectHeaders: token != null ? {'Authorization': 'Bearer $token'} : {},
        webSocketConnectHeaders: token != null ? {'Authorization': 'Bearer $token'} : {},
      ),
    );

    _client!.activate();
    debugPrint('[UserWS] Connecting for user $userId');
  }

  void _onConnect(StompFrame frame, String userId) {
    _connected = true;
    debugPrint('[UserWS] Connected! Subscribing for user $userId');
    onConnected?.call();

    _client!.subscribe(
      destination: '/topic/user/$userId/notifications',
      callback: (frame) {
        if (frame.body == null) return;
        try {
          final json = jsonDecode(frame.body!) as Map<String, dynamic>;
          debugPrint('[UserWS] Notification: ${json['type']}');
          onNotification?.call(json);
        } catch (e) {
          debugPrint('[UserWS] Parse error: $e');
        }
      },
    );
  }

  void disconnect() {
    _client?.deactivate();
    _connected = false;
    debugPrint('[UserWS] Manually disconnected');
  }
}
