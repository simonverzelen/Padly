import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:padly/constants.dart';
import 'package:padly/route/screen_export.dart';
import 'package:padly/screens/games/games.dart';
import 'package:provider/provider.dart';

import 'games_overview_viewmodel.dart';

class GamesOverview extends StatelessWidget {
  const GamesOverview({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => GamesOverviewViewmodel(),
      builder: (context, child) {
        final vm = context.watch<GamesOverviewViewmodel>();
        final games = vm.games;
        final myGames = vm.myGames;

        if (vm.isLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (vm.errorMessage != null) {
          return Scaffold(
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(defaultPadding),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      vm.errorMessage!,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: defaultPadding),
                    ElevatedButton(
                      onPressed: vm.refresh,
                      child: const Text('Opnieuw proberen'),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        if (games.isEmpty) {
          return const Scaffold(
            body: Center(child: Text('Geen matches gevonden')),
          );
        }

        final screenWidth = MediaQuery.of(context).size.width;
        final textTheme = Theme.of(context).textTheme;

        return Scaffold(
          body: RefreshIndicator(
            color: primaryColor,
            backgroundColor: backgroundColor,
            onRefresh: vm.refresh,
            child: CustomScrollView(
              slivers: [
                // Greeting header
                SliverToBoxAdapter(
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
                            backgroundImage:
                                vm.currentUser?.imageUrl != null
                                    ? NetworkImage(vm.currentUser!.imageUrl!)
                                    : null,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Hey ${vm.currentUser?.firstName ?? 'Speler'} \u{1F44B}",
                              style: textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Row(
                              children: [
                                Text(
                                  "Klaar voor een potje ",
                                  style: textTheme.bodyMedium,
                                ),
                                DropdownButton<String>(
                                  value: vm.selectedSport,
                                  underline: const SizedBox(),
                                  isDense: true,
                                  icon: const SizedBox.shrink(),
                                  dropdownColor: backgroundColor,
                                  onChanged: (value) {
                                    if (value != null) {
                                      vm.setSelectedSport(value);
                                    }
                                  },
                                  selectedItemBuilder: (context) {
                                    final sports = [
                                      'Padel',
                                      'Tennis',
                                      'Squash',
                                      'Badminton',
                                      'Pickleball',
                                      'Ping Pong',
                                    ];
                                    return sports.map((sport) {
                                      return Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: primaryColor,
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              vm.selectedSport,
                                              style: textTheme.labelSmall
                                                  ?.copyWith(
                                                color: backgroundColor,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const SizedBox(width: 4),
                                            Icon(
                                              Icons.keyboard_arrow_down,
                                              size: 16,
                                              color: backgroundColor,
                                            ),
                                          ],
                                        ),
                                      );
                                    }).toList();
                                  },
                                  items: const [
                                    'Padel',
                                    'Tennis',
                                    'Squash',
                                    'Badminton',
                                    'Pickleball',
                                    'Ping Pong',
                                  ]
                                      .map(
                                        (sport) => DropdownMenuItem<String>(
                                          value: sport,
                                          child: Text(
                                            sport,
                                            style: textTheme.bodyMedium
                                                ?.copyWith(
                                              color: whiteColor,
                                            ),
                                          ),
                                        ),
                                      )
                                      .toList(),
                                ),
                                Text(
                                  " vandaag?",
                                  style: textTheme.bodyMedium,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // Two big action buttons
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: defaultPadding,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: _ActionButton(
                            icon: 'assets/icons/Search.svg',
                            label: 'Vind een match',
                            color: cardFeaturedBackgroundColor,
                            onTap: () => Navigator.pushNamed(
                              context,
                              findMatchScreenRoute,
                            ),
                          ),
                        ),
                        const SizedBox(width: defaultPadding / 2),
                        Expanded(
                          child: _ActionButton(
                            icon: 'assets/icons/Plus1.svg',
                            label: 'Maak een match',
                            color: scrollBackgroundColor,
                            onTap: () => Navigator.pushNamed(
                              context,
                              createGameScreenRoute,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // "Komende Matches" section
                if (myGames.isNotEmpty) ...[
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
                            "Komende Matches",
                            style: textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          GestureDetector(
                            onTap: () => Navigator.pushNamed(
                              context,
                              findMatchScreenRoute,
                            ),
                            child: Text(
                              "Bekijk Alles",
                              style: textTheme.bodyMedium?.copyWith(
                                color: whiteColor60,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: myGames
                            .map(
                              (g) => SizedBox(
                                width: screenWidth * 0.7,
                                child: GameCardFeatured(game: g),
                              ),
                            )
                            .toList(),
                      ),
                    ),
                  ),
                ],

                // "Dichtstbijzijnde Matches" section
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
                          "Dichtstbijzijnde Matches",
                          style: textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        GestureDetector(
                          onTap: () => Navigator.pushNamed(
                            context,
                            findMatchScreenRoute,
                          ),
                          child: Text(
                            "Bekijk Alles",
                            style: textTheme.bodyMedium?.copyWith(
                              color: whiteColor60,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => GameCard(game: games[index]),
                    childCount: games.length,
                  ),
                ),

                const SliverPadding(
                  padding: EdgeInsets.only(bottom: 100),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String icon;
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
            SvgPicture.asset(
              icon,
              height: 28,
              colorFilter: const ColorFilter.mode(whiteColor, BlendMode.srcIn),
            ),
            const Spacer(),
            Text(
              label,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
