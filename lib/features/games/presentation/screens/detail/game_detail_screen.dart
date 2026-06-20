import 'package:avatar_stack/avatar_stack.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:avatar_stack/positions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:padly/core/components/category_button.dart';
import 'package:padly/core/constants.dart';
import 'package:padly/core/route/route_constants.dart';
import 'package:padly/core/route/screen_export.dart';

import 'package:padly/features/games/domain/entities/game.dart';
import 'package:padly/features/games/presentation/screens/overview/requests_overview.dart';
import 'package:padly/features/games/presentation/notifiers/game_detail_viewmodel.dart';
import 'package:padly/features/users/domain/entities/padly_user.dart';

class GameDetailScreen extends ConsumerStatefulWidget {
  final Game game;
  final PadlyUser? initialUser;

  const GameDetailScreen({
    super.key,
    required this.game,
    this.initialUser,
  });

  @override
  ConsumerState<GameDetailScreen> createState() => _GameDetailScreenState();
}

class _GameDetailScreenState extends ConsumerState<GameDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(gameDetailNotifierProvider.notifier).init(
            widget.game,
            initialUser: widget.initialUser,
          );
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(gameDetailNotifierProvider);
    final notifier = ref.read(gameDetailNotifierProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Neem deel aan de match',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        centerTitle: true,
        forceMaterialTransparency: true,
        actions: [
          if (notifier.isOwner)
            PopupMenuButton<String>(
              color: cardBackgroundColor,
              onSelected: (value) async {
                if (value == 'edit') {
                  Navigator.pushNamed(
                    context,
                    createGameScreenRoute,
                    arguments: {'game': state.game},
                  );
                } else if (value == 'delete') {
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (_) => AlertDialog(
                      backgroundColor: cardBackgroundColor,
                      title: const Text('Match verwijderen'),
                      content: const Text(
                          'Ben je zeker dat je deze match wil verwijderen?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('Annuleren'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text(
                            'Verwijderen',
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                    ),
                  );
                  if (confirmed == true && context.mounted) {
                    final success = await notifier.deleteGame();
                    if (success && context.mounted) {
                      Navigator.pushNamedAndRemoveUntil(
                          context, entryPointScreenRoute, (_) => false);
                    }
                  }
                }
              },
              itemBuilder: (_) => [
                const PopupMenuItem(value: 'edit', child: Text('Aanpassen')),
                const PopupMenuItem(
                  value: 'delete',
                  child: Text(
                    'Verwijderen',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ],
            ),
        ],
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
      bottomNavigationBar: (state.isLoading || notifier.isOwner)
          ? const SizedBox.shrink()
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(defaultPadding),
                child: SizedBox(
                  width: double.infinity,
                  child: notifier.isInMatch
                      ? ElevatedButton(
                          onPressed: null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey.shade700,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(32)),
                          ),
                          child: const Text('Je bent al lid'),
                        )
                      : notifier.hasRequested
                          ? ElevatedButton(
                              onPressed: state.isActionLoading
                                  ? null
                                  : () => notifier.cancelRequest(),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red.shade700,
                                foregroundColor: Colors.white,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(32)),
                              ),
                              child: const Text('Verzoek annuleren'),
                            )
                          : ElevatedButton(
                              onPressed: state.isActionLoading
                                  ? null
                                  : () => notifier.requestToJoin(),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primaryColor,
                                foregroundColor: Colors.black,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(32)),
                              ),
                              child: const Text('Deelnemen'),
                            ),
                ),
              ),
            ),
    );
  }
}

