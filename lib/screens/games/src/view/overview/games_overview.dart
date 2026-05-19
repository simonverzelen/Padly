import 'package:flutter/material.dart';
import 'package:padly/components/category_button.dart';
import 'package:padly/constants.dart';
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
        final viewModel = context.watch<GamesOverviewViewmodel>();
        final games = viewModel.games;
        final myGames = viewModel.myGames;

        Widget body;

        if (viewModel.isLoading) {
          body = const Center(child: CircularProgressIndicator());
        } else if (viewModel.errorMessage != null) {
          body = Center(
            child: Padding(
              padding: const EdgeInsets.all(defaultPadding),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    viewModel.errorMessage!,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: defaultPadding),
                  ElevatedButton(
                    onPressed: viewModel.refresh,
                    child: const Text('Opnieuw proberen'),
                  ),
                ],
              ),
            ),
          );
        } else if (games.isEmpty) {
          body = const Center(
            child: Text('Geen matches gevonden'),
          );
        } else {
          body = RefreshIndicator(
            color: primaryColor,
            backgroundColor: backgroundColor,
            onRefresh: () async {
              await viewModel.refresh();
            },
            notificationPredicate: (_) => true,
            child: CustomScrollView(
              slivers: [
                const SliverToBoxAdapter(
                  child: Filters(),
                ),
                if (myGames.isNotEmpty) ...[
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(defaultPadding / 2),
                      child: Text(
                        "Mijn Matches",
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: RecommendedGames(games: myGames),
                  ),
                ],
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(defaultPadding / 2),
                    child: Text(
                      "Recommended",
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: RecommendedGames(games: games),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(defaultPadding / 2),
                    child: Text(
                      "Upcoming",
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                ),
                SliverSafeArea(
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        return GameCard(game: games[index]);
                      },
                      childCount: games.length,
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        return Scaffold(body: body);
      },
    );
  }
}

class RecommendedGames extends StatelessWidget {
  const RecommendedGames({
    super.key,
    required this.games,
  });

  final List<Game> games;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          ...List.generate(
            games.length,
            (index) => SizedBox(
              width: MediaQuery.of(context).size.width * 0.7,
              child: GameCardFeatured(game: games[index]),
            ),
          ),
        ],
      ),
    );
  }
}

class Filter {
  final String name;
  final String filter;
  final String? svgSrc;
  final String? route;

  Filter({
    required this.name,
    required this.filter,
    this.svgSrc,
    this.route,
  });
}

List<Filter> filters = [
  Filter(
    name: "Padel",
    filter: "padel",
  ),
  Filter(
    name: "Tennis",
    filter: "tennis",
  ),
  Filter(
    name: "Squash",
    filter: "squash",
  ),
  Filter(
    name: "Badminton",
    filter: "badminton",
  ),
  Filter(
    name: "Pickleball",
    filter: "pickleball",
  ),
  Filter(
    name: "Ping Pong",
    filter: "ping_pong",
  ),

  /*Filter(name: "Distance", filter: "distance"),
  Filter(name: "Start Time", filter: "start_time"),
  Filter(name: "End Time", filter: "end_time"),
  Filter(name: "Ranking", filter: "ranking"),
  Filter(name: "Price", filter: "price"),*/
];

class Filters extends StatelessWidget {
  const Filters({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        color: scrollBackgroundColor,
        borderRadius: BorderRadius.circular(defaultBorderRadious),
      ),
      margin: const EdgeInsets.symmetric(
        horizontal: defaultPadding / 2,
        vertical: defaultPadding,
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(
            vertical: defaultPadding, horizontal: defaultPadding / 3),
        child: Row(
          children: [
            ...List.generate(
              filters.length,
              (index) => Padding(
                padding: EdgeInsets.only(
                  left: index == 0 ? defaultPadding / 1.5 : defaultPadding / 2,
                  right: index == filters.length - 1 ? defaultPadding : 0,
                ),
                child: CategoryButton(
                  text: filters[index].name,
                  svgSrc: filters[index].svgSrc,
                  isActive: index == 0,
                  press: () {
                    if (filters[index].route != null) {
                      Navigator.pushNamed(context, filters[index].route!);
                    }
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
