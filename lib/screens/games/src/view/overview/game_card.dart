import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:padly/constants.dart';
import 'package:padly/route/screen_export.dart';
import 'package:padly/screens/games/games.dart';

class GameCard extends StatelessWidget {
  final Game game;

  const GameCard({
    super.key,
    required this.game,
  });

  @override
  Widget build(BuildContext context) {
    final String gameRank = {game.rankingMin, game.rankingMax}.join(' - ');
    final startDate = DateFormat('EEE d MMM').format(game.date!);
    final startTime =
        game.startTime != null ? DateFormat.Hm().format(game.startTime!) : '';

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
        padding: const EdgeInsets.symmetric(
            vertical: defaultPadding / 2, horizontal: defaultPadding),
        child: Column(
          children: [
            _GameInfoChips(
              startDate: startDate,
              startTime: startTime,
              gameRank: gameRank,
            ),
            const SizedBox(height: defaultPadding / 2),
            _GameCardBody(game: game),
            const SizedBox(height: defaultPadding / 2),
            _GameCardFooter(game: game),
          ],
        ),
      ),
    );
  }
}

class GameCardFeatured extends StatelessWidget {
  final Game game;

  const GameCardFeatured({
    super.key,
    required this.game,
  });

  @override
  Widget build(BuildContext context) {
    final String gameRank = {game.rankingMin, game.rankingMax}.join(' - ');
    final startDate = DateFormat('EEE d MMM').format(game.date!);
    final startTime =
        game.startTime != null ? DateFormat.Hm().format(game.startTime!) : '';

    return Card(
      color: cardFeaturedBackgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(defaultBorderRadious / 2),
      ),
      elevation: 0,
      margin: const EdgeInsets.symmetric(
        horizontal: defaultPadding / 2,
        vertical: defaultPadding,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
            vertical: defaultPadding / 2, horizontal: defaultPadding),
        child: Column(
          children: [
            _GameInfoChips(
              startDate: startDate,
              startTime: startTime,
              gameRank: gameRank,
              isDense: true,
            ),
            const SizedBox(height: defaultPadding / 2),
            _GameCardBody(game: game, isDense: true),
            const SizedBox(height: defaultPadding / 2),
            _GameCardFooter(game: game, isDense: true),
          ],
        ),
      ),
    );
  }
}

class _GameCardBody extends StatelessWidget {
  final Game game;
  final bool isDense;

  const _GameCardBody({
    required this.game,
    this.isDense = false,
  });

  @override
  Widget build(BuildContext context) {
    return isDense
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                game.club ?? '',
                style: Theme.of(context).textTheme.titleMedium,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
              const SizedBox(height: defaultPadding / 2),
              _LocationInfo(game: game, isDense: isDense),
              const SizedBox(height: defaultPadding),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _HostPlayer(game: game, isDense: true),
                ],
              ),
            ],
          )
        : Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      game.club ?? '',
                      style: Theme.of(context).textTheme.titleMedium,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                    const SizedBox(height: defaultPadding / 2),
                    _LocationInfo(game: game),
                  ],
                ),
              ),
              const SizedBox(width: defaultPadding / 2),
              _HostPlayer(game: game),
            ],
          );
  }
}

class _LocationInfo extends StatelessWidget {
  final Game game;
  final bool isDense;

  const _LocationInfo({
    required this.game,
    this.isDense = false,
  });

  @override
  Widget build(BuildContext context) {
    final startTime =
        game.startTime != null ? DateFormat.Hm().format(game.startTime!) : '';
    final int playTime = game.endTime!.difference(game.startTime!).inMinutes;

    return isDense
        ? Wrap(
            crossAxisAlignment: WrapCrossAlignment.end,
            spacing: defaultPadding / 2,
            children: [
              Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: defaultPadding / 4,
                children: [
                  Text(
                    game.location ?? '',
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                  Text(
                    '${game.distanceKm} km',
                    style: Theme.of(context)
                        .textTheme
                        .labelMedium!
                        .copyWith(color: Colors.grey.shade500, fontSize: 10),
                  ),
                ],
              ),
              Wrap(
                crossAxisAlignment: WrapCrossAlignment.end,
                spacing: defaultPadding / 4,
                children: [
                  Text(
                    startTime,
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                  Text(
                    '$playTime min',
                    style: Theme.of(context)
                        .textTheme
                        .labelMedium!
                        .copyWith(color: Colors.grey.shade500, fontSize: 10),
                  ),
                ],
              ),
              Text(
                '€ ${game.pricePerHour}',
                style: Theme.of(context).textTheme.labelMedium,
              ),
            ],
          )
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  SvgPicture.asset(
                    "assets/icons/Location.svg",
                    height: 14,
                    colorFilter:
                        ColorFilter.mode(Colors.grey.shade500, BlendMode.srcIn),
                  ),
                  const SizedBox(width: defaultPadding / 2),
                  Flexible(
                    child: Text(
                      game.location ?? '',
                      style: Theme.of(context).textTheme.labelMedium,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                  const SizedBox(width: defaultPadding / 4),
                  Text(
                    '${game.distanceKm} km',
                    style: Theme.of(context)
                        .textTheme
                        .labelMedium!
                        .copyWith(color: Colors.grey.shade500, fontSize: 10),
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
                    colorFilter:
                        ColorFilter.mode(Colors.grey.shade500, BlendMode.srcIn),
                  ),
                  const SizedBox(width: defaultPadding / 2),
                  Text(
                    startTime,
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                  const SizedBox(width: defaultPadding / 4),
                  Text(
                    '$playTime min',
                    style: Theme.of(context)
                        .textTheme
                        .labelMedium!
                        .copyWith(color: Colors.grey.shade500, fontSize: 10),
                  ),
                ],
              ),
              const SizedBox(height: defaultPadding / 4),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  SvgPicture.asset(
                    "assets/icons/Cash.svg",
                    height: 14,
                    colorFilter:
                        ColorFilter.mode(Colors.grey.shade500, BlendMode.srcIn),
                  ),
                  const SizedBox(width: defaultPadding / 2),
                  Text(
                    '€ ${game.pricePerHour}',
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                ],
              ),
            ],
          );
  }
}