class _Location extends ConsumerWidget {
  const _Location();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(gameDetailNotifierProvider);
    final game = state.game;
    final String gameRank =
        '${game.rankingMin ?? '-'} - ${game.rankingMax ?? '-'}';
    final startTime =
        game.startTime != null ? DateFormat.Hm().format(game.startTime!) : '';
    final String playTime = (game.endTime != null && game.startTime != null)
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
                        Icon(LucideIcons.mapPin,
                            size: 14, color: Colors.grey.shade500),
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
                        Icon(LucideIcons.clock,
                            size: 14, color: Colors.grey.shade500),
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
                const Spacer(),
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
                    icon: const Icon(LucideIcons.mapPin,
                        size: 24, color: blackColor),
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

class _RequestPlayers extends ConsumerWidget {
  const _RequestPlayers();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(gameDetailNotifierProvider);
    final notifier = ref.read(gameDetailNotifierProvider.notifier);
    final game = state.game;
    return GestureDetector(
      onTap: () async {
        await Navigator.pushNamed(
          context,
          gameRequestsScreenRoute,
          arguments: GameRequestsArgs(
            gameId: game.id ?? '',
            requests: game.joinRequests ?? [],
            currentPlayers: game.currentPlayers ?? [],
            isOwner: notifier.isOwner,
          ),
        );
        if (context.mounted) {
          ref.read(gameDetailNotifierProvider.notifier).load();
        }
      },
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
                LucideIcons.chevronRight,
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
    final requests = game.joinRequests ?? [];
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
          for (int i = requests.length - 1; i >= 0; i--)
            Container(
              padding: const EdgeInsets.all(defaultPadding / 8),
              decoration: const BoxDecoration(
                color: whiteColor80,
                shape: BoxShape.circle,
              ),
              child: CircleAvatar(
                radius: 24,
                backgroundColor: pillBackgroundColor,
                backgroundImage:
                    i < requests.length && requests[i].imageUrl != null
                        ? NetworkImage(requests[i].imageUrl!)
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

class _CurrentPlayersList extends ConsumerWidget {
  const _CurrentPlayersList();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(gameDetailNotifierProvider);
    final notifier = ref.read(gameDetailNotifierProvider.notifier);
    final game = state.game;
    final players = game.currentPlayers ?? [];

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        for (int i = 0; i < 4; i++) ...[
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    padding: const EdgeInsets.all(defaultPadding / 8),
                    decoration: BoxDecoration(
                      color: i < players.length ? whiteColor80 : null,
                      shape: BoxShape.circle,
                    ),
                    child: CircleAvatar(
                      radius: 36,
                      backgroundColor: pillBackgroundColor,
                      backgroundImage:
                          i < players.length && players[i].imageUrl != null
                              ? NetworkImage(players[i].imageUrl!)
                              : null,
                    ),
                  ),
                  if (notifier.isOwner &&
                      i < players.length &&
                      players[i].id != game.hostPlayer?.id)
                    Positioned(
                      top: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: () async {
                          final player = players[i];
                          final confirmed = await showDialog<bool>(
                            context: context,
                            builder: (_) => AlertDialog(
                              backgroundColor: cardBackgroundColor,
                              title: const Text('Speler verwijderen'),
                              content: Text(
                                  'Ben je zeker dat je ${player.firstName ?? 'deze speler'} wil verwijderen?'),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.pop(context, false),
                                  child: const Text('Annuleren'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  child: const Text(
                                    'Verwijderen',
                                    style: TextStyle(color: Colors.red),
                                  ),
                                ),
                              ],
                            ),
                          );
                          if (confirmed == true) {
                            notifier.removePlayer(player);
                          }
                        },
                        child: Container(
                          width: 20,
                          height: 20,
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(LucideIcons.x,
                              size: 12, color: Colors.white),
                        ),
                      ),
                    ),
                  if (notifier.isOwner && i >= players.length)
                    Positioned(
                      top: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: () async {
                          final result = await Navigator.pushNamed(
                            context,
                            addPlayersScreenRoute,
                            arguments: {
                              'maxPlayers': game.maxPlayers == 2 ? 0 : 1,
                              'initialPlayers': players,
                              'lockedPlayerId': game.hostPlayer?.id,
                            },
                          );
                          if (context.mounted && result is List<PadlyUser>) {
                            ref
                                .read(gameDetailNotifierProvider.notifier)
                                .updatePlayers(result);
                          }
                        },
                        child: Container(
                          width: 20,
                          height: 20,
                          decoration: const BoxDecoration(
                            color: primaryColor,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(LucideIcons.plus,
                              size: 12, color: blackColor),
                        ),
                      ),
                    ),
                  if (!notifier.isOwner &&
                      notifier.isInMatch &&
                      i < players.length &&
                      players[i].id == state.currentUser?.id)
                    Positioned(
                      top: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: () async {
                          final player = players[i];
                          final confirmed = await showDialog<bool>(
                            context: context,
                            builder: (_) => AlertDialog(
                              backgroundColor: cardBackgroundColor,
                              title: const Text('Match verlaten'),
                              content: const Text(
                                  'Ben je zeker dat je de match wil verlaten?'),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.pop(context, false),
                                  child: const Text('Annuleren'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  child: const Text(
                                    'Verlaten',
                                    style: TextStyle(color: Colors.red),
                                  ),
                                ),
                              ],
                            ),
                          );
                          if (confirmed == true && context.mounted) {
                            await ref
                                .read(gameDetailNotifierProvider.notifier)
                                .removePlayer(player);
                            if (context.mounted) {
                              final error = ref
                                  .read(gameDetailNotifierProvider)
                                  .actionError;
                              if (error != null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Verlaten mislukt: $error'),
                                  ),
                                );
                              }
                            }
                          }
                        },
                        child: Container(
                          width: 20,
                          height: 20,
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(LucideIcons.x,
                              size: 12, color: Colors.white),
                        ),
                      ),
                    ),
                ],
              ),
              if (i < players.length) ...[
                const SizedBox(height: defaultPadding / 4),
                Text(players[i].firstName ?? '',
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
                      players[i].rank ?? '',
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
            icon: LucideIcons.messageCircle,
            press: () => {},
            isActive: true,
          ),
          const SizedBox(width: defaultPadding),
          CategoryButton(
            text: "Voeg Toe Aan Kalender",
            icon: LucideIcons.calendar,
            press: () => {},
            isActive: false,
          ),
        ],
      ),
    );
  }
}
