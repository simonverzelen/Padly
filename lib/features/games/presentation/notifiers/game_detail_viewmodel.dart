import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:padly/core/constants.dart';
import 'package:padly/features/games/domain/services/games_service.dart';
import 'package:padly/features/users/domain/entities/padly_user.dart';
import 'package:padly/features/users/domain/services/user_service.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:padly/features/games/domain/entities/game.dart';

class GameDetailState {
  final Game game;
  final PadlyUser? currentUser;
  final bool isLoading;
  final bool isActionLoading;
  final String? actionError;

  const GameDetailState({
    required this.game,
    this.currentUser,
    this.isLoading = true,
    this.isActionLoading = false,
    this.actionError,
  });

  GameDetailState copyWith({
    Game? game,
    Object? currentUser = _sentinel,
    bool? isLoading,
    bool? isActionLoading,
    Object? actionError = _sentinel,
  }) {
    return GameDetailState(
      game: game ?? this.game,
      currentUser: identical(currentUser, _sentinel)
          ? this.currentUser
          : currentUser as PadlyUser?,
      isLoading: isLoading ?? this.isLoading,
      isActionLoading: isActionLoading ?? this.isActionLoading,
      actionError: identical(actionError, _sentinel)
          ? this.actionError
          : actionError as String?,
    );
  }
}

const Object _sentinel = Object();

class GameDetailNotifier extends AutoDisposeNotifier<GameDetailState> {
  final GamesServices _gamesServices = GamesServices();

  // Temporary placeholder game — real state set in init()
  static final _placeholder = Game();

  @override
  GameDetailState build() => GameDetailState(game: _placeholder);

  bool get isOwner =>
      state.currentUser?.id != null &&
      state.currentUser?.id == state.game.hostPlayer?.id;

  bool get isInMatch =>
      state.currentUser?.id != null &&
      (state.game.currentPlayers ?? [])
          .any((p) => p.id == state.currentUser?.id);

  bool get hasRequested =>
      state.currentUser?.id != null &&
      (state.game.joinRequests ?? [])
          .any((p) => p.id == state.currentUser?.id);

  void init(Game game, {PadlyUser? initialUser}) {
    state = GameDetailState(
      game: game,
      currentUser: initialUser,
      isLoading: initialUser == null,
    );
    load();
  }

  Future<void> load() async {
    PadlyUser? currentUser = state.currentUser;
    if (currentUser == null) {
      currentUser = await UserService().getUser();
    }

    Game game = state.game;
    if (game.id != null) {
      try {
        final fresh = await _gamesServices.fetchGame(game.id!);
        if (fresh != null) {
          game = fresh.copyWith(distanceKm: game.distanceKm);
        }
      } catch (_) {}
    }
    state = state.copyWith(
      game: game,
      currentUser: currentUser,
      isLoading: false,
    );
  }

  Future<void> requestToJoin() async {
    if (state.currentUser == null || state.game.id == null) return;
    state = state.copyWith(isActionLoading: true);
    try {
      await _gamesServices.requestToJoin(
          state.game.id!, state.currentUser!.toJson());
      state = state.copyWith(
        game: state.game.copyWith(
          joinRequests: [
            ...(state.game.joinRequests ?? []),
            state.currentUser!
          ],
        ),
      );
    } catch (e) {
      state = state.copyWith(actionError: e.toString());
    } finally {
      state = state.copyWith(isActionLoading: false);
    }
  }

  Future<void> cancelRequest() async {
    if (state.currentUser == null ||
        state.currentUser!.id == null ||
        state.game.id == null) return;
    state = state.copyWith(isActionLoading: true);
    try {
      await _gamesServices.cancelJoinRequest(
          state.game.id!, state.currentUser!.id!);
      final newRequests = (state.game.joinRequests ?? [])
          .where((u) => u.id != state.currentUser!.id)
          .toList();
      state = state.copyWith(
          game: state.game.copyWith(joinRequests: newRequests));
    } catch (e) {
      state = state.copyWith(actionError: e.toString());
    } finally {
      state = state.copyWith(isActionLoading: false);
    }
  }

  Future<void> acceptRequest(PadlyUser user) async {
    if (state.game.id == null) return;
    state = state.copyWith(isActionLoading: true);
    try {
      final newPlayers = <PadlyUser>[
        ...(state.game.currentPlayers ?? []),
        user
      ];
      final newRequests = <PadlyUser>[
        ...(state.game.joinRequests ?? []).where((u) => u.id != user.id)
      ];
      await _gamesServices.acceptRequest(
        state.game.id!,
        newPlayers.map<Map<String, dynamic>>((u) => u.toJson()).toList(),
        newRequests.map<Map<String, dynamic>>((u) => u.toJson()).toList(),
      );
      state = state.copyWith(
          game: state.game.copyWith(
              currentPlayers: newPlayers, joinRequests: newRequests));
    } catch (e) {
      state = state.copyWith(actionError: e.toString());
    } finally {
      state = state.copyWith(isActionLoading: false);
    }
  }

