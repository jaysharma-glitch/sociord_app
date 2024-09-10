// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'personality_trait_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PersonalityTraitModel _$PersonalityTraitModelFromJson(
        Map<String, dynamic> json) =>
    PersonalityTraitModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      image: json['image'] as String,
    );

Map<String, dynamic> _$PersonalityTraitModelToJson(
        PersonalityTraitModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'image': instance.image,
    };
