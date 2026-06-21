import 'package:flutter_test/flutter_test.dart';
import 'package:padly/features/games/domain/entities/game.dart';
import 'package:padly/features/games/domain/services/game_share_service.dart';

void main() {
  late GameShareService service;

  setUp(() => service = GameShareService());

  group('buildGameShareText', () {
    test('bevat club, tijd en deep link', () {
      final game = Game(
        id: 'abc123',
        club: 'Club Padel Antwerpen',
        startTime: DateTime(2026, 6, 21, 18, 0),
      );
      final text = service.buildGameShareText(game);
      expect(text, contains('Club Padel Antwerpen'));
      expect(text, contains('18:00'));
      expect(text, contains('padly://game/abc123'));
    });

    test('valt terug op location als club null is', () {
      final game = Game(
        id: 'abc123',
        location: 'Antwerpen',
        startTime: DateTime(2026, 6, 21, 18, 0),
      );
      final text = service.buildGameShareText(game);
      expect(text, contains('Antwerpen'));
      expect(text, contains('padly://game/abc123'));
    });

    test('valt terug op "een padelbaan" als club en location null zijn', () {
      final game = Game(id: 'xyz', startTime: DateTime(2026, 1, 1, 10, 0));
      final text = service.buildGameShareText(game);
      expect(text, contains('een padelbaan'));
      expect(text, contains('padly://game/xyz'));
    });
  });
}
