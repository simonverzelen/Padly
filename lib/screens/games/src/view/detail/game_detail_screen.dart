import 'package:avatar_stack/avatar_stack.dart';
import 'package:avatar_stack/positions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:padly/components/category_button.dart';
import 'package:padly/constants.dart';
import 'package:padly/route/screen_export.dart';
import 'package:provider/provider.dart';

import '../../domain/game.dart';
import 'game_detail_viewmodel.dart';

class GameDetailScreen extends StatelessWidget {
  final Game game;

  const GameDetailScreen({
    super.key,
    required this.game,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => GameDetailViewModel(
        game: game,
      ),
      child: const GameDetailBody(),
    );
  }
}

class GameDetailBody extends StatelessWidget {
  const GameDetailBody({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Neem deel aan de match',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        centerTitle: true,
        forceMaterialTransparency: true,
      ),
      body: const CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Location(),
                _RequestPlayers(),
                _CurrentPlayers(),
                _Buttons(),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(defaultPadding),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(32)),
              ),
              // TODO: implement actual join-game logic
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Functie komt binnenkort beschikbaar'),
                  ),
                );
              },
              child: const Text('Deelnemen'),
            ),
          ),
        ),
      ),
    );
  }
}

class _Location extends StatelessWidget {
  const _Location();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<GameDetailViewModel>();
    final game = vm.game;
    final String gameRank =
        '${game.rankingMin ?? '-'} - ${game.rankingMax ?? '-'}';
    final startTime =
        game.startTime != null ? DateFormat.Hm().format(game.startTime!) : '';
    final String playTime =
        (game.endTime != null && game.startTime != null)
            ? '${game.endTime!.difference(game.startTime!).inMinutes}'
            : '-';

    return Card(
      color: cardBackgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(defaultBorderRadious / 2),
      ),
      elevation: 0,
      margin: const EdgeInsets.symmetric(
        horizontal: defaultPadding / 2,
        vertical: defaultPadding,
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          defaultPadding,
          defaultPadding,
          defaultPadding,
          defaultPadding / 2,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      game.club ?? '',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: defaultPadding),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        SvgPicture.asset(
                          "assets/icons/Location.svg",
                          height: 14,
                          colorFilter: ColorFilter.mode(
                              Colors.grey.shade500, BlendMode.srcIn),
                        ),
                        const SizedBox(width: defaultPadding / 2),
                        Text(
                          game.location ?? '',
                          style: Theme.of(context).textTheme.labelMedium,
                        ),
                        const SizedBox(width: defaultPadding / 4),
                        Text(
                          '${game.distanceKm} km',
                          style: Theme.of(context)
                              .textTheme
                              .labelMedium!
                              .copyWith(
                                  color: Colors.grey.shade500, fontSize: 11),
                        ),
                      ],
                    ),
                    const SizedBox(height: defaultPadding / 4),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        SvgPicture.asset(
                          "assets/icons/Clock.svg",
                          height: 14,
                          colorFilter: ColorFilter.mode(
                              Colors.grey.shade500, BlendMode.srcIn),
                        ),
                        const SizedBox(width: defaultPadding / 2),
                        Text(
                          "${game.date != null ? DateFormat('EEE d MMM').format(game.date!) : ''} - $startTime",
                          style: Theme.of(context).textTheme.labelMedium,
                        ),
                        const SizedBox(width: defaultPadding / 4),
                        Text(
                          '$playTime min',
                          style: Theme.of(context)
                              .textTheme
                              .labelMedium!
                              .copyWith(
                                  color: Colors.grey.shade500, fontSize: 11),
                        ),
                      ],
                    ),
                  ],
                ),
                Spacer(),
                Container(
                  decoration: BoxDecoration(
                    color: (game.lat != null && game.lng != null)
                        ? primaryColor
                        : Colors.grey.shade700,
                    borderRadius: const BorderRadius.all(
                        Radius.circular(defaultBorderRadious / 4)),
                  ),
                  child: IconButton(
                    onPressed: (game.lat != null && game.lng != null)
                        ? () => showNavigationOptions(
                              context,
                              lat: game.lat!,
                              lng: game.lng!,
                              label: game.club ?? '',
                            )
                        : null,
                    icon: SvgPicture.asset(
                      "assets/icons/Location.svg",
                      height: 24,
                      colorFilter: const ColorFilter.mode(
                        blackColor,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                )
              ],
            ),
            const SizedBox(height: defaultPadding),
            Row(
              children: [
                Chip(
                  backgroundColor: whiteColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(defaultPadding * 2),
                  ),
                  label: Text(
                    "Padel",
                    style: Theme.of(context).textTheme.labelSmall!.copyWith(
                        color: backgroundColor, fontWeight: FontWeight.w700),
                  ),
                ),
                const SizedBox(width: defaultPadding / 4),
                Chip(
                  backgroundColor: whiteColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(defaultPadding * 2),
                  ),
                  label: Text(
                    gameRank,
                    style: Theme.of(context).textTheme.labelSmall!.copyWith(
                        color: backgroundColor, fontWeight: FontWeight.w700),
                  ),
                ),
                const Spacer(),
                Chip(
                  backgroundColor: whiteColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(defaultPadding * 2),
                  ),
                  label: Text(
                    "€ ${game.pricePerHour}",
                    style: Theme.of(context).textTheme.labelSmall!.copyWith(
                        color: backgroundColor, fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _RequestPlayers extends StatelessWidget {
  const _RequestPlayers();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<GameDetailViewModel>();
    final game = vm.game;
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, gameRequestsScreenRoute,
          arguments: game.currentPlayers),
      child: Card(
        color: cardBackgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(defaultBorderRadious / 2),
        ),
        elevation: 0,
        margin: const EdgeInsets.symmetric(
          horizontal: defaultPadding / 2,
          vertical: defaultPadding,
        ),
        child: Padding(
          padding: const EdgeInsets.all(defaultPadding),
          child: Flex(
            direction: Axis.horizontal,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: 120,
                child: Stack(
                  children: [
                    _PlayerList(game: game),
                  ],
                ),
              ),
              const Spacer(),
              const SizedBox(width: defaultPadding),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Verzoeken',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  SizedBox(
                    width: 150,
                    child: Text(
                      'Bekijk spelers die wensen deel te nemen',
                      style: Theme.of(context).textTheme.labelMedium!.copyWith(
                            color: Colors.grey.shade500,
                          ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const Icon(
                Icons.chevron_right,
                size: defaultPadding * 2,
              )
            ],
          ),
        ),
      ),
    );
  }
}

