import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:okada/core/services/token_storage_service.dart';
import 'package:okada/providers/auth_providers.dart';

class WebSocketService {
  WebSocketChannel? _channel;
  final _messageController = StreamController<Map<String, dynamic>>.broadcast();
  final String _baseUrl;
  final TokenStorageService _tokenStorage;
  String? _userId;

  WebSocketService(this._baseUrl, this._tokenStorage);

  Stream<Map<String, dynamic>> get messages => _messageController.stream;

  void connect(String userId) async {
    _userId = userId;
    print('[WebSocketService] ===== STARTING WEBSOCKET CONNECTION =====');
    print('[WebSocketService] Starting connection for user: $userId');
    
    try {
      // Get JWT token from token storage
      final token = await _tokenStorage.getAccessToken();
      if (token == null) {
        print('[WebSocketService] ERROR: No JWT token available');
        return;
      }
      print('[WebSocketService] JWT token obtained successfully: ${token.substring(0, 20)}...');
      
      // Convert HTTP URL to WebSocket URL and ensure no /api prefix for WebSocket routes
      String wsUrl;
      String baseUrl = _baseUrl;
      print('[WebSocketService] Base URL: $baseUrl');
      // Remove /api suffix if present for WebSocket connections
      if (baseUrl.endsWith('/api')) {
        baseUrl = baseUrl.substring(0, baseUrl.length - 4);
        print('[WebSocketService] Removed /api suffix, new baseUrl: $baseUrl');
      } else if (baseUrl.endsWith('/api/')) {
        baseUrl = baseUrl.substring(0, baseUrl.length - 5);
        print('[WebSocketService] Removed /api/ suffix, new baseUrl: $baseUrl');
      }
      
      if (baseUrl.startsWith('http://')) {
        wsUrl = baseUrl.replaceFirst('http://', 'ws://');
      } else if (baseUrl.startsWith('https://')) {
        wsUrl = baseUrl.replaceFirst('https://', 'wss://');
      } else {
        print('[WebSocketService] ERROR: Invalid base URL: $baseUrl');
        return;
      }
      
      wsUrl = '$wsUrl/ws/notifications/?token=$token';
      print('[WebSocketService] Final WebSocket URL: $wsUrl');
      
      print('[WebSocketService] Attempting to connect to WebSocket...');
      _channel = WebSocketChannel.connect(Uri.parse(wsUrl));
      print('[WebSocketService] WebSocket channel created, listening for messages...');
      
      _channel!.stream.listen(
        (message) {
          print('[WebSocketService] Received raw message: $message');
          try {
            final data = json.decode(message);
            print('[WebSocketService] Parsed message: $data');
            _messageController.add(data);
          } catch (e) {
            print('[WebSocketService] Error parsing message: $e');
          }
        },
        onError: (error) {
          print('[WebSocketService] WebSocket error: $error');
          _reconnect();
        },
        onDone: () {
          print('[WebSocketService] WebSocket connection closed');
          _reconnect();
        },
      );
      
      print('[WebSocketService] ===== WEBSOCKET CONNECTION ESTABLISHED SUCCESSFULLY =====');
    } catch (e) {
      print('[WebSocketService] ERROR during connection: $e');
      _reconnect();
    }
  }

  void _reconnect() {
    if (_userId != null) {
      Future.delayed(const Duration(seconds: 5), () {
        print('[WebSocketService] Attempting to reconnect...');
        connect(_userId!);
      });
    }
  }

  void disconnect() {
    _channel?.sink.close();
    _channel = null;
    _userId = null;
  }

  void dispose() {
    disconnect();
    _messageController.close();
  }
}

final websocketServiceProvider = Provider<WebSocketService>((ref) {
  final baseUrl = dotenv.env['API_BASE_URL'] ?? 'MISSING_BASE_URL';
  final tokenStorage = ref.read(tokenStorageServiceProvider);
  return WebSocketService(baseUrl, tokenStorage);
}); 