class _HostPlayer extends StatelessWidget {
  final Game game;
  final bool isDense;

  const _HostPlayer({
    required this.game,
    this.isDense = false,
  });

  @override
  Widget build(BuildContext context) {
    return isDense
        ? Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: defaultPadding / 2,
            children: [
              SizedBox(
                height: 62,
                width: 166,
                child: Stack(
                  children: [
                    for (int i = 4 - 1; i >= 0; i--)
                      _PlayerList(game: game, index: i),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: defaultPadding),
                child: Text(
                  '${game.currentPlayers!.length}/4',
                  style: Theme.of(context).textTheme.labelMedium,
                ),
              ),
            ],
          )
        : Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              SizedBox(
                height: 62,
                width: 166,
                child: Stack(
                  children: [
                    for (int i = 4 - 1; i >= 0; i--)
                      _PlayerList(game: game, index: i),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: defaultPadding / 2),
                child: Text(
                  '${game.currentPlayers!.length}/4',
                  style: Theme.of(context).textTheme.labelMedium,
                ),
              ),
            ],
          );
  }
}

class _PlayerList extends StatelessWidget {
  final Game game;
  final int index;

  const _PlayerList({
    required this.game,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: index * (38),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(defaultPadding / 8),
            decoration: BoxDecoration(
              color: index < game.currentPlayers!.length
                  ? whiteColor80
                  : cardBackgroundWithOpacity, // Border color
              shape: BoxShape.circle,
            ),
            child: CircleAvatar(
              radius: 24,
              backgroundColor: pillBackgroundColor,
              backgroundImage: index < game.currentPlayers!.length &&
                      game.currentPlayers![index].imageUrl != null
                  ? NetworkImage(game.currentPlayers![index].imageUrl!)
                  : null,
            ),
          ),
          if (index < game.currentPlayers!.length)
            Transform(
              transform: Matrix4.identity()
                ..scale(0.6)
                ..translate(18.0, -24.0),
              child: Chip(
                labelPadding: const EdgeInsets.symmetric(horizontal: 5),
                backgroundColor: whiteColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: const BorderSide(color: Colors.transparent),
                ),
                label: Text(
                  game.currentPlayers![index].rank ?? '',
                  style: Theme.of(context).textTheme.labelMedium!.copyWith(
                        color: backgroundColor,
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _GameCardFooter extends StatelessWidget {
  final Game game;
  final bool isDense;

  const _GameCardFooter({
    required this.game,
    this.isDense = false,
  });

  @override
  Widget build(BuildContext context) {
    return Flex(
      direction: Axis.horizontal,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        CircleAvatar(
          radius: 16,
          backgroundColor: Colors.grey.shade300,
          backgroundImage:
              game.hostPlayer != null && game.hostPlayer!.imageUrl != null
                  ? NetworkImage(game.hostPlayer!.imageUrl!)
                  : null,
        ),
        const SizedBox(width: defaultPadding / 2),
        isDense
            ? const SizedBox.shrink()
            : Text(
                game.hostPlayer != null
                    ? game.hostPlayer!.fullName ?? ''
                    : 'Host Player',
                style: Theme.of(context).textTheme.labelMedium,
              ),
        //if (isDense)
        isDense ? const SizedBox(width: defaultPadding * 4) : const Spacer(),
        Expanded(
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.all(defaultPadding / 1.5),
            ),
            onPressed: () {
              Navigator.pushNamed(
                context,
                gameDetailScreenRoute,
                arguments: {
                  'game': game,
                },
              );
            },
            child: const Text("Deelnemen"),
          ),
        )

        /*] else
          InkWell(
            onTap: () {
              Navigator.pushNamed(context, gameDetailScreenRoute);
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'Deelnemen',
                  style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                        color: primaryColor,
                      ),
                ),
                const SizedBox(width: defaultPadding / 2),
                SvgPicture.asset(
                  "assets/icons/Arrow - Right.svg",
                  height: 20,
                  colorFilter: ColorFilter.mode(primaryColor, BlendMode.srcIn),
                ),
              ],
            ),
          )*/
      ],
    );
  }
}

class _GameInfoChips extends StatelessWidget {
  final String startDate;
  final String startTime;
  final String gameRank;
  final bool isDense;

  const _GameInfoChips({
    required this.startDate,
    required this.startTime,
    required this.gameRank,
    this.isDense = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          '$startDate - $startTime',
          style: isDense
              ? Theme.of(context).textTheme.labelLarge
              : Theme.of(context).textTheme.labelLarge,
        ),
        Chip(
          backgroundColor: whiteColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(defaultPadding * 2),
          ),
          label: Text(
            gameRank,
            style: Theme.of(context)
                .textTheme
                .labelMedium!
                .copyWith(color: backgroundColor, fontWeight: FontWeight.w700),
          ),
        ),
      ],
    );
  }
}