class _PlayerList extends StatelessWidget {
  final Game game;

  const _PlayerList({
    required this.game,
  });

  @override
  Widget build(BuildContext context) {
    final settings = RestrictedPositions(
      maxCoverage: 0.4,
      minCoverage: 0.25,
      laying: StackLaying.first,
    );
    return SizedBox(
      height: 48,
      child: WidgetStack(
        positions: settings,
        stackedWidgets: [
          for (int i = (game.currentPlayers ?? []).length - 1; i >= 0; i--)
            Container(
              padding: const EdgeInsets.all(defaultPadding / 8),
              decoration: const BoxDecoration(
                color: whiteColor80, // Border color
                shape: BoxShape.circle,
              ),
              child: CircleAvatar(
                radius: 24,
                backgroundColor: pillBackgroundColor,
                backgroundImage: i < (game.currentPlayers ?? []).length &&
                        (game.currentPlayers ?? [])[i].imageUrl != null
                    ? NetworkImage((game.currentPlayers ?? [])[i].imageUrl!)
                    : null,
              ),
            )
        ],
        buildInfoWidget: (surplus, _) => CircleAvatar(
          radius: 24,
          backgroundColor: pillBackgroundColor,
          child: Text(
            '+$surplus',
          ),
        ),
      ),
    );
  }
}

class _CurrentPlayers extends StatelessWidget {
  const _CurrentPlayers();

  @override
  Widget build(BuildContext context) {
    return Card(
      color: cardBackgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(defaultBorderRadious / 2),
      ),
      elevation: 0,
      margin: const EdgeInsets.symmetric(
        horizontal: defaultPadding / 2,
        vertical: defaultPadding,
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          defaultPadding,
          defaultPadding,
          defaultPadding,
          defaultPadding / 2,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Spelers",
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: defaultPadding),
            const _CurrentPlayersList(),
          ],
        ),
      ),
    );
  }
}

class _CurrentPlayersList extends StatelessWidget {
  const _CurrentPlayersList();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<GameDetailViewModel>();
    final game = vm.game;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        for (int i = 0; i < 4; i++) ...[
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(defaultPadding / 8),
                decoration: BoxDecoration(
                  color: i < (game.currentPlayers ?? []).length
                      ? whiteColor80
                      : null, // Border color
                  shape: BoxShape.circle,
                ),
                child: CircleAvatar(
                  radius: 36,
                  backgroundColor: pillBackgroundColor,
                  backgroundImage: i < (game.currentPlayers ?? []).length &&
                          (game.currentPlayers ?? [])[i].imageUrl != null
                      ? NetworkImage((game.currentPlayers ?? [])[i].imageUrl!)
                      : null,
                ),
              ),
              if (i < (game.currentPlayers ?? []).length) ...[
                const SizedBox(height: defaultPadding / 4),
                Text((game.currentPlayers ?? [])[i].firstName ?? '',
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall!
                        .copyWith(fontWeight: FontWeight.w600)),
                Transform(
                  transform: Matrix4.identity()
                    ..scale(0.8)
                    ..translate(8.0, 0.0),
                  child: Chip(
                    labelPadding: const EdgeInsets.symmetric(horizontal: 5),
                    backgroundColor: whiteColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: const BorderSide(color: Colors.transparent),
                    ),
                    label: Text(
                      (game.currentPlayers ?? [])[i].rank ?? '',
                      style: Theme.of(context).textTheme.labelSmall!.copyWith(
                            color: backgroundColor,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                  ),
                ),
              ] else ...[
                const SizedBox(height: defaultPadding / 4),
                Text('Open',
                    style: Theme.of(context).textTheme.bodySmall!.copyWith(
                          fontWeight: FontWeight.w600,
                          color: Colors.white54,
                        )),
              ]
            ],
          ),
        ],
      ],
    );
  }
}

class _Buttons extends StatelessWidget {
  const _Buttons();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: defaultPadding),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CategoryButton(
            text: "Open Chat",
            svgSrc: "assets/icons/Chat.svg",
            press: () => {},
            isActive: true,
          ),
          const SizedBox(width: defaultPadding),
          CategoryButton(
            text: "Voeg Toe Aan Kalender",
            svgSrc: "assets/icons/Calender.svg",
            press: () => {},
            isActive: false,
          ),
        ],
      ),
    );
  }
}
