import 'dart:io';

import 'package:flutter/material.dart';
import 'package:padly/constants.dart';
import 'package:padly/screens/games/src/domain/games_services.dart';
import 'package:padly/screens/user_info/src/domain/padly_user.dart';
import 'package:padly/screens/user_info/src/domain/user_service.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../domain/game.dart';

class GameDetailViewModel extends ChangeNotifier {
  Game _game;
  PadlyUser? _currentUser;

  bool isLoading = true;
  bool isActionLoading = false;
  String? actionError;

  final GamesServices _gamesServices = GamesServices();

  Game get game => _game;
  PadlyUser? get currentUser => _currentUser;

  bool get isOwner =>
      _currentUser?.id != null && _currentUser?.id == _game.hostPlayer?.id;

  bool get isInMatch =>
      _currentUser?.id != null &&
      (_game.currentPlayers ?? []).any((p) => p.id == _currentUser?.id);

  bool get hasRequested =>
      _currentUser?.id != null &&
      (_game.joinRequests ?? []).any((p) => p.id == _currentUser?.id);

  GameDetailViewModel({required Game game, PadlyUser? initialUser})
      : _game = game,
        _currentUser = initialUser {
    isLoading = initialUser == null;
    load();
  }

  Future<void> load() async {
    _currentUser ??= await UserService().getUser();
    if (_game.id != null) {
      try {
        final fresh = await _gamesServices.fetchGame(_game.id!);
        if (fresh != null) {
          _game = fresh.copyWith(distanceKm: _game.distanceKm);
        }
      } catch (_) {}
    }
    isLoading = false;
    notifyListeners();
  }

  Future<void> requestToJoin() async {
    if (_currentUser == null || _game.id == null) return;
    isActionLoading = true;
    notifyListeners();
    try {
      await _gamesServices.requestToJoin(_game.id!, _currentUser!.toJson());
      _game = _game.copyWith(
          joinRequests: [...(_game.joinRequests ?? []), _currentUser!]);
    } catch (e) {
      actionError = e.toString();
    } finally {
      isActionLoading = false;
      notifyListeners();
    }
  }

  Future<void> cancelRequest() async {
    if (_currentUser == null || _currentUser!.id == null || _game.id == null) return;
    isActionLoading = true;
    notifyListeners();
    try {
      await _gamesServices.cancelJoinRequest(_game.id!, _currentUser!.id!);
      final newRequests = (_game.joinRequests ?? [])
          .where((u) => u.id != _currentUser!.id)
          .toList();
      _game = _game.copyWith(joinRequests: newRequests);
    } catch (e) {
      actionError = e.toString();
    } finally {
      isActionLoading = false;
      notifyListeners();
    }
  }

  Future<void> acceptRequest(PadlyUser user) async {
    if (_game.id == null) return;
    isActionLoading = true;
    notifyListeners();
    try {
      final newPlayers = <PadlyUser>[...(_game.currentPlayers ?? []), user];
      final newRequests = <PadlyUser>[
        ...(_game.joinRequests ?? []).where((u) => u.id != user.id)
      ];
      await _gamesServices.acceptRequest(
        _game.id!,
        newPlayers.map<Map<String, dynamic>>((u) => u.toJson()).toList(),
        newRequests.map<Map<String, dynamic>>((u) => u.toJson()).toList(),
      );
      _game =
          _game.copyWith(currentPlayers: newPlayers, joinRequests: newRequests);
    } catch (e) {
      actionError = e.toString();
    } finally {
      isActionLoading = false;
      notifyListeners();
    }
  }

  Future<void> rejectRequest(PadlyUser user) async {
    if (_game.id == null) return;
    isActionLoading = true;
    notifyListeners();
    try {
      final newRequests = <PadlyUser>[
        ...(_game.joinRequests ?? []).where((u) => u.id != user.id)
      ];
      await _gamesServices.updateJoinRequests(
          _game.id!,
          newRequests.map<Map<String, dynamic>>((u) => u.toJson()).toList());
      _game = _game.copyWith(joinRequests: newRequests);
    } catch (e) {
      actionError = e.toString();
    } finally {
      isActionLoading = false;
      notifyListeners();
    }
  }

  Future<void> removePlayer(PadlyUser user) async {
    if (_game.id == null) return;
    isActionLoading = true;
    actionError = null;
    notifyListeners();
    try {
      final newPlayers = (_game.currentPlayers ?? [])
          .where((u) => u.id != user.id)
          .toList();
      final isSelfRemoval = user.id != null && user.id == _currentUser?.id;
      if (isSelfRemoval) {
        await _gamesServices.removePlayerSelf(_game.id!, user.id!);
      } else {
        await _gamesServices.removePlayer(
            _game.id!,
            newPlayers.map<Map<String, dynamic>>((u) => u.toJson()).toList());
      }
      _game = _game.copyWith(currentPlayers: newPlayers);
    } catch (e) {
      actionError = e.toString();
    } finally {
      isActionLoading = false;
      notifyListeners();
    }
  }

  Future<void> updatePlayers(List<PadlyUser> newPlayers) async {
    if (_game.id == null) return;
    isActionLoading = true;
    notifyListeners();
    try {
      await _gamesServices.removePlayer(
        _game.id!,
        newPlayers.map<Map<String, dynamic>>((u) => u.toJson()).toList(),
      );
      _game = _game.copyWith(currentPlayers: newPlayers);
    } catch (e) {
      actionError = e.toString();
    } finally {
      isActionLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteGame() async {
    if (_game.id == null) return false;
    try {
      await _gamesServices.deleteGame(_game.id!);
      return true;
    } catch (e) {
      actionError = e.toString();
      notifyListeners();
      return false;
    }
  }
}

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
