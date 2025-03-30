import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class NotificationService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  Future<void> initialize() async {
    // Request permission (especially for iOS)
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
    print('User granted permission: ${settings.authorizationStatus}');

    // Get the FCM token and store it securely
    String? token = await _firebaseMessaging.getToken();
    print("FCM Token: $token");
    if (token != null) {
      await _secureStorage.write(key: 'fcm_token', value: token);
      // You can also send this token to your backend as part of login/registration
    }

    // Listen for foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Received a foreground message: ${message.notification?.body}');
      // Optionally, show a local notification (using flutter_local_notifications, for example)
    });
  }
}
