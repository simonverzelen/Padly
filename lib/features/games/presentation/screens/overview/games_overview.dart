import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:padly/core/components/custom_modal_bottom_sheet.dart';
import 'package:padly/core/constants.dart';
import 'package:padly/providers/providers.dart';
import 'package:padly/core/route/screen_export.dart';
import 'package:padly/features/games/games.dart';

class GamesOverview extends ConsumerWidget {
  const GamesOverview({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedSport = ref.watch(selectedSportProvider);
    final gamesAsync = ref.watch(gamesStreamProvider(selectedSport));
    final myGamesAsync = ref.watch(myGamesProvider);
    final currentUserAsync = ref.watch(currentUserProvider);
    final sportNamesAsync = ref.watch(sportNamesProvider);

    // Show full-screen spinner only on the very first load (no cached value yet).
    if (gamesAsync.isLoading && !gamesAsync.hasValue) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // Show error only when there is no cached data to fall back on.
    if (gamesAsync.hasError && !gamesAsync.hasValue) {
      return Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(defaultPadding),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  gamesAsync.error.toString(),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
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
        ),
      );
    }

    final games = gamesAsync.value ?? [];
    final currentUser = currentUserAsync.value;
    final availableSports = sportNamesAsync.value ?? [];

    final myGames = myGamesAsync.value ?? [];

    final screenWidth = MediaQuery.of(context).size.width;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: Column(
        children: [
          // Sticky greeting header
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: defaultPadding,
                vertical: defaultPadding,
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(3),
                    decoration: const BoxDecoration(
                      color: primaryColor,
                      shape: BoxShape.circle,
                    ),
                    child: CircleAvatar(
                      radius: 28,
                      backgroundColor: backgroundColor,
                      backgroundImage: currentUser?.imageUrl != null
                          ? NetworkImage(currentUser!.imageUrl!)
                          : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Hey ${currentUser?.firstName ?? 'Speler'} \u{1F44B}",
                        style: textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Row(
                        children: [
                          Text("Klaar voor een potje ",
                              style: textTheme.bodyMedium),
                          GestureDetector(
                            onTap: () => customModalBottomSheet(
                              context,
                              height: 420,
                              child: _SportPickerSheet(
                                sports: availableSports,
                                selectedSport: selectedSport,
                                onSportSelected: (sport) async {
                                  await ref
                                      .read(selectedSportProvider.notifier)
                                      .setSport(sport);
                                  // Sync preference to Supabase profile.
                                  ref
                                      .read(authBridgeProvider)
                                      .updateUserPreferences(sport: sport);
                                },
                              ),
                            ),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: primaryColor,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    selectedSport,
                                    style: textTheme.labelSmall?.copyWith(
                                      color: backgroundColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  const Icon(LucideIcons.chevronDown,
                                      size: 16, color: backgroundColor),
                                ],
                              ),
                            ),
                          ),
                          Text(" vandaag?", style: textTheme.bodyMedium),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          Expanded(
            child: RefreshIndicator(
              color: primaryColor,
              backgroundColor: backgroundColor,
              onRefresh: () async {
                // ignore: unused_result
                ref.refresh(gamesStreamProvider(selectedSport));
                // ignore: unused_result
                ref.refresh(myGamesProvider);
              },
              child: CustomScrollView(
                slivers: [
                  // Action buttons
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(
                        defaultPadding / 2,
                        defaultPadding,
                        defaultPadding / 2,
                        defaultPadding * 2,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: _ActionButton(
                              icon: LucideIcons.search,
                              label: 'Vind een match',
                              color: cardFeaturedBackgroundColor,
                              onTap: () => Navigator.pushNamed(
                                  context, findMatchScreenRoute),
                            ),
                          ),
                          const SizedBox(width: defaultPadding / 2),
                          Expanded(
                            child: _ActionButton(
                              icon: LucideIcons.plus,
                              label: 'Maak een match',
                              color: scrollBackgroundColor,
                              onTap: () async {
                                await Navigator.pushNamed(
                                    context, createGameScreenRoute);
                                // Refresh after returning from create screen.
                                if (context.mounted) {
                                  // ignore: unused_result
                                  ref.refresh(gamesStreamProvider(selectedSport));
                                  // ignore: unused_result
                                  ref.refresh(myGamesProvider);
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // My upcoming games
                  if (myGames.isNotEmpty) ...[
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(
                            defaultPadding / 2,
                            defaultPadding / 2,
                            defaultPadding / 2,
                            defaultPadding / 2),
                        child: Text(
                          "Komende Matches",
                          style: textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Padding(
                          padding:
                              const EdgeInsets.only(bottom: defaultPadding),
                          child: Row(
                            children: myGames
                                .map((g) => SizedBox(
                                      width: screenWidth * 0.7,
                                      child: GameCardFeatured(
                                        game: g,
                                        currentUser: currentUser,
                                        onReturn: () {
                                          // ignore: unused_result
                                          ref.refresh(gamesStreamProvider(selectedSport));
                                          // ignore: unused_result
                                          ref.refresh(myGamesProvider);
                                        },
                                      ),
                                    ))
                                .toList(),
                          ),
                        ),
                      ),
                    ),
                  ],

                  // All nearby games
                  if (games.isEmpty) ...[
                    const SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(child: Text('Geen matches gevonden')),
                    ),
                  ] else ...[
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(
                            defaultPadding / 2,
                            defaultPadding / 2,
                            defaultPadding / 2,
                            defaultPadding / 2),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Dichtstbijzijnde Matches",
                              style: textTheme.titleLarge
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            GestureDetector(
                              onTap: () => Navigator.pushNamed(
                                  context, findMatchScreenRoute),
                              child: Text(
                                "Bekijk Alles",
                                style: textTheme.bodyMedium
                                    ?.copyWith(color: whiteColor60),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) => GameCard(
                          game: games[index],
                          currentUser: currentUser,
                          onReturn: () {
                            // ignore: unused_result
                            ref.refresh(gamesStreamProvider(selectedSport));
                            // ignore: unused_result
                            ref.refresh(myGamesProvider);
                          },
                        ),
                        childCount: games.length,
                      ),
                    ),
                  ],

                  const SliverPadding(
                      padding: EdgeInsets.only(bottom: 100)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SportPickerSheet extends StatelessWidget {
  final List<String> sports;
  final String selectedSport;
  final void Function(String) onSportSelected;

  const _SportPickerSheet({
    required this.sports,
    required this.selectedSport,
    required this.onSportSelected,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
              defaultPadding, defaultPadding, defaultPadding, 8),
          child: Text(
            'Kies een sport',
            style:
                textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
        const Divider(color: cardBackgroundWithOpacity),
        Expanded(
          child: ListView(
            children: sports.map((sport) {
              final isSelected = sport == selectedSport;
              return ListTile(
                onTap: () {
                  onSportSelected(sport);
                  Navigator.pop(context);
                },
                title: Text(
                  sport,
                  style: textTheme.bodyLarge?.copyWith(
                    color: isSelected ? primaryColor : whiteColor,
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                trailing: isSelected
                    ? const Icon(LucideIcons.check, color: primaryColor)
                    : null,
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 160,
        padding: const EdgeInsets.all(defaultPadding),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(defaultBorderRadious / 2),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 28, color: whiteColor),
            const Spacer(),
            Text(
              label,
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
