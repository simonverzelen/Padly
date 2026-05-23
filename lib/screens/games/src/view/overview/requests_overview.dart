import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:padly/components/category_button.dart';
import 'package:padly/constants.dart';
import 'package:padly/route/route_constants.dart';
import 'package:padly/screens/games/src/domain/games_services.dart';
import 'package:provider/provider.dart';

import '../../../../user_info/src/domain/padly_user.dart';

class GameRequestsArgs {
  final String gameId;
  final List<PadlyUser> requests;
  final List<PadlyUser> currentPlayers;
  final bool isOwner;

  const GameRequestsArgs({
    required this.gameId,
    required this.requests,
    required this.currentPlayers,
    required this.isOwner,
  });
}

class RequestsOverviewViewModel extends ChangeNotifier {
  final String gameId;
  final bool isOwner;
  List<PadlyUser> _requests;
  List<PadlyUser> _currentPlayers;
  final GamesServices _gamesServices = GamesServices();
  bool isLoading = false;

  RequestsOverviewViewModel({
    required this.gameId,
    required this.isOwner,
    required List<PadlyUser> initialRequests,
    required List<PadlyUser> initialCurrentPlayers,
  })  : _requests = List.from(initialRequests),
        _currentPlayers = List.from(initialCurrentPlayers);

  List<PadlyUser> get requests => _requests;

  Future<void> acceptRequest(PadlyUser user) async {
    isLoading = true;
    notifyListeners();
    try {
      final newPlayers = [..._currentPlayers, user];
      final newRequests = _requests.where((u) => u.id != user.id).toList();
      await _gamesServices.acceptRequest(
        gameId,
        newPlayers.map<Map<String, dynamic>>((u) => u.toJson()).toList(),
        newRequests.map<Map<String, dynamic>>((u) => u.toJson()).toList(),
      );
      _requests = newRequests;
      _currentPlayers = newPlayers;
    } catch (_) {
      // ignore
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> rejectRequest(PadlyUser user) async {
    isLoading = true;
    notifyListeners();
    try {
      final newRequests = _requests.where((u) => u.id != user.id).toList();
      await _gamesServices.updateJoinRequests(
          gameId,
          newRequests.map<Map<String, dynamic>>((u) => u.toJson()).toList());
      _requests = newRequests;
    } catch (_) {
      // ignore
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}

class RequestsOverview extends StatelessWidget {
  final GameRequestsArgs args;

  const RequestsOverview({required this.args, super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => RequestsOverviewViewModel(
        gameId: args.gameId,
        isOwner: args.isOwner,
        initialRequests: args.requests,
        initialCurrentPlayers: args.currentPlayers,
      ),
      child: const _RequestsOverviewBody(),
    );
  }
}

class _RequestsOverviewBody extends StatelessWidget {
  const _RequestsOverviewBody();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<RequestsOverviewViewModel>();
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Verzoeken',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        centerTitle: true,
        forceMaterialTransparency: true,
      ),
      body: vm.requests.isEmpty
          ? Center(
              child: Text(
                'Geen verzoeken',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            )
          : CustomScrollView(
              slivers: [
                SliverSafeArea(
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => RequestCard(
                        user: vm.requests[index],
                        isOwner: vm.isOwner,
                      ),
                      childCount: vm.requests.length,
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

class RequestCard extends StatelessWidget {
  final PadlyUser user;
  final bool isOwner;

  const RequestCard({required this.user, required this.isOwner, super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.read<RequestsOverviewViewModel>();
    final image = user.imageUrl != null ? NetworkImage(user.imageUrl!) : null;

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
        padding: const EdgeInsets.all(defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () =>
                      Navigator.pushNamed(context, playerDetailScreenRoute),
                  child: Container(
                    padding: const EdgeInsets.all(defaultPadding / 8),
                    decoration: const BoxDecoration(
                      color: whiteColor80,
                      shape: BoxShape.circle,
                    ),
                    child: CircleAvatar(
                      radius: 36,
                      backgroundColor: pillBackgroundColor,
                      foregroundImage: image,
                      child: image == null
                          ? const Icon(LucideIcons.user,
                              size: 32, color: whiteColor)
                          : null,
                    ),
                  ),
                ),
                const SizedBox(width: defaultPadding),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        [
                          if (user.firstName != null) user.firstName,
                          if (user.lastName != null) user.lastName,
                        ].join(' '),
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Row(
                        children: [
                          Text(
                            'padel',
                            style: Theme.of(context).textTheme.labelSmall,
                          ),
                          Transform(
                            transform: Matrix4.identity()
                              ..scale(0.75)
                              ..translate(18.0, 10.0),
                            child: Chip(
                              labelPadding:
                                  const EdgeInsets.symmetric(horizontal: 5),
                              backgroundColor: whiteColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                                side: const BorderSide(
                                    color: Colors.transparent),
                              ),
                              label: Text(
                                user.rank ?? '',
                                style: Theme.of(context)
                                    .textTheme
                                    .labelSmall!
                                    .copyWith(
                                      color: backgroundColor,
                                      fontWeight: FontWeight.w700,
                                    ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (isOwner) ...[
              const SizedBox(height: defaultPadding / 2),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  CategoryButton(
                    text: "Weigeren",
                    isActive: false,
                    press: () async {
                      final confirmed = await showDialog<bool>(
                        context: context,
                        builder: (_) => AlertDialog(
                          backgroundColor: cardBackgroundColor,
                          title: const Text('Verzoek weigeren'),
                          content: const Text(
                              'Ben je zeker dat je dit verzoek wil weigeren?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text('Annuleren'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: const Text(
                                'Weigeren',
                                style: TextStyle(color: Colors.red),
                              ),
                            ),
                          ],
                        ),
                      );
                      if (confirmed == true) vm.rejectRequest(user);
                    },
                  ),
                  const SizedBox(width: defaultPadding),
                  CategoryButton(
                    text: "Accepteren",
                    isActive: true,
                    press: () async {
                      final confirmed = await showDialog<bool>(
                        context: context,
                        builder: (_) => AlertDialog(
                          backgroundColor: cardBackgroundColor,
                          title: const Text('Verzoek aanvaarden'),
                          content: Text(
                              'Ben je zeker dat je ${user.firstName ?? 'deze speler'} wil aanvaarden?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text('Annuleren'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: const Text('Aanvaarden'),
                            ),
                          ],
                        ),
                      );
                      if (confirmed == true) vm.acceptRequest(user);
                    },
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
