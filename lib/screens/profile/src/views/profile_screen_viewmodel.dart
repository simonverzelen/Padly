import 'package:flutter/material.dart';
import 'package:padly/screens/user_info/src/domain/padly_user.dart';
import 'package:padly/screens/user_info/src/domain/user_service.dart';

class ProfileScreenViewModel with ChangeNotifier {
  final UserService _userService = UserService();

  PadlyUser? _user;
  PadlyUser? get user => _user;

  ProfileScreenViewModel() {
    init();
  }

  Future<void> init() async {
    _user = await _userService.getUser();
    notifyListeners();
  }
}
