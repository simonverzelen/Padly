import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:padly/constants.dart';
import 'package:padly/providers/providers.dart';
import 'package:padly/screens/games/games.dart';

class FindMatchScreen extends ConsumerWidget {
  const FindMatchScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedSport = ref.watch(selectedSportProvider);
    final gamesAsync = ref.watch(gamesStreamProvider(selectedSport));
    final currentUserAsync = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(
        surfaceTintColor: Colors.transparent,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft, size: 24, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: Text(
          "Vind een match",
          style: Theme.of(context)
              .textTheme
              .titleLarge
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
      ),
      body: _buildBody(context, ref, selectedSport, gamesAsync, currentUserAsync),
    );
  }

  Widget _buildBody(
    BuildContext context,
    WidgetRef ref,
    String selectedSport,
    AsyncValue<List<Game>> gamesAsync,
    AsyncValue currentUserAsync,
  ) {
    if (gamesAsync.isLoading && !gamesAsync.hasValue) {
      return const Center(child: CircularProgressIndicator());
    }

    if (gamesAsync.hasError && !gamesAsync.hasValue) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(defaultPadding),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                gamesAsync.error.toString(),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: defaultPadding),
              ElevatedButton(
                onPressed: () {
                  // ignore: unused_result
                  ref.refresh(gamesStreamProvider(selectedSport));
                },
                child: const Text('Opnieuw proberen'),
              ),
            ],
          ),
        ),
      );
    }

    final games = gamesAsync.value ?? [];
    final currentUser = currentUserAsync.value;

    if (games.isEmpty) {
      return const Center(child: Text('Geen matches gevonden'));
    }

    return RefreshIndicator(
      color: primaryColor,
      backgroundColor: backgroundColor,
      onRefresh: () async {
        // ignore: unused_result
        ref.refresh(gamesStreamProvider(selectedSport));
      },
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _FilterChipsBar(selectedSport: selectedSport)),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: defaultPadding,
                vertical: defaultPadding / 2,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Resultaten",
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const Icon(LucideIcons.slidersHorizontal, size: 24, color: Colors.white),
                ],
              ),
            ),
          ),
          SliverSafeArea(
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) => GameCard(
                  game: games[index],
                  currentUser: currentUser,
                  onReturn: () {
                    // ignore: unused_result
                    ref.refresh(gamesStreamProvider(selectedSport));
                  },
                ),
                childCount: games.length,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterChipsBar extends StatelessWidget {
  final String selectedSport;
  const _FilterChipsBar({required this.selectedSport});

  @override
  Widget build(BuildContext context) {
    final chips = [
      _FilterChip(label: selectedSport, isActive: true, hasDropdown: true),
      const _FilterChip(label: 'P400'),
      const _FilterChip(label: 'Heren'),
      const _FilterChip(label: '0 - 15 km'),
      const _FilterChip(label: '21 Jan - 30 Jan'),
    ];

    return Container(
      clipBehavior: Clip.hardEdge,
      margin: const EdgeInsets.symmetric(
        horizontal: defaultPadding / 2,
        vertical: defaultPadding,
      ),
      decoration: BoxDecoration(
        color: scrollBackgroundColor,
        borderRadius: BorderRadius.circular(defaultBorderRadious),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(
          vertical: defaultPadding,
          horizontal: defaultPadding / 3,
        ),
        child: Row(
          children: [
            for (int i = 0; i < chips.length; i++)
              Padding(
                padding: EdgeInsets.only(
                  left: i == 0 ? defaultPadding / 1.5 : defaultPadding / 2,
                  right: i == chips.length - 1 ? defaultPadding : 0,
                ),
                child: chips[i],
              ),
          ],
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isActive;
  final bool hasDropdown;

  const _FilterChip({
    required this.label,
    this.isActive = false,
    this.hasDropdown = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: isActive ? primaryColor : Colors.transparent,
        borderRadius: BorderRadius.circular(defaultBorderRadious),
        border: Border.all(color: primaryColor, width: 1.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: isActive ? backgroundColor : primaryColor,
                  fontWeight: FontWeight.w600,
                ),
          ),
          if (hasDropdown) ...[
            const SizedBox(width: 4),
            Icon(
              LucideIcons.chevronDown,
              size: 16,
              color: isActive ? backgroundColor : primaryColor,
            ),
          ],
        ],
      ),
    );
  }
}
