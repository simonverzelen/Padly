import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:padly/core/constants.dart';
import 'package:padly/core/route/route_constants.dart';
import 'package:padly/features/games/domain/entities/game.dart';
import 'package:padly/features/games/domain/services/game_share_service.dart';

class GameCreatedScreen extends StatelessWidget {
  final Game game;
  const GameCreatedScreen({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            children: [
              const Spacer(),
              const Icon(
                LucideIcons.trophy,
                size: 72,
                color: successColor,
              ),
              const SizedBox(height: 24),
              Text(
                'Match aangemaakt!',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              _MatchSummaryCard(game: game),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  icon: const Icon(LucideIcons.share2),
                  label: const Text('Deel match'),
                  onPressed: () => GameShareService().shareGame(game),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => Navigator.pushReplacementNamed(
                    context,
                    gameDetailScreenRoute,
                    arguments: {'game': game},
                  ),
                  child: const Text('Bekijk match'),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

class _MatchSummaryCard extends StatelessWidget {
  final Game game;
  const _MatchSummaryCard({required this.game});

  @override
  Widget build(BuildContext context) {
    final service = GameShareService();
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (game.club != null)
            _InfoRow(icon: LucideIcons.mapPin, text: game.club!),
          if (game.startTime != null)
            _InfoRow(
              icon: LucideIcons.calendar,
              text: service.formatDateTime(game.startTime!),
            ),
          if (game.rankingMin != null || game.rankingMax != null)
            _InfoRow(
              icon: LucideIcons.barChart2,
              text: '${game.rankingMin ?? ''} – ${game.rankingMax ?? ''}',
            ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;
  const _InfoRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Text(text, style: Theme.of(context).textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }
}
