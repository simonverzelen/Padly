import 'package:flutter/material.dart';
import 'package:padly/screens/user_info/src/domain/padly_user.dart';

import '../../domain/club.dart';
import '../../domain/create_game.dart';
import '../../domain/game.dart';
import '../../domain/games_services.dart';

class CreateGameViewModel extends ChangeNotifier {
  CreateGameViewModel({
    required GamesServices gameService,
  }) : _gameService = gameService;

  final GamesServices _gameService;

  final Game game = Game(currentPlayers: [
    PadlyUser(
      firstName: "Simon",
      rank: 'P300',
      imageUrl: 'https://i.pravatar.cc/300?v=1',
    ),
    PadlyUser(
      firstName: "Charlotte",
      rank: 'P300',
      imageUrl: 'https://i.pravatar.cc/300?v=2',
    ),
  ]);

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

  final List<String> sportList = [
    'Padel',
    'Tennis',
    'Squash',
    'Badminton',
    'Pickleball',
    'Ping Pong',
    'PadBol',
    'Petanque'
  ];
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
    _selectedDate = _dateList.indexWhere((date) =>
        date.year == value.year &&
        date.month == value.month &&
        date.day == value.day);
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

  String? _error;
  String? get error => _error;

  Future<void> createGame() async {
    if (!canCreateGame) return;

    _isSaving = true;
    _error = null;
    notifyListeners();

    try {
      final selectedDate = _dateList[_selectedDate!];
      final selectedTime = _selectedTime!;

      final start = DateTime(
        selectedDate.year,
        selectedDate.month,
        selectedDate.day,
        selectedTime.hour,
        selectedTime.minute,
      );

      // TODO: replace with your real duration selection
      final end = start.add(const Duration(minutes: 90));

      final gameCreate = GameCreate(
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
        currentPlayers: game.currentPlayers?.map((u) => u.toJson()).toList(),
        hostPlayer: game.currentPlayers?.first.toJson(),
      );

      final insertedRow = await _gameService.createGame(gameCreate);

      // optional: store created row / navigate
      debugPrint('Created game: $insertedRow');
    } catch (e) {
      _error = e.toString();
      print(_error);
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  int _rankFromLevel(String level) {
    // "P300" -> 300
    return int.tryParse(level.replaceAll('P', '')) ?? 0;
  }
}
