import 'package:flutter/material.dart';
import 'package:padly/screens/games/src/data/sports_repository.dart';
import 'package:padly/screens/user_info/src/domain/padly_user.dart';
import 'package:padly/screens/user_info/src/domain/user_service.dart';

import '../../domain/club.dart';
import '../../domain/create_game.dart';
import '../../domain/game.dart';
import '../../domain/games_services.dart';

class CreateGameViewModel extends ChangeNotifier {
  CreateGameViewModel({
    required GamesServices gameService,
    Game? initialGame,
  }) : _gameService = gameService {
    _loadCurrentUser(initialGame: initialGame);
    _loadSports();
    if (initialGame != null) {
      _prefillFromGame(initialGame);
    }
  }

  final GamesServices _gameService;

  String? _gameId;
  bool get isEditing => _gameId != null;

  List<PadlyUser> _currentPlayers = [];
  List<PadlyUser> get currentPlayers => _currentPlayers;

  String? get lockedPlayerId =>
      _currentPlayers.isNotEmpty ? _currentPlayers.first.id : null;

  Future<void> _loadCurrentUser({Game? initialGame}) async {
    // In edit mode the players are already set via _prefillFromGame;
    // only auto-fill the current user when creating a new game.
    if (initialGame != null) return;
    final user = await UserService().getUser();
    if (user != null) {
      _currentPlayers = [user];
      notifyListeners();
    }
  }

  void _prefillFromGame(Game game) {
    _gameId = game.id;
    _currentPlayers = game.currentPlayers ?? [];

    if (game.club != null || game.location != null) {
      _location = ClubPlace(
        placeId: '',
        name: game.club ?? '',
        address: game.location ?? '',
        city: game.location ?? '',
        lat: game.lat ?? 0,
        lng: game.lng ?? 0,
      );
    }

    selectDate(game.date);
    selectTime(game.startTime);

    if (game.endTime != null && game.startTime != null) {
      final diffMinutes =
          game.endTime!.difference(game.startTime!).inMinutes;
      final idx = playTimeList.indexOf(diffMinutes);
      _playTime = idx >= 0 ? playTimeList[idx] : diffMinutes;
    }

    final amountStr = game.maxPlayers?.toString();
    if (amountStr != null) {
      final idx = _playersAmountList.indexOf(amountStr);
      if (idx >= 0) _playersAmountIndex = idx;
    }

    if (game.rankingMin != null) {
      final idx = levelList.indexOf(game.rankingMin!);
      if (idx >= 0) _minLevelIndex = idx;
    }

    if (game.rankingMax != null) {
      final idx = levelList.indexOf(game.rankingMax!);
      if (idx >= 0) _maxLevelIndex = idx;
    }

    _price = game.pricePerHour;
    _nameCourt = game.club;

    setCanCreateGame();
  }

  void setPlayers(List<PadlyUser> players) {
    _currentPlayers = players;
    notifyListeners();
  }

  bool _canCreateGame = false;
  bool get canCreateGame => _canCreateGame;
  void setCanCreateGame() {
    _canCreateGame = _selectedDate != null &&
        _selectedTime != null &&
        _nameCourt != null &&
        _price != null &&
        _location != null;
    notifyListeners();
  }

  List<String> sportList = [];

  Future<void> _loadSports() async {
    sportList = await SportsRepository.instance.getSports();
    notifyListeners();
  }

  int _selectedSportIndex = 0;
  int get selectedSport => _selectedSportIndex;
  void selectSport(int value) {
    _selectedSportIndex = value;
    setCanCreateGame();
  }

  final List<String> levelList = [
    'P50',
    'P100',
    'P200',
    'P300',
    'P400',
    'P500',
    'P700',
    'P1000'
  ];
  int _minLevelIndex = 0;
  int get minLevel => _minLevelIndex;
  int _maxLevelIndex = 1;
  int get maxLevel => _maxLevelIndex;
  void selectMinLevel(int value) {
    _minLevelIndex = value;
    _maxLevelIndex = _minLevelIndex > _maxLevelIndex ? value : _maxLevelIndex;
    setCanCreateGame();
  }

  void selectMaxLevel(int value) {
    _maxLevelIndex = value;
    _minLevelIndex = _maxLevelIndex < _minLevelIndex ? value : _minLevelIndex;
    setCanCreateGame();
  }

  final List<String> _playersAmountList = ['2', '4'];
  List<String> get playersAmountList => _playersAmountList;
  int? _playersAmountIndex = 1;
  int? get playersAmount => _playersAmountIndex;
  void selectPlayersAmount(int? value) {
    _playersAmountIndex = value;
    setCanCreateGame();
  }

