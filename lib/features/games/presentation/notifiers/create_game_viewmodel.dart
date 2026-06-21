import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:padly/features/games/data/repositories/sports_repository.dart';
import 'package:padly/features/users/domain/entities/padly_user.dart';
import 'package:padly/features/users/domain/services/user_service.dart';

import 'package:padly/features/games/domain/entities/club.dart';
import 'package:padly/features/games/domain/entities/create_game.dart';
import 'package:padly/features/games/domain/entities/game.dart';
import 'package:padly/features/games/domain/services/games_service.dart';

class CreateGameState {
  final List<PadlyUser> currentPlayers;
  final List<String> sportList;
  final int selectedSportIndex;
  final List<String> levelList;
  final int minLevelIndex;
  final int maxLevelIndex;
  final List<String> playersAmountList;
  final int? playersAmountIndex;
  final List<String> genderList;
  final int? genderIndex;
  final List<DateTime> dateList;
  final int? selectedDate;
  final DateTime? selectedTime;
  final List<int> playTimeList;
  final int? playTime;
  final String? nameCourt;
  final double? price;
  final ClubPlace? location;
  final String? gameId;
  final String? createdGameId;
  final bool canCreateGame;
  final bool isSaving;
  final bool isSuccess;
  final String? error;

  const CreateGameState({
    this.currentPlayers = const [],
    this.sportList = const [],
    this.selectedSportIndex = 0,
    this.levelList = const [
      'P50',
      'P100',
      'P200',
      'P300',
      'P400',
      'P500',
      'P700',
      'P1000'
    ],
    this.minLevelIndex = 0,
    this.maxLevelIndex = 1,
    this.playersAmountList = const ['2', '4'],
    this.playersAmountIndex = 1,
    this.genderList = const ['Heren', 'Dames', 'Gemengd'],
    this.genderIndex = 0,
    List<DateTime>? dateList,
    this.selectedDate,
    this.selectedTime,
    this.playTimeList = const [60, 90, 120],
    this.playTime,
    this.nameCourt,
    this.price,
    this.location,
    this.gameId,
    this.createdGameId,
    this.canCreateGame = false,
    this.isSaving = false,
    this.isSuccess = false,
    this.error,
  }) : dateList = dateList ??
            const []; // Will be overridden in notifier build()

  CreateGameState copyWith({
    List<PadlyUser>? currentPlayers,
    List<String>? sportList,
    int? selectedSportIndex,
    List<String>? levelList,
    int? minLevelIndex,
    int? maxLevelIndex,
    List<String>? playersAmountList,
    Object? playersAmountIndex = _sentinel,
    List<String>? genderList,
    Object? genderIndex = _sentinel,
    List<DateTime>? dateList,
    Object? selectedDate = _sentinel,
    Object? selectedTime = _sentinel,
    List<int>? playTimeList,
    Object? playTime = _sentinel,
    Object? nameCourt = _sentinel,
    Object? price = _sentinel,
    Object? location = _sentinel,
    Object? gameId = _sentinel,
    Object? createdGameId = _sentinel,
    bool? canCreateGame,
    bool? isSaving,
    bool? isSuccess,
    Object? error = _sentinel,
  }) {
    return CreateGameState(
      currentPlayers: currentPlayers ?? this.currentPlayers,
      sportList: sportList ?? this.sportList,
      selectedSportIndex: selectedSportIndex ?? this.selectedSportIndex,
      levelList: levelList ?? this.levelList,
      minLevelIndex: minLevelIndex ?? this.minLevelIndex,
      maxLevelIndex: maxLevelIndex ?? this.maxLevelIndex,
      playersAmountList: playersAmountList ?? this.playersAmountList,
      playersAmountIndex: identical(playersAmountIndex, _sentinel)
          ? this.playersAmountIndex
          : playersAmountIndex as int?,
      genderList: genderList ?? this.genderList,
      genderIndex: identical(genderIndex, _sentinel)
          ? this.genderIndex
          : genderIndex as int?,
      dateList: dateList ?? this.dateList,
      selectedDate: identical(selectedDate, _sentinel)
          ? this.selectedDate
          : selectedDate as int?,
      selectedTime: identical(selectedTime, _sentinel)
          ? this.selectedTime
          : selectedTime as DateTime?,
      playTimeList: playTimeList ?? this.playTimeList,
      playTime: identical(playTime, _sentinel)
          ? this.playTime
          : playTime as int?,
      nameCourt: identical(nameCourt, _sentinel)
          ? this.nameCourt
          : nameCourt as String?,
      price: identical(price, _sentinel) ? this.price : price as double?,
      location: identical(location, _sentinel)
          ? this.location
          : location as ClubPlace?,
      gameId:
          identical(gameId, _sentinel) ? this.gameId : gameId as String?,
      createdGameId: identical(createdGameId, _sentinel)
          ? this.createdGameId
          : createdGameId as String?,
      canCreateGame: canCreateGame ?? this.canCreateGame,
      isSaving: isSaving ?? this.isSaving,
      isSuccess: isSuccess ?? this.isSuccess,
      error: identical(error, _sentinel) ? this.error : error as String?,
    );
  }
}

