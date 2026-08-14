import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Manages Platform-Specific Secure Window & Capture Protection
/// - Android: WindowManager.LayoutParams.FLAG_SECURE
/// - iOS: UIScreen.capturedDidChangeNotification & isCaptured state
class SecureWindowManager {
  static const MethodChannel _securityChannel = MethodChannel('com.edukkit.app/security');
  static const EventChannel _captureEventChannel = EventChannel('com.edukkit.app/screen_capture_events');

  static final SecureWindowManager _instance = SecureWindowManager._internal();
  factory SecureWindowManager() => _instance;
  SecureWindowManager._internal();

  bool _isSecureWindowEnabled = false;
  bool _isScreenCaptured = false;
  StreamSubscription? _captureSubscription;

  final _captureStateController = StreamController<bool>.broadcast();
  Stream<bool> get onScreenCaptureChanged => _captureStateController.stream;
  bool get isScreenCaptured => _isScreenCaptured;

  /// Initializes listeners for iOS screen recording / mirroring events
  void initialize() {
    if (kIsWeb) return;

    if (Platform.isIOS) {
      _captureSubscription?.cancel();
      _captureSubscription = _captureEventChannel.receiveBroadcastStream().listen(
        (event) {
          if (event is Map) {
            final type = event['type'];
            if (type == 'capture_changed' || type == 'initial_state') {
              final bool captured = event['isCaptured'] == true;
              _isScreenCaptured = captured;
              _captureStateController.add(captured);
              debugPrint('[Security] iOS Screen capture state changed: $captured');
            } else if (type == 'screenshot_taken') {
              debugPrint('[Security] iOS Screenshot notification received');
            }
          }
        },
        onError: (err) {
          debugPrint('[Security] Screen capture event stream error: $err');
        },
      );
    }
  }

  /// Enables FLAG_SECURE on Android when opening protected player screens
  Future<bool> enableSecureWindow() async {
    if (kIsWeb) return true;
    if (!Platform.isAndroid) return true;

    try {
      final res = await _securityChannel.invokeMethod<bool>('enableSecureWindow');
      _isSecureWindowEnabled = res ?? false;
      debugPrint('[Security] FLAG_SECURE enabled: $_isSecureWindowEnabled');
      return _isSecureWindowEnabled;
    } catch (e) {
      debugPrint('[Security] Failed to enable FLAG_SECURE: $e');
      return false;
    }
  }

  /// Disables FLAG_SECURE on Android when leaving protected player screens
  Future<bool> disableSecureWindow() async {
    if (kIsWeb) return true;
    if (!Platform.isAndroid) return true;

    try {
      final res = await _securityChannel.invokeMethod<bool>('disableSecureWindow');
      _isSecureWindowEnabled = false;
      debugPrint('[Security] FLAG_SECURE disabled');
      return res ?? false;
    } catch (e) {
      debugPrint('[Security] Failed to disable FLAG_SECURE: $e');
      return false;
    }
  }

  /// Checks if iOS screen is currently being captured (recording/AirPlay)
  Future<bool> checkIsCaptured() async {
    if (kIsWeb || !Platform.isIOS) return false;
    try {
      final isCaptured = await _securityChannel.invokeMethod<bool>('isScreenCaptured');
      _isScreenCaptured = isCaptured ?? false;
      return _isScreenCaptured;
    } catch (e) {
      debugPrint('[Security] Error checking screen capture status: $e');
      return false;
    }
  }

  /// Fetches platform security hardware signals
  Future<Map<String, dynamic>> getPlatformSecurityInfo() async {
    if (kIsWeb) return {'platform': 'Web', 'secure': false};
    try {
      final info = await _securityChannel.invokeMapMethod<String, dynamic>('getSecurityInfo');
      return info ?? {};
    } catch (e) {
      return {'error': e.toString()};
    }
  }

  void dispose() {
    _captureSubscription?.cancel();
    _captureStateController.close();
  }
}
