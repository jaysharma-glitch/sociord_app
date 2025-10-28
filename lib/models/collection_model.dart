import 'package:sociord/models/clip_model.dart';

class CollectionModel {
  final String id;
  final String title;
  final String rating;
  final List<ClipModel> posts;

  const CollectionModel({
    required this.id,
    required this.title,
    required this.rating,
    required this.posts,
  });
}
