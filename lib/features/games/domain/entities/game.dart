import 'dart:convert';

import 'package:padly/features/users/domain/entities/padly_user.dart';

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
  final List<PadlyUser>? joinRequests;
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
    this.joinRequests,
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
      joinRequests: json['join_requests'] != null
          ? List<PadlyUser>.from(
              (json['join_requests'] as List).map(
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

  Game copyWith({
    String? id,
    PadlyUser? hostPlayer,
    DateTime? date,
    DateTime? startTime,
    DateTime? endTime,
    String? location,
    double? distanceKm,
    String? rankingMin,
    String? rankingMax,
    double? pricePerHour,
    int? maxPlayers,
    List<PadlyUser>? currentPlayers,
    List<PadlyUser>? joinRequests,
    String? club,
    double? lat,
    double? lng,
  }) {
    return Game(
      id: id ?? this.id,
      hostPlayer: hostPlayer ?? this.hostPlayer,
      date: date ?? this.date,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      location: location ?? this.location,
      distanceKm: distanceKm ?? this.distanceKm,
      rankingMin: rankingMin ?? this.rankingMin,
      rankingMax: rankingMax ?? this.rankingMax,
      pricePerHour: pricePerHour ?? this.pricePerHour,
      maxPlayers: maxPlayers ?? this.maxPlayers,
      currentPlayers: currentPlayers ?? this.currentPlayers,
      joinRequests: joinRequests ?? this.joinRequests,
      club: club ?? this.club,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
    );
  }
}
