import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:sociord/graphql_config.dart';
import 'package:sociord/models/user_model.dart';
import 'package:http/http.dart' as http;

class UserService {
  static GraphQLConfig graphQLConfig = GraphQLConfig();
  GraphQLClient client = graphQLConfig.clientToQuery();

  /// Convert snake_case keys to camelCase so we parse API responses either way.
  static Map<String, dynamic> _normalizeKeys(Map<String, dynamic> json) {
    final out = <String, dynamic>{};
    for (final e in json.entries) {
      final key = e.key.replaceAllMapped(
        RegExp(r'_([a-z])'),
        (m) => m.group(1)!.toUpperCase(),
      );
      final value = e.value;
      if (value is Map<String, dynamic>) {
        out[key] = _normalizeKeys(value);
      } else {
        out[key] = value;
      }
    }
    return out;
  }

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
            otherIdentity
            birthDate
            ageCohort
            contentType
            profilePic
            onboardingStatus
            creatorIntention
            isCreator
          }
        }
      """),
          variables: {"userId": userId},
        ),
      );
      if (result.hasException) {
        print('getUser error: ${result.exception}');
        return null;
      }
      if (result.exception?.graphqlErrors != null &&
          result.exception!.graphqlErrors.isNotEmpty) {
        print('getUser GraphQL errors: ${result.exception!.graphqlErrors}');
        return null;
      }

      var res = result.data?['getUser'];
      print(res);
      if (res == null || res.isEmpty) {
        return null;
      }
      // Support both camelCase (GraphQL) and snake_case (some APIs)
      final raw = Map<String, dynamic>.from(res as Map);
      final map = _normalizeKeys(raw);
      // Ensure location submap has no null strings so LocationModel.fromJson does not throw
      if (map['location'] != null && map['location'] is Map) {
        final loc = Map<String, dynamic>.from(map['location'] as Map);
        map['location'] = <String, dynamic>{
          'lat': loc['lat'] ?? 0,
          'long': loc['long'] ?? 0,
          'street': loc['street'] ?? '',
          'city': loc['city'] ?? '',
          'state': loc['state'] ?? '',
          'zipCode': loc['zipCode'] ?? '',
        };
      }
      UserModel user = UserModel.fromJson(map);
      return user;
    } on Object catch (error, stackTrace) {
      // Never rethrow: return null so callers never get unhandled exceptions (e.g. USER_NOT_FOUND)
      print('getUser catch: $error');
      print('getUser stackTrace: $stackTrace');
      return null;
    }
  }

  Future<List<Map<String, String>>> searchUsers({
    required String query,
    String? excludeUserId,
    int limit = 20,
  }) async {
    try {
      final trimmedQuery = query.trim();
      if (trimmedQuery.length < 2) return <Map<String, String>>[];

      QueryResult result = await client.query(
        QueryOptions(
          fetchPolicy: FetchPolicy.noCache,
          document: gql("""
        query SearchUsers(\$query: String!, \$limit: Int, \$excludeUserId: ID) {
          searchUsers(query: \$query, limit: \$limit, excludeUserId: \$excludeUserId) {
            userId
            userName
            firstName
            lastName
            profilePic
          }
        }
      """),
          variables: {
            "query": trimmedQuery,
            "limit": limit,
            "excludeUserId": excludeUserId,
          },
        ),
      );

      if (result.hasException) {
        throw Exception(result.exception);
      }

      final data = result.data?['searchUsers'];
      if (data is! List) return <Map<String, String>>[];

      return data.map<Map<String, String>>((item) {
        final row = Map<String, dynamic>.from(item as Map);
        final firstName = (row['firstName'] ?? '').toString().trim();
        final lastName = (row['lastName'] ?? '').toString().trim();
        final userName = (row['userName'] ?? '').toString().trim();
        final displayName =
            userName.isNotEmpty
                ? userName
                : '$firstName $lastName'.trim();
        return <String, String>{
          'id': (row['userId'] ?? '').toString(),
          'username': displayName,
          'profilePic': (row['profilePic'] ?? '').toString(),
        };
      }).where((row) => row['id']!.isNotEmpty).toList();
    } catch (error) {
      throw Exception(error);
    }
  }

  Future<Map<String, dynamic>?> createUser({
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
        mutation CreateUser(\$input: CreateUserInput!) {
          createUser(input: \$input) {
            userId
            firstName
            lastName
            countryCode
            phoneNumber
            onboardingStatus
          }
        }
      """),
          variables: {
            "input": {
              "firstName": firstName,
              "lastName": lastName,
              "countryCode": countryCode,
              "phoneNumber": phoneNumber,
            },
          },
        ),
      );

      if (result.hasException) {
        // Extract error message from GraphQL exception
        String errorMessage = 'Failed to create user';
        if (result.exception?.graphqlErrors != null &&
            result.exception!.graphqlErrors.isNotEmpty) {
          errorMessage = result.exception!.graphqlErrors.first.message;
        } else if (result.exception?.linkException != null) {
          errorMessage = result.exception!.linkException.toString();
        }
        print('GraphQL Error in createUser: $errorMessage');
        throw Exception(errorMessage);
      }

      var res = result.data?['createUser'];
      print('in service createUser: $res');
      if (res == null || res.isEmpty) {
        return null;
      }

      return Map<String, dynamic>.from(res);
    } catch (error) {
      print('Exception in createUser service: $error');
      rethrow;
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

  Future<bool> checkUsername({required userName, String? userId}) async {
    print('=== UserService.checkUsername ===');
    print('Input userName: "$userName"');
    print('Input userId (optional): "$userId"');

    // Normalize username to lowercase for consistent checking
    final normalizedUserName = userName.toLowerCase().trim();
    print('Normalized userName: "$normalizedUserName"');

    try {
      // Build variables - include userId if provided
      final variables = <String, dynamic>{"userName": normalizedUserName};
      if (userId != null && userId.isNotEmpty) {
        variables["userId"] = userId;
      }

      QueryResult result = await client.query(
        QueryOptions(
          fetchPolicy: FetchPolicy.noCache,
          document: gql("""
        query Query(\$userName: String!, \$userId: ID) {
          checkUserName(userName: \$userName, userId: \$userId) {
            available
            reservedByCurrentUser
            reservedUntil
          }
        }
      """),
          variables: variables,
        ),
      );

      print('GraphQL query executed');
      print('Has exception: ${result.hasException}');

      if (result.hasException) {
        print('Exception: ${result.exception}');
        print('Exception details: ${result.exception?.graphqlErrors}');
        throw Exception(result.exception);
      }

      var res = result.data?['checkUserName'];
      print('GraphQL response data: ${result.data}');
      print('checkUserName result: $res');

      // Handle both old format (boolean) and new format (object)
      if (res is bool) {
        // Legacy format - return as is
        print('Legacy boolean format: $res');
        return res;
      } else if (res is Map) {
        // New format - extract available field
        final available = res['available'] as bool? ?? false;
        print('New format - available: $available');
        print('reservedByCurrentUser: ${res['reservedByCurrentUser']}');
        print('reservedUntil: ${res['reservedUntil']}');
        return available;
      } else {
        // Fallback
        final boolResult = res == true || res == 'true';
        print('Fallback interpretation: $boolResult');
        return boolResult;
      }
    } catch (error) {
      print('ERROR in checkUsername: $error');
      print('Error details: $error');
      print('==============================');
      throw Exception(error);
    }
  }

  Future<List> generateUsernameOptions({
    required userName,
    required userId,
    bool skipPriority1 = false,
  }) async {
    print('=== UserService.generateUsernameOptions ===');
    print('Input userName: "$userName"');
    print('Input userId: "$userId"');
    print('Skip Priority 1: $skipPriority1');
    try {
      QueryResult result = await client.query(
        QueryOptions(
          fetchPolicy: FetchPolicy.noCache,
          document: gql("""
        query Query(\$userName: String!, \$userId: ID!, \$skipPriority1: Boolean) {
          generateUsernameOptions(userName: \$userName, userId: \$userId, skipPriority1: \$skipPriority1)
        }
      """),
          variables: {
            "userName": userName,
            "userId": userId,
            "skipPriority1": skipPriority1,
          },
        ),
      );

      print('GraphQL query executed');
      print('Has exception: ${result.hasException}');

      if (result.hasException) {
        print('Exception in generateUsernameOptions: ${result.exception}');
        print('GraphQL errors: ${result.exception?.graphqlErrors}');
        // Even on error, return some fallback suggestions
        final fallbackUserName = userName.toString().toLowerCase().trim();
        return [
          '${fallbackUserName}${DateTime.now().millisecondsSinceEpoch % 10000}',
          '${fallbackUserName}_${DateTime.now().millisecondsSinceEpoch % 1000}',
          '${fallbackUserName}${DateTime.now().millisecondsSinceEpoch % 100000}',
        ];
      }

      var res = result.data?['generateUsernameOptions'];
      print('GraphQL response data: ${result.data}');
      print('generateUsernameOptions result: $res (type: ${res.runtimeType})');

      if (res == null || res.isEmpty) {
        print('No suggestions returned, generating fallback suggestions');
        print('===========================================');
        // Generate fallback suggestions instead of returning empty
        final fallbackUserName = userName.toString().toLowerCase().trim();
        return [
          '${fallbackUserName}${DateTime.now().millisecondsSinceEpoch % 10000}',
          '${fallbackUserName}_${DateTime.now().millisecondsSinceEpoch % 1000}',
          '${fallbackUserName}${DateTime.now().millisecondsSinceEpoch % 100000}',
        ];
      }

      print('Returning ${res.length} suggestions');
      print('===========================================');
      return res;
    } catch (error) {
      print('ERROR in generateUsernameOptions: $error');
      print('===========================================');
      // Return fallback suggestions instead of throwing
      final fallbackUserName = userName.toString().toLowerCase().trim();
      return [
        '${fallbackUserName}${DateTime.now().millisecondsSinceEpoch % 10000}',
        '${fallbackUserName}_${DateTime.now().millisecondsSinceEpoch % 1000}',
        '${fallbackUserName}${DateTime.now().millisecondsSinceEpoch % 100000}',
      ];
    }
  }

  // Reserve username temporarily during onboarding (15 min TTL)
  Future<bool> reserveUsername({required userId, required userName}) async {
    print('=== UserService.reserveUsername ===');
    print('userId: "$userId"');
    print('userName: "$userName"');

    try {
      QueryResult result = await client.mutate(
        MutationOptions(
          fetchPolicy: FetchPolicy.noCache,
          document: gql("""
        mutation ReserveUsername(\$input: ReserveUsernameInput!) {
          reserveUsername(input: \$input) {
            success
            reservedUntil
            message
          }
        }
      """),
          variables: {
            "input": {"userId": userId, "userName": userName},
          },
        ),
      );

      print('GraphQL mutation executed');
      print('Has exception: ${result.hasException}');

      if (result.hasException) {
        print('Exception: ${result.exception}');
        print('Exception details: ${result.exception?.graphqlErrors}');
        throw Exception(result.exception);
      }

      var res = result.data?['reserveUsername'];
      print('Mutation response: $res');
      final success = res?['success'] ?? false;
      print('Reservation success: $success');
      print('Reserved until: ${res?['reservedUntil']}');
      print('==============================');
      return success;
    } catch (error) {
      print('ERROR in reserveUsername: $error');
      print('==============================');
      // Re-throw the error as-is if it's already an Exception, otherwise wrap it
      if (error is Exception) {
        rethrow;
      }
      throw Exception(error);
    }
  }

  // Extend username reservation (heartbeat - call every 5 minutes)
  Future<bool> extendUsernameReservation({
    required userId,
    required userName,
  }) async {
    print('=== UserService.extendUsernameReservation ===');
    print('userId: "$userId"');
    print('userName: "$userName"');

    try {
      QueryResult result = await client.mutate(
        MutationOptions(
          fetchPolicy: FetchPolicy.noCache,
          document: gql("""
        mutation ExtendUsernameReservation(\$input: ExtendReservationInput!) {
          extendUsernameReservation(input: \$input) {
            success
            reservedUntil
            message
          }
        }
      """),
          variables: {
            "input": {"userId": userId, "userName": userName},
          },
        ),
      );

      print('GraphQL mutation executed');
      print('Has exception: ${result.hasException}');

      if (result.hasException) {
        print('Exception: ${result.exception}');
        // Don't throw on heartbeat failures - just log
        print('Heartbeat failed but continuing');
        return false;
      }

      var res = result.data?['extendUsernameReservation'];
      print('Extension response: $res');
      final success = res?['success'] ?? false;
      print('Extension success: $success');
      print('New reserved until: ${res?['reservedUntil']}');
      print('===========================================');
      return success;
    } catch (error) {
      print('ERROR in extendUsernameReservation: $error');
      print('Heartbeat failed but continuing');
      print('===========================================');
      // Don't throw - heartbeat failures shouldn't break the flow
      return false;
    }
  }

  // Release username reservation (on username change or app close)
  Future<bool> releaseUsernameReservation({
    required userId,
    required userName,
  }) async {
    print('=== UserService.releaseUsernameReservation ===');
    print('userId: "$userId"');
    print('userName: "$userName"');

    try {
      QueryResult result = await client.mutate(
        MutationOptions(
          fetchPolicy: FetchPolicy.noCache,
          document: gql("""
        mutation ReleaseUsernameReservation(\$input: ReleaseReservationInput!) {
          releaseUsernameReservation(input: \$input) {
            success
            message
          }
        }
      """),
          variables: {
            "input": {"userId": userId, "userName": userName},
          },
        ),
      );

      print('GraphQL mutation executed');
      print('Has exception: ${result.hasException}');

      if (result.hasException) {
        print('Exception: ${result.exception}');
        // Don't throw - release failures are not critical
        return false;
      }

      var res = result.data?['releaseUsernameReservation'];
      print('Release response: $res');
      final success = res?['success'] ?? false;
      print('Release success: $success');
      print('==============================');
      return success;
    } catch (error) {
      print('ERROR in releaseUsernameReservation: $error');
      print('Release failed but continuing');
      print('==============================');
      // Don't throw - release failures are not critical
      return false;
    }
  }

  // Get onboarding status for a user
  Future<Map<String, dynamic>?> getOnboardingStatus({required userId}) async {
    try {
      QueryResult result = await client.query(
        QueryOptions(
          fetchPolicy: FetchPolicy.noCache,
          document: gql("""
        query GetOnboardingStatus(\$userId: ID!) {
          getOnboardingStatus(userId: \$userId) {
            userId
            onboardingStatus
            userName
          }
        }
      """),
          variables: {"userId": userId},
        ),
      );

      if (result.hasException) {
        throw Exception(result.exception);
      }

      var res = result.data?['getOnboardingStatus'];
      if (res == null || res.isEmpty) {
        return null;
      }

      return Map<String, dynamic>.from(res);
    } catch (error) {
      throw Exception(error);
    }
  }

  // Update profile basics (gender, pronouns, birthdate, ageCohort) - moves status to 'profile_basic'
  // Backend should compute and store ageCohort from birthDate (Boomer/Gen X/Millennial/Gen Z/Alpha).
  Future<Map<String, dynamic>?> updateProfileBasics({
    required userId,
    String? gender,
    String? otherIdentity,
    String? pronouns,
    String? birthDate,
    String? ageCohort,
  }) async {
    try {
      QueryResult result = await client.mutate(
        MutationOptions(
          fetchPolicy: FetchPolicy.noCache,
          document: gql("""
        mutation UpdateProfileBasics(\$input: UpdateProfileBasicsInput!) {
          updateProfileBasics(input: \$input) {
            userId
            onboardingStatus
            gender
            otherIdentity
            pronouns
            birthDate
            ageCohort
          }
        }
      """),
          variables: {
            "input": {
              "userId": userId,
              if (gender != null) "gender": gender,
              if (otherIdentity != null) "otherIdentity": otherIdentity,
              if (pronouns != null && pronouns.isNotEmpty) "pronouns": pronouns,
              if (birthDate != null) "birthDate": birthDate,
              if (ageCohort != null && ageCohort.isNotEmpty) "ageCohort": ageCohort,
            },
          },
        ),
      );

      if (result.hasException) {
        throw Exception(result.exception);
      }

      var res = result.data?['updateProfileBasics'];
      if (res == null || res.isEmpty) {
        return null;
      }

      return Map<String, dynamic>.from(res);
    } catch (error) {
      throw Exception(error);
    }
  }

  // Update profile type (creator/consumer) - moves status to 'profile_type_selected'
  Future<Map<String, dynamic>?> updateProfileType({
    required userId,
    required creatorIntention, // 'creator' or 'consumer'
  }) async {
    try {
      QueryResult result = await client.mutate(
        MutationOptions(
          fetchPolicy: FetchPolicy.noCache,
          document: gql("""
        mutation UpdateProfileType(\$input: UpdateProfileTypeInput!) {
          updateProfileType(input: \$input) {
            userId
            onboardingStatus
            creatorIntention
            isCreator
          }
        }
      """),
          variables: {
            "input": {"userId": userId, "creatorIntention": creatorIntention},
          },
        ),
      );

      if (result.hasException) {
        throw Exception(result.exception);
      }

      var res = result.data?['updateProfileType'];
      if (res == null || res.isEmpty) {
        return null;
      }

      return Map<String, dynamic>.from(res);
    } catch (error) {
      throw Exception(error);
    }
  }

  // Set username permanently (called when user confirms username selection)
  Future<Map<String, dynamic>?> setUsername({
    required userId,
    required userName,
  }) async {
    try {
      QueryResult result = await client.mutate(
        MutationOptions(
          fetchPolicy: FetchPolicy.noCache,
          document: gql("""
        mutation SetUsername(\$input: SetUsernameInput!) {
          setUsername(input: \$input) {
            userId
            userName
          }
        }
      """),
          variables: {
            "input": {"userId": userId, "userName": userName},
          },
        ),
      );

      if (result.hasException) {
        throw Exception(result.exception);
      }

      var res = result.data?['setUsername'];
      if (res == null || res.isEmpty) {
        return null;
      }

      return Map<String, dynamic>.from(res);
    } catch (error) {
      throw Exception(error);
    }
  }

  // Complete onboarding - sets status to 'completed' (username must be set separately)
  Future<Map<String, dynamic>?> completeOnboarding({required userId}) async {
    try {
      QueryResult result = await client.mutate(
        MutationOptions(
          fetchPolicy: FetchPolicy.noCache,
          document: gql("""
        mutation CompleteOnboarding(\$input: CompleteOnboardingInput!) {
          completeOnboarding(input: \$input) {
            userId
            onboardingStatus
          }
        }
      """),
          variables: {
            "input": {"userId": userId},
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

      return Map<String, dynamic>.from(res);
    } catch (error) {
      throw Exception(error);
    }
  }

  Future<String?> addProfilePic({required userId, required image}) async {
    try {
      print('=== addProfilePic Service ===');
      print('User ID: $userId');
      print(
        'Image: ${image.substring(0, image.length > 100 ? 100 : image.length)}...',
      );

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
        print('=== GraphQL Exception Details ===');
        print('Full exception: ${result.exception}');
        print('Exception type: ${result.exception.runtimeType}');

        if (result.exception?.graphqlErrors != null) {
          print(
            'Number of GraphQL errors: ${result.exception!.graphqlErrors.length}',
          );
          for (int i = 0; i < result.exception!.graphqlErrors.length; i++) {
            final error = result.exception!.graphqlErrors[i];
            print('Error $i:');
            print('  Message: ${error.message}');
            print('  Locations: ${error.locations}');
            print('  Path: ${error.path}');
            print('  Extensions: ${error.extensions}');
          }

          // Get the first error message for user display
          final errorMessage = result.exception!.graphqlErrors.first.message;
          print('Primary error message: $errorMessage');
          print('================================');
          throw Exception('GraphQL Error: $errorMessage');
        }

        // Handle link exceptions (network errors)
        if (result.exception?.linkException != null) {
          print('Link Exception: ${result.exception!.linkException}');
          print('================================');
          throw Exception('Network Error: ${result.exception!.linkException}');
        }

        print('================================');
        throw Exception(result.exception);
      }
      print('Mutation result: $result');
      var res = result.data?['addProfilePic'];
      print('addProfilePic response: $res');
      if (res == null || res.isEmpty) {
        return null;
      }

      return res;
    } catch (error) {
      print('Error in addProfilePic service: $error');
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
        query UserLogin(\$phoneNumber: String!, \$countryCode: String!) {
          userLogin(phoneNumber: \$phoneNumber, countryCode: \$countryCode) {
            userId
            onboardingStatus
            userName
          }
        }
      """),
          variables: {"phoneNumber": phoneNumber, "countryCode": countryCode},
        ),
      );
      print('servicee $result');
      if (result.hasException) {
        throw Exception(result.exception);
      }
      final res = result.data?['userLogin'];
      print("service $res");
      if (res == null) {
        return null;
      }
      final userId = res['userId'] as String?;
      return userId;
    } catch (error) {
      throw Exception(error);
    }
  }
}
