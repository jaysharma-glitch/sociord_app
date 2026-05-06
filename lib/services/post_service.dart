import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:sociord/graphql_config.dart';

class PostService {
  static GraphQLConfig graphQLConfig = GraphQLConfig();
  final GraphQLClient client = graphQLConfig.clientToQuery();

  Future<Map<String, dynamic>> createPostMedia({
    required String userId,
    required String postType,
    required String title,
    String? description,
    String? backgroundMusic,
    String? collectionId,
    List<String> taggedUserIds = const <String>[],
    List<http.MultipartFile> images = const <http.MultipartFile>[],
    List<http.MultipartFile> videos = const <http.MultipartFile>[],
    http.MultipartFile? coverImage,
  }) async {
    final result = await client.mutate(
      MutationOptions(
        fetchPolicy: FetchPolicy.noCache,
        document: gql(r'''
          mutation CreatePostMedia($input: CreatePostMediaInput!) {
            createPostMedia(input: $input) {
              id
              userId
              type
              title
              description
              coverImage
              backgroundMusic
              collectionId
              imageUrls
              videoUrls
              taggedUserIds
              createdAt
              updatedAt
            }
          }
        '''),
        variables: <String, dynamic>{
          'input': <String, dynamic>{
            'userId': userId,
            'postType': postType,
            'title': title,
            'description': description,
            'backgroundMusic': backgroundMusic,
            'collectionId': collectionId,
            'taggedUserIds': taggedUserIds,
            'images': images,
            'videos': videos,
            'coverImage': coverImage,
          },
        },
      ),
    );

    if (result.hasException) {
      final gqlErrors = result.exception?.graphqlErrors
          .map((e) => e.message)
          .join(' | ');
      final linkError = result.exception?.linkException?.toString();
      throw Exception(
        'createPostMedia failed'
        '${gqlErrors != null && gqlErrors.isNotEmpty ? ': $gqlErrors' : ''}'
        '${linkError != null ? ' (${linkError})' : ''}',
      );
    }

    final data = result.data?['createPostMedia'];
    if (data == null) {
      throw Exception('Post creation returned empty response');
    }

    return Map<String, dynamic>.from(data as Map);
  }
}

