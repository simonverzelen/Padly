import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:padly/features/games/domain/entities/game.dart';
import 'package:padly/features/games/presentation/screens/detail/game_created_screen.dart';

void main() {
  testWidgets('toont match aangemaakt heading', (tester) async {
    final game = Game(
      id: 'abc',
      club: 'Test Club',
      startTime: DateTime(2026, 6, 21, 18, 0),
      rankingMin: 'P300',
      rankingMax: 'P500',
    );

    await tester.pumpWidget(
      MaterialApp(home: GameCreatedScreen(game: game)),
    );

    expect(find.text('Match aangemaakt!'), findsOneWidget);
    expect(find.text('Test Club'), findsOneWidget);
  });

  testWidgets('bevat Deel match en Bekijk match knoppen', (tester) async {
    final game = Game(id: 'abc', club: 'Test Club');

    await tester.pumpWidget(
      MaterialApp(home: GameCreatedScreen(game: game)),
    );

    expect(find.text('Deel match'), findsOneWidget);
    expect(find.text('Bekijk match'), findsOneWidget);
  });
}
