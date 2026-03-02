import 'dart:io';

import 'package:flutter/material.dart';
import 'package:padly/constants.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../domain/game.dart';

class GameDetailViewModel extends ChangeNotifier {
  final Game _game;

  bool isLoading = true;
  Game get game => _game;

  GameDetailViewModel({
    required Game game,
  }) : _game = game {
    load();
  }

  Future<void> load() async {
    isLoading = false;
    notifyListeners();
  }
}

Future<void> showNavigationOptions(
  BuildContext context, {
  required double lat,
  required double lng,
  required String label,
}) async {
  final List<_NavOption> options = [];

  // Google Maps
  // Google Maps
  final googleMapsUri = Uri.parse(
    Platform.isIOS
        ? 'comgooglemaps://?daddr=$lat,$lng'
        : 'google.navigation:q=$lat,$lng',
  );

  //if (await canLaunchUrl(googleMapsUri)) {
  options.add(
    _NavOption(
      name: "Google Maps",
      uri: googleMapsUri,
    ),
  );
  //}

  // Apple Maps (iOS only)
  if (Platform.isIOS) {
    final appleMapsUri = Uri.parse('http://maps.apple.com/?daddr=$lat,$lng');

    if (await canLaunchUrl(appleMapsUri)) {
      options.add(
        _NavOption(
          name: "Apple Maps",
          uri: appleMapsUri,
        ),
      );
    }
  }

  // Waze
  final wazeUri = Uri.parse('waze://?ll=$lat,$lng&navigate=yes');

  //if (await canLaunchUrl(wazeUri)) {
  options.add(
    _NavOption(
      name: "Waze",
      uri: wazeUri,
    ),
  );
  //}

  // Always add fallback (browser Google Maps)
  final browserFallback = Uri.parse(
    'https://www.google.com/maps/dir/?api=1&destination=$lat,$lng',
  );

  options.add(
    _NavOption(
      name: "Open in Browser",
      uri: browserFallback,
    ),
  );

  // Show bottom sheet
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
                    await launchUrl(
                      option.uri,
                      mode: LaunchMode.externalApplication,
                    );
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
