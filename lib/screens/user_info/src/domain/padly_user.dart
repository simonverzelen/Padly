import 'package:cloud_firestore/cloud_firestore.dart' show Timestamp;

class PadlyUser {
  final String? id;
  final String? firstName;
  final String? lastName;
  final String? fullName;
  final String? email;
  final DateTime? lastSeen;
  final String? imageUrl;
  final String? rank;
  final List<String>? selectedSports;
  final Map<String, String>? sportLevels;

  PadlyUser({
    this.id,
    this.firstName,
    this.lastName,
    this.fullName,
    this.email,
    this.lastSeen,
    this.imageUrl,
    this.rank,
    this.selectedSports,
    this.sportLevels,
  });

  factory PadlyUser.fromJson(Map<String, dynamic> json) => PadlyUser(
        id: json["id"] as String?,
        firstName: json["firstName"] as String?,
        lastName: json["lastName"] as String?,
        fullName: json["name"] as String?,
        email: json["email"] as String?,
        lastSeen: json['lastSeen'] != null
            ? json["lastSeen"] is Timestamp
                ? (json["lastSeen"] as Timestamp).toDate()
                : DateTime.tryParse(json["lastSeen"])
            : null,
        imageUrl: json["imageUrl"] as String?,
        rank: json["rank"] as String?,
        selectedSports:
            (json['selectedSports'] as List<dynamic>?)?.cast<String>(),
        sportLevels: (json['sportLevels'] as Map<String, dynamic>?)
            ?.cast<String, String>(),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "firstName": firstName,
        "lastName": lastName,
        "email": email,
        "lastSeen": lastSeen?.toIso8601String(),
        "imageUrl": imageUrl,
        "rank": rank,
      };
}