// Sentinel for nullable copyWith fields
const Object _sentinel = Object();

class CreateGameNotifier extends AutoDisposeNotifier<CreateGameState> {
  final GamesServices _gameService = GamesServices();

  @override
  CreateGameState build() {
    return CreateGameState(
      dateList: List.generate(
        31,
        (index) => DateTime.now().add(Duration(days: index)),
      ),
    );
  }

  bool get isEditing => state.gameId != null;

  String? get lockedPlayerId =>
      state.currentPlayers.isNotEmpty ? state.currentPlayers.first.id : null;

  void init(Game? initialGame) {
    if (initialGame != null) {
      _prefillFromGame(initialGame);
    }
    _loadCurrentUser(initialGame: initialGame);
    _loadSports();
  }

  Future<void> _loadCurrentUser({Game? initialGame}) async {
    if (initialGame != null) return;
    final user = await UserService().getUser();
    if (user != null) {
      state = state.copyWith(currentPlayers: [user]);
    }
  }

  void _prefillFromGame(Game game) {
    ClubPlace? location;
    if (game.club != null || game.location != null) {
      location = ClubPlace(
        placeId: '',
        name: game.club ?? '',
        address: game.location ?? '',
        city: game.location ?? '',
        lat: game.lat ?? 0,
        lng: game.lng ?? 0,
      );
    }

    int? selectedDate;
    DateTime? selectedTime;
    int? playTime;

    // Compute selectedDate
    final dateList = state.dateList;
    if (game.date != null) {
      final idx = dateList.indexWhere((date) =>
          date.year == game.date!.year &&
          date.month == game.date!.month &&
          date.day == game.date!.day);
      selectedDate = idx >= 0 ? idx : null;
    }

    if (game.startTime != null) {
      selectedTime = game.startTime;
    }

    if (game.endTime != null && game.startTime != null) {
      final diffMinutes =
          game.endTime!.difference(game.startTime!).inMinutes;
      const playTimeList = [60, 90, 120];
      final idx = playTimeList.indexOf(diffMinutes);
      playTime = idx >= 0 ? playTimeList[idx] : diffMinutes;
    }

    int? playersAmountIndex = 1;
    final amountStr = game.maxPlayers?.toString();
    if (amountStr != null) {
      final idx = state.playersAmountList.indexOf(amountStr);
      if (idx >= 0) playersAmountIndex = idx;
    }

    int minLevelIndex = 0;
    int maxLevelIndex = 1;
    if (game.rankingMin != null) {
      final idx = state.levelList.indexOf(game.rankingMin!);
      if (idx >= 0) minLevelIndex = idx;
    }
    if (game.rankingMax != null) {
      final idx = state.levelList.indexOf(game.rankingMax!);
      if (idx >= 0) maxLevelIndex = idx;
    }

    state = state.copyWith(
      gameId: game.id,
      currentPlayers: game.currentPlayers ?? [],
      location: location,
      selectedDate: selectedDate,
      selectedTime: selectedTime,
      playTime: playTime,
      playersAmountIndex: playersAmountIndex,
      minLevelIndex: minLevelIndex,
      maxLevelIndex: maxLevelIndex,
      price: game.pricePerHour,
      nameCourt: game.club,
    );
    _recomputeCanCreate();
  }

  void setPlayers(List<PadlyUser> players) {
    state = state.copyWith(currentPlayers: players);
  }

  void _recomputeCanCreate() {
    final can = state.selectedDate != null &&
        state.selectedTime != null &&
        state.nameCourt != null &&
        state.price != null &&
        state.location != null;
    state = state.copyWith(canCreateGame: can);
  }

  Future<void> _loadSports() async {
    final sports = await SportsRepository.instance.getSports();
    state = state.copyWith(sportList: sports);
  }

  void selectSport(int value) {
    state = state.copyWith(selectedSportIndex: value);
    _recomputeCanCreate();
  }

  void selectMinLevel(int value) {
    final newMax =
        value > state.maxLevelIndex ? value : state.maxLevelIndex;
    state = state.copyWith(minLevelIndex: value, maxLevelIndex: newMax);
    _recomputeCanCreate();
  }

  void selectMaxLevel(int value) {
    final newMin =
        value < state.minLevelIndex ? value : state.minLevelIndex;
    state = state.copyWith(maxLevelIndex: value, minLevelIndex: newMin);
    _recomputeCanCreate();
  }

