import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:sociord/graphql_config.dart';
import 'package:sociord/models/user_model.dart';
import 'package:http/http.dart' as http;

class UserService {
  static GraphQLConfig graphQLConfig = GraphQLConfig();
  GraphQLClient client = graphQLConfig.clientToQuery();

  Future<UserModel?> getUser({required userId}) async {
    try {
      QueryResult result = await client.query(
        QueryOptions(
          fetchPolicy: FetchPolicy.noCache,
          document: gql("""
        query GetUser(\$userId: ID!) {
          getUser(id: \$userId) {
            userId
            profileType
            firstName
            lastName
            countryCode
            phoneNumber
            location {
              userLocationId
              userId
              lat
              long
              street
              city
              state
              zipCode
            }
            userName
            gender
            otherIdenty
            birthDate
            contentType
            profilePic
          }
        }
      """),
          variables: {"userId": userId},
        ),
      );
      if (result.hasException) {
        throw Exception(result.exception);
      }

      var res = result.data?['getUser'];
      print(res);
      if (res == null || res.isEmpty) {
        return null;
      }
      print(res);
      UserModel user = UserModel.fromJson(res);
      return user;
    } catch (error) {
      throw Exception(error);
    }
  }

  Future<String?> createUser({
    required profileType,
    required firstName,
    required lastName,
    required countryCode,
    required phoneNumber,
  }) async {
    try {
      QueryResult result = await client.mutate(
        MutationOptions(
          fetchPolicy: FetchPolicy.noCache,
          document: gql("""
        mutation Mutation(\$input: CreateUserInput!) {
          createUser(input: \$input) {
            userId
            profileType
            firstName
            lastName
            countryCode
            phoneNumber
          }
        }
      """),
          variables: {
            "input": {
              "profileType": profileType,
              "firstName": firstName,
              "lastName": lastName,
              "countryCode": countryCode,
              "phoneNumber": phoneNumber,
            },
          },
        ),
      );

      if (result.hasException) {
        throw Exception(result.exception);
      }

      var res = result.data?['createUser'];
      print('in service $res');
      if (res == null || res.isEmpty) {
        return null;
      }

      return res['userId'];
    } catch (error) {
      throw Exception(error);
    }
  }

  Future<bool> confirmOtp({
    required countryCode,
    required phoneNumber,
    required otp,
  }) async {
    try {
      QueryResult result = await client.mutate(
        MutationOptions(
          fetchPolicy: FetchPolicy.noCache,
          document: gql("""
        mutation Mutation(\$phoneNumber: String!, \$countryCode: String!, \$otp: String!) {
          confirmUserOtp(phoneNumber: \$phoneNumber, countryCode: \$countryCode, otp: \$otp) {
            message
            success
          }
        }
      """),
          variables: {
            "phoneNumber": phoneNumber,
            "countryCode": countryCode,
            "otp": otp,
          },
        ),
      );

      if (result.hasException) {
        throw Exception(result.exception);
      }
      print(result);
      var res = result.data?['confirmUserOtp'];
      print('in service $res');
      if (res == null || res.isEmpty) {
        return false;
      }

      return res['success'];
    } catch (error) {
      throw Exception(error);
    }
  }

  Future<bool> resendOtp({required countryCode, required phoneNumber}) async {
    try {
      QueryResult result = await client.mutate(
        MutationOptions(
          fetchPolicy: FetchPolicy.noCache,
          document: gql("""
        mutation ResendOtp(\$countryCode: String!, \$phoneNumber: String!) {
          resendOtp(countryCode: \$countryCode, phoneNumber: \$phoneNumber)
        }
      """),
          variables: {"phoneNumber": phoneNumber, "countryCode": countryCode},
        ),
      );

      if (result.hasException) {
        throw Exception(result.exception);
      }
      print(result);
      var res = result.data?['resendOtp'];
      print('in service $res');
      return res;
    } catch (error) {
      throw Exception(error);
    }
  }

  Future<bool> checkUsername({required userName}) async {
    try {
      QueryResult result = await client.query(
        QueryOptions(
          fetchPolicy: FetchPolicy.noCache,
          document: gql("""
        query Query(\$userName: String!) {
          checkUserName(userName: \$userName)
        }
      """),
          variables: {"userName": userName},
        ),
      );
      if (result.hasException) {
        throw Exception(result.exception);
      }

      var res = result.data?['checkUserName'];

      print(res);

      return res;
    } catch (error) {
      throw Exception(error);
    }
  }

