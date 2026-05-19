import 'dart:convert';

import 'package:padly/screens/user_info/src/domain/padly_user.dart';

class Game {
  final String? id;
  final PadlyUser? hostPlayer;
  final DateTime? date;
  final DateTime? startTime;
  final DateTime? endTime;
  final String? location;
  final double? distanceKm;
  final String? rankingMin;
  final String? rankingMax;
  final double? pricePerHour;
  final int? maxPlayers;
  final List<PadlyUser>? currentPlayers;
  final String? club;
  final double? lat;
  final double? lng;

  Game({
    this.id,
    this.hostPlayer,
    this.date,
    this.startTime,
    this.endTime,
    this.location,
    this.distanceKm,
    this.rankingMin,
    this.rankingMax,
    this.pricePerHour,
    this.maxPlayers,
    this.currentPlayers,
    this.club,
    this.lat,
    this.lng,
  });

  factory Game.fromJson(Map<String, dynamic> json) {
    return Game(
      id: json['id'],
      hostPlayer: json['host_player'] != null
          ? PadlyUser.fromJson(
              json['host_player'] is String
                  ? jsonDecode(json['host_player'])
                  : json['host_player'] as Map<String, dynamic>,
            )
          : null,
      date: json['date'] != null ? DateTime.parse(json['date']) : null,
      startTime: json['start_time'] != null
          ? DateTime.parse(json['start_time'])
          : null,
      endTime:
          json['end_time'] != null ? DateTime.parse(json['end_time']) : null,
      location: json['location'],
      distanceKm: json['distance_km'] != null
          ? double.parse(
              (json['distance_km'] as num).toDouble().toStringAsFixed(2))
          : null,
      rankingMin:
          json['ranking_min'] != null ? "P${json['ranking_min']}" : null,
      rankingMax:
          json['ranking_max'] != null ? "P${json['ranking_max']}" : null,
      pricePerHour: json['price_per_hour'] != null
          ? (json['price_per_hour'] as num).toDouble()
          : null,
      maxPlayers: json['max_players'] != null
          ? (json['max_players'] as num).toInt()
          : null,
      currentPlayers: json['current_players'] != null
          ? List<PadlyUser>.from(
              (json['current_players'] as List).map(
                (player) => PadlyUser.fromJson(
                  player is String
                      ? jsonDecode(player)
                      : player as Map<String, dynamic>,
                ),
              ),
            )
          : null,
      club: json['club'],
      lat: json['lat'] != null ? (json['lat'] as num).toDouble() : null,
      lng: json['lng'] != null ? (json['lng'] as num).toDouble() : null,
    );
  }
}
