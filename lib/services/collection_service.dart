import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:sociord/graphql_config.dart';

class CollectionService {
  static GraphQLConfig graphQLConfig = GraphQLConfig();
  final GraphQLClient client = graphQLConfig.clientToQuery();

  Future<List<Map<String, String>>> getCollectionsByUser(String userId) async {
    final result = await client.query(
      QueryOptions(
        fetchPolicy: FetchPolicy.noCache,
        document: gql(r'''
          query GetCollectionsByUser($userId: ID!) {
            getCollectionsByUser(userId: $userId) {
              collectionId
              title
            }
          }
        '''),
        variables: <String, dynamic>{'userId': userId},
      ),
    );

    if (result.hasException) {
      throw Exception(result.exception);
    }

    final data = result.data?['getCollectionsByUser'];
    if (data is! List) {
      return <Map<String, String>>[];
    }

    return data
        .map((item) => <String, String>{
              'id': (item['collectionId'] ?? '').toString(),
              'name': (item['title'] ?? '').toString(),
            })
        .where((item) => item['id']!.isNotEmpty && item['name']!.isNotEmpty)
        .toList();
  }

  Future<Map<String, String>> createCollection({
    required String userId,
    required String title,
  }) async {
    final result = await client.mutate(
      MutationOptions(
        fetchPolicy: FetchPolicy.noCache,
        document: gql(r'''
          mutation CreateCollection($input: CreateCollectionInput!) {
            createCollection(input: $input) {
              collectionId
              title
            }
          }
        '''),
        variables: <String, dynamic>{
          'input': <String, dynamic>{
            'userId': userId,
            'title': title,
          },
        },
      ),
    );

    if (result.hasException) {
      throw Exception(result.exception);
    }

    final data = result.data?['createCollection'];
    if (data == null) {
      throw Exception('Collection was not created');
    }

    return <String, String>{
      'id': (data['collectionId'] ?? '').toString(),
      'name': (data['title'] ?? '').toString(),
    };
  }
}

