import 'package:flutter/material.dart';

import '../../../../user_info/src/domain/padly_user.dart';

class GameDetailViewModel extends ChangeNotifier {
  final List<PadlyUser> _requests;

  List<PadlyUser> get requests => _requests;

  GameDetailViewModel({
    required List<PadlyUser> requests,
  }) : _requests = requests {
    load();
  }

  Future<void> load() async {
    notifyListeners();
  }
}
