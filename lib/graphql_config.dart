import 'package:graphql_flutter/graphql_flutter.dart';

class GraphQLConfig {
  // static HttpLink httpLink = HttpLink('http://localhost:9090/graphql');
  static HttpLink httpLink =
      HttpLink('https://sociord-backend.onrender.com/graphql');

  GraphQLClient clientToQuery() =>
      GraphQLClient(link: httpLink, cache: GraphQLCache());
}
