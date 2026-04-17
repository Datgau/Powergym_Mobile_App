import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:stomp_dart_client/stomp_dart_client.dart';
import '../../../core/storage/auth_storage.dart';
import '../models/trainer_models.dart';

/// Kết nối STOMP/WebSocket tới backend để nhận realtime events cho trainer.
///
/// Topics:
///   /topic/trainer/{id}/new-booking     → booking mới từ user
///   /topic/trainer/{id}/booking-updated → booking được accept/reject
class TrainerWebSocketService {
  StompClient? _client;
  bool _connected = false;

  final AuthStorage _storage = AuthStorage();

  // Callbacks
  void Function(TrainerBookingItem booking)? onNewBooking;
  void Function(TrainerBookingItem booking)? onBookingUpdated;
  void Function()? onConnected;
  void Function()? onDisconnected;

  bool get isConnected => _connected;

  Future<void> connect(String trainerId) async {
    if (_connected) return;

    final token = await _storage.getToken();

    // Android emulator: 10.0.2.2 → localhost; web: localhost
    final wsUrl = kIsWeb
        ? 'http://localhost:8080/ws'
        : 'http://10.0.2.2:8080/ws';

    _client = StompClient(
      config: StompConfig.sockJS(
        url: wsUrl,
        onConnect: (frame) => _onConnect(frame, trainerId),
        onDisconnect: (_) {
          _connected = false;
          debugPrint('[WS] Disconnected');
          onDisconnected?.call();
        },
        onWebSocketError: (e) {
          debugPrint('[WS] Error: $e');
          _connected = false;
        },
        onStompError: (frame) {
          debugPrint('[WS] STOMP error: ${frame.body}');
        },
        reconnectDelay: const Duration(seconds: 5),
        connectionTimeout: const Duration(seconds: 10),
        stompConnectHeaders: token != null
            ? {'Authorization': 'Bearer $token'}
            : {},
        webSocketConnectHeaders: token != null
            ? {'Authorization': 'Bearer $token'}
            : {},
      ),
    );

    _client!.activate();
    debugPrint('[WS] Connecting to $wsUrl for trainer $trainerId');
  }

  void _onConnect(StompFrame frame, String trainerId) {
    _connected = true;
    debugPrint('[WS] Connected! Subscribing for trainer $trainerId');
    onConnected?.call();

    // Subscribe: new booking
    _client!.subscribe(
      destination: '/topic/trainer/$trainerId/new-booking',
      callback: (frame) {
        if (frame.body == null) return;
        try {
          final json = jsonDecode(frame.body!) as Map<String, dynamic>;
          final booking = TrainerBookingItem.fromWebSocketJson(json);
          debugPrint('[WS] New booking: ${booking.bookingId}');
          onNewBooking?.call(booking);
        } catch (e) {
          debugPrint('[WS] Parse error (new-booking): $e');
        }
      },
    );

    // Subscribe: booking updated (accept/reject)
    _client!.subscribe(
      destination: '/topic/trainer/$trainerId/booking-updated',
      callback: (frame) {
        if (frame.body == null) return;
        try {
          final json = jsonDecode(frame.body!) as Map<String, dynamic>;
          final booking = TrainerBookingItem.fromWebSocketJson(json);
          debugPrint('[WS] Booking updated: ${booking.bookingId} → ${booking.status}');
          onBookingUpdated?.call(booking);
        } catch (e) {
          debugPrint('[WS] Parse error (booking-updated): $e');
        }
      },
    );
  }

  void disconnect() {
    _client?.deactivate();
    _connected = false;
    debugPrint('[WS] Manually disconnected');
  }
}
