import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Dummy Push Notification Service (Firebase Removed - Offline/Demo Mode)
/// This file exists only to prevent any import/compile errors
/// No Firebase, no permissions, no background listeners
/// App runs perfectly without any notification setup
class PushNotificationService {
  /// Call this anywhere (e.g. main.dart) - it does nothing but prevents errors
  Future<void> setupInteractedMessage() async {
    // Firebase completely removed - no initialization needed
    // No permissions requested - safe for demo/offline use
    // No background listeners - prevents crashes
    print(
        "PushNotificationService: Firebase removed - running in offline/demo mode");
    return;
  }

  /// Dummy method - keeps old calls happy
  Future<void> registerNotificationListeners() async {
    // No action needed - safe placeholder
  }

  /// Dummy method - keeps old calls happy
  Future<void> enableIOSNotifications() async {
    // No action needed
  }

  /// Dummy channel - keeps old calls happy
  AndroidNotificationChannel androidNotificationChannel() {
    return const AndroidNotificationChannel(
      'silent_channel',
      'Silent Notifications',
      description: 'This channel is used only in demo mode',
      playSound: false,
      enableVibration: false,
      importance: Importance.low,
    );
  }

  /// Dummy permission request - does nothing
  Future<void> _requestPermissions() async {
    // No permissions requested - safe for demo
  }
}
