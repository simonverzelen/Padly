import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:padly/screens/user_info/src/domain/padly_user.dart';
import 'package:padly/screens/user_info/src/domain/user_service.dart';
import 'package:permission_handler/permission_handler.dart';

class ProfileScreenViewModel with ChangeNotifier {
  final UserService _userService = UserService();

  PadlyUser? _user;
  PadlyUser? get user => _user;

  bool notificationsEnabled = false;
  bool locationEnabled = false;

  ProfileScreenViewModel() {
    init();
  }

  Future<void> init() async {
    _user = await _userService.getUser();
    await checkPermissions();
    notifyListeners();
  }

  Future<void> checkPermissions() async {
    final notifSettings =
        await FirebaseMessaging.instance.getNotificationSettings();
    notificationsEnabled =
        notifSettings.authorizationStatus == AuthorizationStatus.authorized;
    locationEnabled = await Permission.location.isGranted;
    notifyListeners();
  }
}
