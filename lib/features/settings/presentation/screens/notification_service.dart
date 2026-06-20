import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:padly/features/users/domain/services/user_service.dart';

import 'package:padly/features/auth/domain/services/auth_service.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:http/http.dart' as http;

class PushNotifications {
  final AuthService _authService = AuthService();
  final UserService _userService = UserService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late FirebaseMessaging _firebaseMessaging;
  static final FlutterLocalNotificationsPlugin
      _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  PushNotifications({required FirebaseMessaging firebaseMessaging})
      : _firebaseMessaging = firebaseMessaging;

  // request notification permission
  Future<void> init() async {
    await _firebaseMessaging.requestPermission(
      alert: true,
      announcement: true,
      badge: true,
      carPlay: false,
      criticalAlert: true,
      provisional: false,
      sound: true,
    );

    await _getDeviceToken();

    _firebaseMessaging.getInitialMessage().then((RemoteMessage? message) {
      if (message != null) {
        print(message);
        // Handle notification that opened the app
      }
    });
  }

  static Future localNotiInit(navigatorKey) async {
    void onNotificationTap(NotificationResponse notificationResponse) {
      navigatorKey.currentState!
          .pushNamed("/message", arguments: notificationResponse);
    }

    // initialise the plugin. app_icon needs to be a added as a drawable resource to the Android head project
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    final DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings();

    final InitializationSettings initializationSettings =
        InitializationSettings(
            android: initializationSettingsAndroid,
            iOS: initializationSettingsDarwin);

    // request notification permissions for android 13 or above
    _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()!
        .requestNotificationsPermission();

    _flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onDidReceiveNotificationResponse: onNotificationTap,
        onDidReceiveBackgroundNotificationResponse: onNotificationTap);

    // on tap local notification in foreground
  }

  Future<void> _saveTokentoFirestore({required String token}) async {
    bool isUserLoggedin = await _authService.isLoggedIn();

    print("User is logged in $isUserLoggedin");
    if (isUserLoggedin) {
      String? token = await _firebaseMessaging.getToken();
      print("FCM Token: $token");
      await _userService.saveUserToken(token);
      print("save to firestore");
    }
    // also save if token changes
    _firebaseMessaging.onTokenRefresh.listen((event) async {
      if (isUserLoggedin) {
        await _userService.saveUserToken(token);
        print("save to firestore");
      }
    });
  }

  // get the fcm device token
  Future<void> _getDeviceToken({int maxRetires = 3}) async {
    try {
      String? token;
      token = await _firebaseMessaging.getToken();
      await _saveTokentoFirestore(token: token!);
    } catch (e) {
      print("failed to get device token");
      if (maxRetires > 0) {
        print("try after 1 sec");
        await Future.delayed(Duration(seconds: 1));
        await _getDeviceToken(maxRetires: maxRetires - 1);
      }
    }
  }

  // show a simple notification
  Future<void> showSimpleNotification({
    required notification,
    required android,
    required payload,
  }) async {
    if (notification != null && android != null) {
      _flutterLocalNotificationsPlugin.show(
        DateTime.now().millisecondsSinceEpoch ~/ 1000, // Safe unique int ID
        notification?.title ?? "",
        notification?.body ?? "",
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'io.padly',
            'Padly',
            channelDescription: 'Padly Notifications',
            importance: Importance.max,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
          ),
        ),
        payload: payload,
      );
    } else {
      print('Notification or Android info missing in message:');
    }
  }
}
