import 'package:json_annotation/json_annotation.dart';

part 'personality_trait_model.g.dart';

@JsonSerializable()
class PersonalityTraitModel {
  final String id;
  final String title;
  final String description;
  final String image;

  PersonalityTraitModel({
    required this.id,
    required this.title,
    required this.description,
    required this.image,
  });

  // Factory constructor for creating a new `PersonalityTrait` instance from a map
  factory PersonalityTraitModel.fromJson(Map<String, dynamic> json) =>
      _$PersonalityTraitModelFromJson(json);

  // Method for converting a `PersonalityTrait` instance to a map
  Map<String, dynamic> toJson() => _$PersonalityTraitModelToJson(this);
}
