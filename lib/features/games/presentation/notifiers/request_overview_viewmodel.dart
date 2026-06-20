import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:padly/features/games/domain/services/games_service.dart';
import 'package:padly/features/users/domain/entities/padly_user.dart';

class RequestsOverviewState {
  final List<PadlyUser> requests;
  final List<PadlyUser> currentPlayers;
  final String gameId;
  final bool isOwner;
  final bool isLoading;

  const RequestsOverviewState({
    this.requests = const [],
    this.currentPlayers = const [],
    this.gameId = '',
    this.isOwner = false,
    this.isLoading = false,
  });

  RequestsOverviewState copyWith({
    List<PadlyUser>? requests,
    List<PadlyUser>? currentPlayers,
    String? gameId,
    bool? isOwner,
    bool? isLoading,
  }) {
    return RequestsOverviewState(
      requests: requests ?? this.requests,
      currentPlayers: currentPlayers ?? this.currentPlayers,
      gameId: gameId ?? this.gameId,
      isOwner: isOwner ?? this.isOwner,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class RequestsOverviewNotifier
    extends AutoDisposeNotifier<RequestsOverviewState> {
  final GamesServices _gamesServices = GamesServices();

  @override
  RequestsOverviewState build() => const RequestsOverviewState();

  void init({
    required String gameId,
    required bool isOwner,
    required List<PadlyUser> initialRequests,
    required List<PadlyUser> initialCurrentPlayers,
  }) {
    state = RequestsOverviewState(
      gameId: gameId,
      isOwner: isOwner,
      requests: List.from(initialRequests),
      currentPlayers: List.from(initialCurrentPlayers),
    );
  }

  Future<void> acceptRequest(PadlyUser user) async {
    state = state.copyWith(isLoading: true);
    try {
      final newPlayers = [...state.currentPlayers, user];
      final newRequests =
          state.requests.where((u) => u.id != user.id).toList();
      await _gamesServices.acceptRequest(
        state.gameId,
        newPlayers.map<Map<String, dynamic>>((u) => u.toJson()).toList(),
        newRequests.map<Map<String, dynamic>>((u) => u.toJson()).toList(),
      );
      state = state.copyWith(
          requests: newRequests, currentPlayers: newPlayers);
    } catch (_) {
      // ignore
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> rejectRequest(PadlyUser user) async {
    state = state.copyWith(isLoading: true);
    try {
      final newRequests =
          state.requests.where((u) => u.id != user.id).toList();
      await _gamesServices.updateJoinRequests(
          state.gameId,
          newRequests
              .map<Map<String, dynamic>>((u) => u.toJson())
              .toList());
      state = state.copyWith(requests: newRequests);
    } catch (_) {
      // ignore
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }
}

final requestsOverviewNotifierProvider =
    AutoDisposeNotifierProvider<RequestsOverviewNotifier, RequestsOverviewState>(
        RequestsOverviewNotifier.new);
