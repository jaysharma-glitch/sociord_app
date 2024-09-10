import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:sociord/graphql_config.dart';
import 'package:sociord/models/location_model.dart';

class LocationService {
  static GraphQLConfig graphQLConfig = GraphQLConfig();
  GraphQLClient client = graphQLConfig.clientToQuery();

  Future<LocationModel?> addLocation(
      {required userId,
      required lat,
      required long,
      required street,
      required city,
      required state,
      required zipCode}) async {
    try {
      QueryResult result = await client.mutate(
        MutationOptions(fetchPolicy: FetchPolicy.noCache, document: gql("""
        mutation AddLocation(\$input: CreateLocationInput!) {
          addLocation(input: \$input) {
            userLocationId
            userId
            lat
            long
            street
            city
            state
            zipCode
          }
        }
      """), variables: {
          "input": {
            "userId": userId,
            "lat": lat,
            "long": long,
            "street": street,
            "city": city,
            "state": state,
            "zipCode": zipCode
          },
        }),
      );
      if (result.hasException) {
        throw Exception(result.exception);
      }

      var res = result.data?['addLocation'];
      print(res);
      if (res == null || res.isEmpty) {
        return null;
      }
      print(res);
      LocationModel user = LocationModel.fromJson(res);
      return user;
    } catch (error) {
      throw Exception(error);
    }
  }
}
