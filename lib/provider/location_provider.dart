import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:http/http.dart' as http;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'dart:convert';

import 'package:sociord/models/location_model.dart';
import 'package:sociord/provider/user_provider.dart';
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
        error: 'Location services are disabled. Please enable the services',
      );
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
            'Location permissions are permanently denied, we cannot request permissions.',
      );
      return false;
    }
    return true;
  }

  Future<LocationModel?> getCurrentPosition() async {
    state = state.copyWith(loading: true, clearError: true);
    try {
      // Don't check permission again - it should already be checked before calling this
      print('Getting current position...');
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );
      print('Position obtained: ${position.latitude}, ${position.longitude}');

      print('Getting placemarks...');
      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isEmpty) {
        throw Exception('No placemarks found for coordinates');
      }

      final place = placemarks[0];
      print('Place found: ${place.locality}, ${place.administrativeArea}');

      final location = LocationModel(
        lat: position.latitude,
        long: position.longitude,
        street: place.street ?? '',
        city: place.locality ?? '',
        state: place.administrativeArea ?? '',
        zipCode: place.postalCode ?? '',
      );

      state = state.copyWith(loading: false, location: location, clearError: true);
      print('Location set successfully in state. Location: ${location.city}, ${location.state}. State error: ${state.error}, State location: ${state.location?.city}');
      return location;
    } catch (e) {
      print('Error in getCurrentPosition: $e');
      state = state.copyWith(loading: false, error: e.toString());
      return null;
    }
  }

  Future<void> getSuggestion(String input, sessionToken) async {
    const String PLACES_API_KEY = "AIzaSyCEgHihARBlyKYC1lDjZohM8N5D88RUoRs";

    try {
      state = state.copyWith(loading: true, error: null);

      String baseURL =
          'https://maps.googleapis.com/maps/api/place/autocomplete/json';
      String request =
          '$baseURL?input=$input&key=$PLACES_API_KEY&sessiontoken=$sessionToken';

      print('Places API Request: $request');

      var response = await http.get(Uri.parse(request));
      var data = json.decode(response.body);

      print('Places API Response Status: ${response.statusCode}');
      print('Places API Response: ${response.body}');

      if (response.statusCode == 200) {
        if (data['status'] == 'OK' && data['predictions'] != null) {
          state = state.copyWith(
            loading: false,
            suggestions: data['predictions'],
            error: null,
          );
          print('Suggestions set: ${data['predictions'].length} items');
        } else {
          // Handle API errors like OVER_QUERY_LIMIT, REQUEST_DENIED, etc.
          final status = data['status'] ?? 'UNKNOWN';
          final errorMessage = data['error_message'] ?? 'Unknown error';
          print('Places API Error Status: $status, Message: $errorMessage');
          state = state.copyWith(
            loading: false,
            suggestions: [],
            error: 'API Error: $status - $errorMessage',
          );
        }
      } else {
        throw Exception('Failed to load predictions: ${response.statusCode}');
      }
    } catch (e) {
      print('Exception in getSuggestion: $e');
      state = state.copyWith(
        loading: false,
        suggestions: [],
        error: e.toString(),
      );
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
      ref.read(userNotifierProvider.notifier).setLocation(location);
    } else {
      throw Exception('Failed to load place details');
    }
  }

  Future<LocationModel?> addLocation(userId, LocationModel location) async {
    var locationService = LocationService();
    var res = await locationService.addLocation(
      userId: userId,
      lat: location.lat,
      long: location.long,
      street: location.street,
      city: location.city,
      state: location.state,
      zipCode: location.zipCode,
    );
    print('in provider $res');

    // Update state with the location after successful submission
    state = state.copyWith(location: location);

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
    bool clearError = false,
  }) {
    return LocationState(
      loading: loading ?? this.loading,
      location: location ?? this.location,
      suggestions: suggestions ?? this.suggestions,
      error: clearError ? null : (error ?? this.error),
    );
  }

  @override
  String toString() {
    return 'LocationState(loading: $loading, location: ${location?.city ?? "null"}, error: $error)';
  }
}
