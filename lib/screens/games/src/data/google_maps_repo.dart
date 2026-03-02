// data/google_places_repository.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';

import '../domain/club.dart';

class GooglePlacesRepository {
  GooglePlacesRepository(this.apiKey);

  final String apiKey;
  final _uuid = const Uuid();

  String? _sessionToken;

  bool get hasActiveSession => _sessionToken != null;

  void startSession() {
    if (_sessionToken != null) return; // 🔒 safeguard
    _sessionToken = _uuid.v4();
  }

  void endSession() {
    _sessionToken = null;
  }

  Future<List<AutocompleteResult>> autocomplete(String input) async {
    if (input.isEmpty) return [];

    if (_sessionToken == null) {
      throw StateError(
        'Autocomplete called without active session. '
        'Call startSession() first.',
      );
    }

    final uri = Uri.https(
      'maps.googleapis.com',
      '/maps/api/place/autocomplete/json',
      {
        'input': input,
        'key': apiKey,
        'sessiontoken': _sessionToken!,
        'components': 'country:be',
        'language': 'nl',
      },
    );

    final response = await http.get(uri);
    final body = json.decode(response.body);

    if (body['status'] != 'OK') return [];

    return (body['predictions'] as List)
        .map((p) => AutocompleteResult(
              placeId: p['place_id'],
              name: p['structured_formatting']['main_text'],
              description: p['structured_formatting']['secondary_text'],
            ))
        .toList();
  }

  Future<ClubPlace?> getPlaceDetails(String placeId) async {
    if (_sessionToken == null) {
      throw StateError(
        'Place details called without active session.',
      );
    }

    final uri = Uri.https(
      'maps.googleapis.com',
      '/maps/api/place/details/json',
      {
        'place_id': placeId,
        'key': apiKey,
        'sessiontoken': _sessionToken!,
        'fields': 'place_id,name,geometry,address_components',
        'language': 'nl',
      },
    );

    final response = await http.get(uri);
    final body = json.decode(response.body);

    if (body['status'] != 'OK') return null;

    final result = body['result'];

    return ClubPlace(
      placeId: result['place_id'],
      name: result['name'],
      address: formatAddress(result['address_components']),
      city: formatCity(result['address_components']),
      lat: result['geometry']['location']['lat'],
      lng: result['geometry']['location']['lng'],
    );
  }
}

/// INTERNAL AUTOCOMPLETE MODEL
class AutocompleteResult {
  final String placeId;
  final String name;
  final String description;

  AutocompleteResult({
    required this.placeId,
    required this.name,
    required this.description,
  });
}

String formatCity(List addressComponents) {
  for (final component in addressComponents) {
    final types = List<String>.from(component['types']);

    if (types.contains('locality')) {
      return component['long_name'];
    }

    if (types.contains('postal_town')) {
      return component['long_name'];
    }
  }

  return '';
}

String formatAddress(List addressComponents) {
  String? street;
  String? houseNumber;
  String? city;

  for (final component in addressComponents) {
    final types = List<String>.from(component['types']);

    if (types.contains('route')) {
      street = component['long_name'];
    }

    if (types.contains('street_number')) {
      houseNumber = component['long_name'];
    }

    if (types.contains('locality')) {
      city = component['long_name'];
    }

    // Fallback for Belgian cities
    if (city == null && types.contains('postal_town')) {
      city = component['long_name'];
    }
  }

  final streetPart = [
    street,
    houseNumber,
  ].where((e) => e != null).join(' ');

  final cityPart = city;

  if (streetPart.isEmpty) return cityPart ?? '';
  if (cityPart == null) return streetPart;

  return '$streetPart, $cityPart';
}