  void selectPlayersAmount(int? value) {
    state = state.copyWith(playersAmountIndex: value);
    _recomputeCanCreate();
  }

  void selectGender(int? value) {
    state = state.copyWith(genderIndex: value);
    _recomputeCanCreate();
  }

  void selectDay(int? value) {
    state = state.copyWith(selectedDate: value);
    _recomputeCanCreate();
  }

  void selectDate(DateTime? value) {
    if (value == null) return;
    final idx = state.dateList.indexWhere((date) =>
        date.year == value.year &&
        date.month == value.month &&
        date.day == value.day);
    state = state.copyWith(selectedDate: idx >= 0 ? idx : null);
    _recomputeCanCreate();
  }

  void selectTime(DateTime? value) {
    if (value == null) return;
    state = state.copyWith(selectedTime: value);
    _recomputeCanCreate();
  }

  void selectTotalPlayTime(int? value) {
    state = state.copyWith(playTime: value);
    _recomputeCanCreate();
  }

  void setNameCourt(dynamic value) {
    final v = value is String && value == '' ? null : value as String?;
    state = state.copyWith(nameCourt: v);
    _recomputeCanCreate();
  }

  void setPrice(dynamic value) {
    double? price;
    if (value is String && value.isEmpty) {
      price = null;
    } else {
      price = double.tryParse(value.toString());
    }
    state = state.copyWith(price: price);
    _recomputeCanCreate();
  }

  void setLocation(ClubPlace value) {
    state = state.copyWith(location: value);
    _recomputeCanCreate();
  }

  GameCreate _buildGameCreate() {
    final selectedDate = state.dateList[state.selectedDate!];
    final selectedTime = state.selectedTime!;

    final start = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
      selectedTime.hour,
      selectedTime.minute,
    );

    final durationMinutes = state.playTime ?? 90;
    final end = start.add(Duration(minutes: durationMinutes));

    return GameCreate(
      date: selectedDate,
      startTime: start,
      endTime: end,
      lat: state.location!.lat,
      lng: state.location!.lng,
      club: state.location!.name,
      location: state.location!.city,
      maxPlayers: int.parse(
          state.playersAmountList[state.playersAmountIndex ?? 1]),
      pricePerHour: state.price!,
      rankingMin: _rankFromLevel(state.levelList[state.minLevelIndex]),
      rankingMax: _rankFromLevel(state.levelList[state.maxLevelIndex]),
      currentPlayers:
          state.currentPlayers.map((u) => u.toJson()).toList(),
      hostPlayer: state.currentPlayers.isNotEmpty
          ? state.currentPlayers.first.toJson()
          : null,
      sportId: null,
    );
  }

  Future<void> saveGame() async {
    if (!state.canCreateGame) return;

    state = state.copyWith(isSaving: true, error: null);

    try {
      if (state.selectedDate == null) {
        throw Exception('Geen geldige datum geselecteerd');
      }

      final gameCreate = _buildGameCreate();

      if (state.gameId != null) {
        await _gameService.updateGame(state.gameId!, gameCreate);
      } else {
        final selectedSportName = state.sportList.isNotEmpty
            ? state.sportList[state.selectedSportIndex]
            : null;
        final sportId = selectedSportName != null
            ? await SportsRepository.instance.getSportId(selectedSportName)
            : null;

        final gameCreateWithSport = GameCreate(
          date: gameCreate.date,
          startTime: gameCreate.startTime,
          endTime: gameCreate.endTime,
          lat: gameCreate.lat,
          lng: gameCreate.lng,
          club: gameCreate.club,
          location: gameCreate.location,
          maxPlayers: gameCreate.maxPlayers,
          pricePerHour: gameCreate.pricePerHour,
          rankingMin: gameCreate.rankingMin,
          rankingMax: gameCreate.rankingMax,
          currentPlayers: gameCreate.currentPlayers,
          hostPlayer: gameCreate.hostPlayer,
          sportId: sportId,
        );

        final result = await _gameService.createGame(gameCreateWithSport);
        final createdId = result['id'] as String;
        state = state.copyWith(isSuccess: true, createdGameId: createdId);
        return;
      }

      state = state.copyWith(isSuccess: true);
    } catch (e) {
      // ignore: avoid_print
      print(e.toString());
      state = state.copyWith(error: e.toString());
    } finally {
      state = state.copyWith(isSaving: false);
    }
  }

  // Keep createGame as an alias for backwards compatibility.
  Future<void> createGame() => saveGame();

  int _rankFromLevel(String level) {
    // "P300" -> 300
    return int.tryParse(level.replaceAll('P', '')) ?? 0;
  }
}

final createGameNotifierProvider =
    AutoDisposeNotifierProvider<CreateGameNotifier, CreateGameState>(
        CreateGameNotifier.new);
