import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:sociord/graphql_config.dart';
import 'package:sociord/models/personality_trait_model.dart';

class UserPersonalityService {
  static GraphQLConfig graphQLConfig = GraphQLConfig();
  GraphQLClient client = graphQLConfig.clientToQuery();

  Future<List<dynamic>> getSoundtrackOptions() async {
    try {
      QueryResult result = await client.query(
        QueryOptions(
          fetchPolicy: FetchPolicy.noCache,
          document: gql("""
       query GetSoundtrackOption {
          getSoundtrackOption {
            id
            title
            description
            image
          }
        }
      """),
        ),
      );
      if (result.hasException) {
        throw Exception(result.exception);
      }

      var res = result.data?['getSoundtrackOption'];
      print(res);
      if (res == null || res.isEmpty) {
        return [];
      }
      print(res);
      List<dynamic> options =
          res.map((r) => PersonalityTraitModel.fromJson(r)).toList();
      return options;
    } catch (error) {
      throw Exception(error);
    }
  }

  Future<List<dynamic>> getWeekendOption() async {
    try {
      QueryResult result = await client.query(
        QueryOptions(
          fetchPolicy: FetchPolicy.noCache,
          document: gql("""
       query GetWeekendOption {
        getWeekendOption {
          id
          title
          description
          image
        }
      }
      """),
        ),
      );
      if (result.hasException) {
        throw Exception(result.exception);
      }

      var res = result.data?['getWeekendOption'];
      print(res);
      if (res == null || res.isEmpty) {
        return [];
      }
      print(res);
      List<dynamic> options =
          res.map((r) => PersonalityTraitModel.fromJson(r)).toList();
      return options;
    } catch (error) {
      throw Exception(error);
    }
  }

  Future<List<dynamic>> getConnectOption() async {
    try {
      QueryResult result = await client.query(
        QueryOptions(
          fetchPolicy: FetchPolicy.noCache,
          document: gql("""
       query GetConnectOption {
        getConnectOption {
          id
          title
          description
          image
        }
      }
      """),
        ),
      );
      if (result.hasException) {
        throw Exception(result.exception);
      }

      var res = result.data?['getConnectOption'];
      print(res);
      if (res == null || res.isEmpty) {
        return [];
      }
      print(res);
      List<dynamic> options =
          res.map((r) => PersonalityTraitModel.fromJson(r)).toList();
      return options;
    } catch (error) {
      throw Exception(error);
    }
  }

  Future<List<dynamic>> getBingeWatchOption() async {
    try {
      QueryResult result = await client.query(
        QueryOptions(
          fetchPolicy: FetchPolicy.noCache,
          document: gql("""
       query GetConnectOption {
        getBingeWatchOption {
          id
          title
          description
          image
        }
      }
      """),
        ),
      );
      if (result.hasException) {
        throw Exception(result.exception);
      }

      var res = result.data?['getBingeWatchOption'];
      print(res);
      if (res == null || res.isEmpty) {
        return [];
      }
      print(res);
      List<dynamic> options =
          res.map((r) => PersonalityTraitModel.fromJson(r)).toList();
      return options;
    } catch (error) {
      throw Exception(error);
    }
  }

  Future<dynamic> getPetOption() async {
    try {
      QueryResult result = await client.query(
        QueryOptions(
          fetchPolicy: FetchPolicy.noCache,
          document: gql("""
       query GetPetOption {
        getPetOption {
          id
          title
          description
          image
        }
      }
      """),
        ),
      );
      if (result.hasException) {
        throw Exception(result.exception);
      }

      var res = result.data?['getPetOption'];
      print(res);
      if (res == null || res.isEmpty) {
        return [];
      }
      print(res);
      List<dynamic> options =
          res.map((r) => PersonalityTraitModel.fromJson(r)).toList();
      return options;
    } catch (error) {
      throw Exception(error);
    }
  }

  Future<String?> addUserSoundtrackSelection(
      {required userId, required data}) async {
    try {
      QueryResult result = await client.mutate(
        MutationOptions(fetchPolicy: FetchPolicy.noCache, document: gql("""
       mutation AddUserSoundtrackSelection(\$input: AddUserData) {
          addUserSoundtrackSelection(input: \$input)
        }
      """), variables: {
          "input": {"userId": userId, "data": data}
        }),
      );
      if (result.hasException) {
        throw Exception(result.exception);
      }

      var res = result.data?['addUserSoundtrackSelection'];
      print(res);
      if (res == null || res.isEmpty) {
        return null;
      }
      print(res);
      return res;
    } catch (error) {
      throw Exception(error);
    }
  }

  Future<String?> addUserWeekendSelection(
      {required userId, required data}) async {
    try {
      QueryResult result = await client.mutate(
        MutationOptions(fetchPolicy: FetchPolicy.noCache, document: gql("""
       mutation AddUserWeekendSelection(\$input: AddUserData) {
          addUserWeekendSelection(input: \$input)
        }
      """), variables: {
          "input": {"userId": userId, "data": data}
        }),
      );
      if (result.hasException) {
        throw Exception(result.exception);
      }

      var res = result.data?['addUserWeekendSelection'];
      print(res);
      if (res == null || res.isEmpty) {
        return null;
      }
      print(res);
      return res;
    } catch (error) {
      throw Exception(error);
    }
  }

  Future<String?> addUserConnectSelection(
      {required userId, required data}) async {
    try {
      QueryResult result = await client.mutate(
        MutationOptions(fetchPolicy: FetchPolicy.noCache, document: gql("""
       mutation AddUserConnectSelection(\$input: AddUserData) {
          addUserConnectSelection(input: \$input)
        }
      """), variables: {
          "input": {"userId": userId, "data": data}
        }),
      );
      if (result.hasException) {
        throw Exception(result.exception);
      }

      var res = result.data?['addUserConnectSelection'];
      print(res);
      if (res == null || res.isEmpty) {
        return null;
      }
      print(res);
      return res;
    } catch (error) {
      throw Exception(error);
    }
  }

  Future<String?> addUserBingeWatchSelection(
      {required userId, required data}) async {
    try {
      QueryResult result = await client.mutate(
        MutationOptions(fetchPolicy: FetchPolicy.noCache, document: gql("""
       mutation AddUserBingeWatchSelection(\$input: AddUserData) {
        addUserBingeWatchSelection(input: \$input)
      }
      """), variables: {
          "input": {"userId": userId, "data": data}
        }),
      );
      if (result.hasException) {
        throw Exception(result.exception);
      }

      var res = result.data?['addUserBingeWatchSelection'];
      print(res);
      if (res == null || res.isEmpty) {
        return null;
      }
      print(res);
      return res;
    } catch (error) {
      throw Exception(error);
    }
  }

  Future<String?> addUserPetSelection({required userId, required data}) async {
    try {
      QueryResult result = await client.mutate(
        MutationOptions(fetchPolicy: FetchPolicy.noCache, document: gql("""
       mutation AddUserPetSelection(\$input: AddUserData) {
        addUserPetSelection(input: \$input)
      }
      """), variables: {
          "input": {"userId": userId, "data": data}
        }),
      );
      if (result.hasException) {
        throw Exception(result.exception);
      }

      var res = result.data?['addUserPetSelection'];
      print(res);
      if (res == null || res.isEmpty) {
        return null;
      }
      print(res);
      return res;
    } catch (error) {
      throw Exception(error);
    }
  }
}
