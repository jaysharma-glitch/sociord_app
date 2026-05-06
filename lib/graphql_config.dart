import 'package:graphql_flutter/graphql_flutter.dart';

class GraphQLConfig {
  /// Default is for simulator/emulator or when the backend runs on the same machine.
  /// On a **physical device**, `localhost` is the phone — use your Mac's LAN IP or
  /// pass `--dart-define=GRAPHQL_URL=...`.
  static final HttpLink httpLink = HttpLink(
    const String.fromEnvironment(
      'GRAPHQL_URL',
      defaultValue: 'http://localhost:9090/graphql',
    ),
    defaultHeaders: const <String, String>{
      // Required by Apollo Server CSRF prevention for multipart uploads.
      'apollo-require-preflight': 'true',
      'x-apollo-operation-name': 'sociord-mobile',
    },
  );

  GraphQLClient clientToQuery() =>
      GraphQLClient(link: httpLink, cache: GraphQLCache());
}
