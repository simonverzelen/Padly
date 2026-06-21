import 'package:share_plus/share_plus.dart';
import 'package:padly/features/games/domain/entities/game.dart';

class GameShareService {
  static const _weekdays = ['ma', 'di', 'wo', 'do', 'vr', 'za', 'zo'];

  static const _months = [
    'jan', 'feb', 'mrt', 'apr', 'mei', 'jun',
    'jul', 'aug', 'sep', 'okt', 'nov', 'dec'
  ];

  Future<void> shareGame(Game game) async {
    if (game.id == null) return;
    await Share.share(buildGameShareText(game));
  }

  String buildGameShareText(Game game) {
    final venue = game.club ?? game.location ?? 'een padelbaan';
    final datePart = game.startTime != null ? _formatDate(game.startTime!) : '';
    final timePart = game.startTime != null ? _formatTime(game.startTime!) : '';
    final deepLink = game.id != null ? 'padly://game/${game.id}' : null;
    return deepLink != null
        ? 'Kom meespelen bij $venue op $datePart om $timePart! 🎾\n$deepLink'
        : 'Kom meespelen bij $venue op $datePart om $timePart! 🎾';
  }

  String formatDateTime(DateTime dt) => '${_formatDate(dt)} om ${_formatTime(dt)}';

  String _formatDate(DateTime dt) {
    final weekday = _weekdays[dt.weekday - 1];
    final month = _months[dt.month - 1];
    return '$weekday ${dt.day} $month';
  }

  String _formatTime(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }
}
