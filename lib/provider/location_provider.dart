import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:http/http.dart' as http;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'dart:convert';

import 'package:sociord/models/location_model.dart';
import 'package:sociord/services/location_service.dart';

part 'location_provider.g.dart'; // Add this part directive

@riverpod
class LocationNotifier extends _$LocationNotifier {
  @override
  LocationState build() {
    return LocationState(
      loading: false,
      location: null,
      suggestions: [],
      error: null,
    );
  }

  Future<bool> handleLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      state = state.copyWith(
          error: 'Location services are disabled. Please enable the services');
      return false;
    }
    print('checkin per');
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();

      if (permission == LocationPermission.denied) {
        state = state.copyWith(error: 'Location permissions are denied');
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      state = state.copyWith(
          error:
              'Location permissions are permanently denied, we cannot request permissions.');
      return false;
    }
    return true;
  }

  Future<void> getCurrentPosition() async {
    state = state.copyWith(loading: true);
    try {
      final bool isAllowed = await handleLocationPermission();
      if (!isAllowed) return;

      final position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      final placemarks =
          await placemarkFromCoordinates(position.latitude, position.longitude);
      final place = placemarks[0];

      final location = LocationModel(
        lat: position.latitude,
        long: position.longitude,
        street: place.street ?? '',
        city: place.locality ?? '',
        state: place.administrativeArea ?? '',
        zipCode: place.postalCode ?? '',
      );

      state = state.copyWith(loading: false, location: location);
      print('location set');
    } catch (e) {
      state = state.copyWith(loading: false, error: e.toString());
    }
  }

  Future<void> getSuggestion(String input, sessionToken) async {
    const String PLACES_API_KEY = "AIzaSyCEgHihARBlyKYC1lDjZohM8N5D88RUoRs";

    try {
      String baseURL =
          'https://maps.googleapis.com/maps/api/place/autocomplete/json';
      String request =
          '$baseURL?input=$input&key=$PLACES_API_KEY&sessiontoken=$sessionToken';
      var response = await http.get(Uri.parse(request));
      var data = json.decode(response.body);

      if (response.statusCode == 200) {
        state =
            state.copyWith(loading: false, suggestions: data['predictions']);
      } else {
        throw Exception('Failed to load predictions');
      }
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> fetchPlaceDetails(String placeId) async {
    const String PLACES_API_KEY = "AIzaSyCEgHihARBlyKYC1lDjZohM8N5D88RUoRs";

    final url =
        'https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&fields=address_components&key=$PLACES_API_KEY';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      final addressComponents = data['result']['address_components'];

      String street = '';
      String city = '';
      String statee = '';
      String zipCode = '';

      for (final component in addressComponents) {
        final types = List<String>.from(component['types']);

        if (types.contains('street_number') || types.contains('route')) {
          street = component['long_name'];
        } else if (types.contains('locality')) {
          city = component['long_name'];
        } else if (types.contains('administrative_area_level_1')) {
          statee = component['short_name'];
        } else if (types.contains('postal_code')) {
          zipCode = component['long_name'];
        }
      }

      final location = LocationModel(
        lat: state.location != null ? state.location!.lat : 00,
        long: state.location != null ? state.location!.long : 00,
        street: street,
        city: city,
        state: statee,
        zipCode: zipCode,
      );

      state = state.copyWith(location: location);
    } else {
      throw Exception('Failed to load place details');
    }
  }

  Future<LocationModel?> addLocation(userId) async {
    var locationService = LocationService();
    var res = await locationService.addLocation(
        userId: userId,
        lat: state.location?.lat,
        long: state.location?.long,
        street: state.location?.street,
        city: state.location?.city,
        state: state.location?.state,
        zipCode: state.location?.zipCode);
    print('in provider $res');
    return res;
  }
}

class LocationState {
  final bool loading;
  final LocationModel? location;
  final List? suggestions;
  final String? error;

  LocationState({
    required this.loading,
    this.location,
    this.suggestions,
    this.error,
  });

  LocationState copyWith({
    bool? loading,
    LocationModel? location,
    List? suggestions,
    String? error,
  }) {
    return LocationState(
      loading: loading ?? this.loading,
      location: location ?? this.location,
      suggestions: suggestions ?? this.suggestions,
      error: error ?? this.error,
    );
  }
}