  Future<void> rejectRequest(PadlyUser user) async {
    if (state.game.id == null) return;
    state = state.copyWith(isActionLoading: true);
    try {
      final newRequests = <PadlyUser>[
        ...(state.game.joinRequests ?? []).where((u) => u.id != user.id)
      ];
      await _gamesServices.updateJoinRequests(
          state.game.id!,
          newRequests
              .map<Map<String, dynamic>>((u) => u.toJson())
              .toList());
      state =
          state.copyWith(game: state.game.copyWith(joinRequests: newRequests));
    } catch (e) {
      state = state.copyWith(actionError: e.toString());
    } finally {
      state = state.copyWith(isActionLoading: false);
    }
  }

  Future<void> removePlayer(PadlyUser user) async {
    if (state.game.id == null) return;
    state = state.copyWith(isActionLoading: true, actionError: null);
    try {
      final newPlayers = (state.game.currentPlayers ?? [])
          .where((u) => u.id != user.id)
          .toList();
      final isSelfRemoval =
          user.id != null && user.id == state.currentUser?.id;
      if (isSelfRemoval) {
        await _gamesServices.removePlayerSelf(state.game.id!, user.id!);
      } else {
        await _gamesServices.removePlayer(
            state.game.id!,
            newPlayers
                .map<Map<String, dynamic>>((u) => u.toJson())
                .toList());
      }
      state = state.copyWith(
          game: state.game.copyWith(currentPlayers: newPlayers));
    } catch (e) {
      state = state.copyWith(actionError: e.toString());
    } finally {
      state = state.copyWith(isActionLoading: false);
    }
  }

  Future<void> updatePlayers(List<PadlyUser> newPlayers) async {
    if (state.game.id == null) return;
    state = state.copyWith(isActionLoading: true);
    try {
      await _gamesServices.removePlayer(
        state.game.id!,
        newPlayers
            .map<Map<String, dynamic>>((u) => u.toJson())
            .toList(),
      );
      state = state.copyWith(
          game: state.game.copyWith(currentPlayers: newPlayers));
    } catch (e) {
      state = state.copyWith(actionError: e.toString());
    } finally {
      state = state.copyWith(isActionLoading: false);
    }
  }

  Future<bool> deleteGame() async {
    if (state.game.id == null) return false;
    try {
      await _gamesServices.deleteGame(state.game.id!);
      return true;
    } catch (e) {
      state = state.copyWith(actionError: e.toString());
      return false;
    }
  }
}

final gameDetailNotifierProvider =
    AutoDisposeNotifierProvider<GameDetailNotifier, GameDetailState>(
        GameDetailNotifier.new);

Future<void> showNavigationOptions(
  BuildContext context, {
  required double lat,
  required double lng,
  required String label,
}) async {
  final List<_NavOption> options = [];

  final googleMapsUri = Uri.parse(
    Platform.isIOS
        ? 'comgooglemaps://?daddr=$lat,$lng'
        : 'google.navigation:q=$lat,$lng',
  );

  if (await canLaunchUrl(googleMapsUri)) {
    options.add(_NavOption(name: "Google Maps", uri: googleMapsUri));
  }

  if (Platform.isIOS) {
    final appleMapsUri = Uri.parse('http://maps.apple.com/?daddr=$lat,$lng');
    if (await canLaunchUrl(appleMapsUri)) {
      options.add(_NavOption(name: "Apple Maps", uri: appleMapsUri));
    }
  }

  final wazeUri = Uri.parse('waze://?ll=$lat,$lng&navigate=yes');
  if (await canLaunchUrl(wazeUri)) {
    options.add(_NavOption(name: "Waze", uri: wazeUri));
  }

  final browserFallback = Uri.parse(
    'https://www.google.com/maps/dir/?api=1&destination=$lat,$lng',
  );
  options.add(_NavOption(name: "Open in Browser", uri: browserFallback));

  if (!context.mounted) return;
  showModalBottomSheet(
    context: context,
    builder: (_) => SafeArea(
      child: Container(
        decoration: const BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(defaultBorderRadious / 2),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: options
              .map(
                (option) => ListTile(
                  title: Text(option.name),
                  onTap: () async {
                    Navigator.pop(context);
                    try {
                      await launchUrl(
                        option.uri,
                        mode: LaunchMode.externalApplication,
                      );
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                                'Navigatie-app kon niet worden geopend: $e'),
                          ),
                        );
                      }
                    }
                  },
                ),
              )
              .toList(),
        ),
      ),
    ),
  );
}

class _NavOption {
  final String name;
  final Uri uri;
  _NavOption({required this.name, required this.uri});
}