  Future<List> generateUsernameOptions({
    required userName,
    required userId,
  }) async {
    try {
      QueryResult result = await client.query(
        QueryOptions(
          fetchPolicy: FetchPolicy.noCache,
          document: gql("""
        query Query(\$userName: String!, \$userId: ID!) {
          generateUsernameOptions(userName: \$userName, userId: \$userId)
        }
      """),
          variables: {"userName": userName, "userId": userId},
        ),
      );
      if (result.hasException) {
        throw Exception(result.exception);
      }

      var res = result.data?['generateUsernameOptions'];
      print(res);
      if (res == null || res.isEmpty) {
        return [];
      }

      return res;
    } catch (error) {
      throw Exception(error);
    }
  }

  Future<Map?> completeOnboarding({
    required userId,
    required userName,
    required gender,
    required otherIdenty,
    required birthDate,
    required contentType,
  }) async {
    try {
      QueryResult result = await client.mutate(
        MutationOptions(
          fetchPolicy: FetchPolicy.noCache,
          document: gql("""
        mutation CompleteOnboarding(\$input: CompleteOnboardingInput!) {
          completeOnboarding(input: \$input) {
            userId
          }
        }
      """),
          variables: {
            "input": {
              "userId": userId,
              "userName": userName,
              "gender": gender,
              "otherIdenty": otherIdenty,
              "birthDate": birthDate,
              "contentType": contentType,
            },
          },
        ),
      );
      if (result.hasException) {
        throw Exception(result.exception);
      }
      print(result);
      var res = result.data?['completeOnboarding'];
      print(res);
      if (res == null || res.isEmpty) {
        return null;
      }

      return res;
    } catch (error) {
      throw Exception(error);
    }
  }

  Future<String?> addProfilePic({required userId, required image}) async {
    try {
      QueryResult result = await client.mutate(
        MutationOptions(
          fetchPolicy: FetchPolicy.noCache,
          document: gql("""
        mutation AddProfilePic(\$input: UpdateImage!) {
          addProfilePic(input: \$input)
        }
      """),
          variables: {
            "input": {"userId": userId, "image": image},
          },
        ),
      );

      if (result.hasException) {
        throw Exception(result.exception);
      }
      print(result);
      var res = result.data?['addProfilePic'];
      print(res);
      if (res == null || res.isEmpty) {
        return null;
      }

      return res;
    } catch (error) {
      throw Exception(error);
    }
  }

  Future<String?> getSignedUrl({required fileType, required folder}) async {
    try {
      QueryResult result = await client.query(
        QueryOptions(
          fetchPolicy: FetchPolicy.noCache,
          document: gql("""
        query Query(\$fileType: String!, \$folder: String!) {
          getSignedUrl(fileType: \$fileType, folder: \$folder)
        }
      """),
          variables: {"fileType": fileType, "folder": folder},
        ),
      );

      if (result.hasException) {
        throw Exception(result.exception);
      }
      print(result);
      var res = result.data?['getSignedUrl'];
      print(res);
      if (res == null || res.isEmpty) {
        return null;
      }

      return res;
    } catch (error) {
      throw Exception(error);
    }
  }

  Future<bool> uploadFile({required file, required signedUrl}) async {
    final response = await http.put(
      Uri.parse(signedUrl),
      headers: {
        'Content-Type': 'image/png', // or the appropriate content type
      },
      body: file.readAsBytesSync(),
    );
    if (response.statusCode != 200) {
      print(response.body);
      throw Exception('Failed to upload file: ${response.body}');
    } else {
      return true;
    }
  }

  Future<String?> userLogin({
    required phoneNumber,
    required countryCode,
  }) async {
    print(countryCode);
    print(phoneNumber);
    try {
      QueryResult result = await client.query(
        QueryOptions(
          fetchPolicy: FetchPolicy.noCache,
          document: gql("""
        query Query(\$phoneNumber: String!, \$countryCode: String!) {
          userLogin(phoneNumber: \$phoneNumber, countryCode: \$countryCode)
        }
      """),
          variables: {"phoneNumber": phoneNumber, "countryCode": countryCode},
        ),
      );
      print('servicee $result');
      if (result.hasException) {
        throw Exception(result.exception);
      }
      var res = result.data?['userLogin'];
      print("service $res");
      if (res == null || res.isEmpty) {
        return null;
      }
      return res;
    } catch (error) {
      throw Exception(error);
    }
  }
}
