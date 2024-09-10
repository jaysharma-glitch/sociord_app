import 'package:json_annotation/json_annotation.dart';

part 'location_model.g.dart';

@JsonSerializable()
class LocationModel {
  final double lat;
  final double long;
  final String street;
  final String city;
  final String state;
  final String zipCode;

  LocationModel({
    required this.lat,
    required this.long,
    required this.street,
    required this.city,
    required this.state,
    required this.zipCode,
  });

  factory LocationModel.fromJson(Map<String, dynamic> json) =>
      _$LocationModelFromJson(json);
  Map<String, dynamic> toJson() => _$LocationModelToJson(this);
}
