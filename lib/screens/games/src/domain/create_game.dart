class GameCreate {
  final DateTime date;
  final DateTime startTime;
  final DateTime endTime;
  final double lat;
  final double lng;

  final String? location;
  final String? club;
  final int? maxPlayers;
  final double? pricePerHour;
  final int? rankingMin;
  final int? rankingMax;

  final List<Map<String, dynamic>>? currentPlayers;
  final Map<String, dynamic>? hostPlayer;

  const GameCreate({
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.lat,
    required this.lng,
    this.location,
    this.club,
    this.maxPlayers,
    this.pricePerHour,
    this.rankingMin,
    this.rankingMax,
    this.currentPlayers,
    this.hostPlayer,
  });

  Map<String, dynamic> toInsertJson() => {
        'date': date.toIso8601String().substring(0, 10),
        'start_time': startTime.toUtc().toIso8601String(),
        'end_time': endTime.toUtc().toIso8601String(),
        'lat': lat,
        'lng': lng,
        if (location != null) 'location': location,
        if (club != null) 'club': club,
        if (maxPlayers != null) 'max_players': maxPlayers,
        if (pricePerHour != null) 'price_per_hour': pricePerHour,
        if (rankingMin != null) 'ranking_min': rankingMin,
        if (rankingMax != null) 'ranking_max': rankingMax,
        if (currentPlayers != null) 'current_players': currentPlayers,
        if (hostPlayer != null) 'host_player': hostPlayer,
      };
}