  final List<String> _genderList = ['Heren', 'Dames', 'Gemengd'];
  List<String> get genderList => _genderList;
  int? _genderIndex = 0;
  int? get gender => _genderIndex;
  void selectGender(int? value) {
    _genderIndex = value;
    setCanCreateGame();
  }

  final List<DateTime> _dateList = List.generate(
    31,
    (index) => DateTime.now().add(Duration(days: index)),
  );
  List<DateTime> get dateList => _dateList;
  int? _selectedDate;
  DateTime? _selectedTime;
  int? get selectedDate => _selectedDate;
  DateTime? get selectedTime => _selectedTime;
  void selectDay(int? value) {
    _selectedDate = value;
    setCanCreateGame();
  }

  void selectDate(DateTime? value) {
    if (value == null) return;
    final idx = _dateList.indexWhere((date) =>
        date.year == value.year &&
        date.month == value.month &&
        date.day == value.day);
    // When editing an existing game the date may be in the past and not in
    // _dateList; store -1 so the UI shows no highlighted day but still valid.
    _selectedDate = idx >= 0 ? idx : null;
    setCanCreateGame();
  }

  void selectTime(DateTime? value) {
    if (value == null) return;
    _selectedTime = value;
    setCanCreateGame();
  }

  //total play time: 60, 90, 120 min
  final List<int> playTimeList = [60, 90, 120];
  int? _playTime;
  int? get playTime => _playTime;
  void selectTotalPlayTime(int? value) {
    _playTime = value;
    setCanCreateGame();
  }

  //name court
  String? _nameCourt;
  String? get nameCourt => _nameCourt;
  void setNameCourt(value) {
    _nameCourt = value;
    if (value == "") _nameCourt = null;
    setCanCreateGame();
  }

  //price
  double? _price;
  double? get price => _price;
  void setPrice(dynamic value) {
    if (value is String && value.isEmpty) {
      _price = null;
    } else {
      _price = double.tryParse(value.toString());
    }
    setCanCreateGame();
  }

  //location
  ClubPlace? _location;
  ClubPlace? get location => _location;
  void setLocation(ClubPlace value) {
    _location = value;
    setCanCreateGame();
  }

  bool _isSaving = false;
  bool get isSaving => _isSaving;

  bool _isSuccess = false;
  bool get isSuccess => _isSuccess;

  String? _error;
  String? get error => _error;

  GameCreate _buildGameCreate() {
    final selectedDate = _dateList[_selectedDate!];
    final selectedTime = _selectedTime!;

    final start = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
      selectedTime.hour,
      selectedTime.minute,
    );

    final durationMinutes = _playTime ?? 90;
    final end = start.add(Duration(minutes: durationMinutes));

    return GameCreate(
      date: selectedDate,
      startTime: start,
      endTime: end,
      lat: _location!.lat,
      lng: _location!.lng,
      club: _location!.name,
      location: _location!.city,
      maxPlayers: int.parse(_playersAmountList[_playersAmountIndex ?? 1]),
      pricePerHour: _price!,
      rankingMin: _rankFromLevel(levelList[_minLevelIndex]),
      rankingMax: _rankFromLevel(levelList[_maxLevelIndex]),
      currentPlayers: _currentPlayers.map((u) => u.toJson()).toList(),
      hostPlayer:
          _currentPlayers.isNotEmpty ? _currentPlayers.first.toJson() : null,
      sportId: null,
    );
  }

  Future<void> saveGame() async {
    if (!canCreateGame) return;

    _isSaving = true;
    _error = null;
    notifyListeners();

    try {
      if (_selectedDate == null) {
        throw Exception('Geen geldige datum geselecteerd');
      }

      final gameCreate = _buildGameCreate();

      if (_gameId != null) {
        await _gameService.updateGame(_gameId!, gameCreate);
      } else {
        final selectedSportName =
            sportList.isNotEmpty ? sportList[_selectedSportIndex] : null;
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

        await _gameService.createGame(gameCreateWithSport);
      }

      _isSuccess = true;
    } catch (e) {
      _error = e.toString();
      // ignore: avoid_print
      print(_error);
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  // Keep createGame as an alias for backwards compatibility.
  Future<void> createGame() => saveGame();

  int _rankFromLevel(String level) {
    // "P300" -> 300
    return int.tryParse(level.replaceAll('P', '')) ?? 0;
  }
}
