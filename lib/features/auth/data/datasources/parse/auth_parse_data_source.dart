import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:mood_manager/core/error/exceptions.dart';
import 'package:mood_manager/features/auth/data/datasources/auth_data_source.dart';
import 'package:mood_manager/features/common/data/models/media_collection_parse.dart';
import 'package:mood_manager/features/memory/data/models/memory_collection_parse.dart';
import 'package:mood_manager/features/profile/data/datasources/user_profile_remote_data_source.dart';
import 'package:mood_manager/features/auth/data/model/parse/user_parse.dart';
import 'package:mood_manager/features/profile/data/models/user_profile_parse.dart';
import 'package:mood_manager/features/auth/domain/entitles/user.dart';
import 'package:parse_server_sdk/parse_server_sdk.dart';
import 'package:uuid/uuid.dart';

class AuthParseDataSource extends AuthDataSource {
  final FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;
  final FacebookLogin facebookLogin;
  final http.Client httpClient;
  final UserProfileRemoteDataSource userProfileRemoteDataSource;
  final Uuid uuid;

  AuthParseDataSource(
      {FirebaseAuth firebaseAuth,
      GoogleSignIn googleSignin,
      FacebookLogin facebookLogin,
      http.Client httpClient,
      UserProfileRemoteDataSource userProfileRemoteDataSource,
      Uuid uuid})
      : assert(firebaseAuth != null),
        assert(googleSignin != null),
        assert(facebookLogin != null),
        this._firebaseAuth = firebaseAuth,
        this._googleSignIn = googleSignin,
        this.httpClient = httpClient,
        this.facebookLogin = facebookLogin,
        this.userProfileRemoteDataSource = userProfileRemoteDataSource,
        this.uuid = uuid;

  @override
  Future<User> getUser() async {
    try {
      final ParseUser parseUser = await ParseUser.currentUser();
      if (parseUser != null) {
        return UserParse.fromParseUser(parseUser);
      } else {
        return throw ServerException();
      }
    } catch (_) {
      throw ServerException();
    }
  }

  @override
  Future<bool> isSignedIn() async {
    try {
      final ParseUser parseUser = await ParseUser.currentUser();
      return parseUser != null;
    } catch (_) {
      throw ServerException();
    }
  }

  @override
  Future<User> signInWithCredentials(
      {String email, String password, String username}) async {
    try {
      final user = ParseUser(username, password, email);
      final response = await user.login();
      if (response.success) {
        return UserParse.fromParseUser(response.result);
      }
      throw ValidationException(response.error.message);
    } on ValidationException catch (e) {
      throw e;
    } catch (_) {
      throw ServerException();
    }
  }

  @override
  Future<User> signInWithGoogle() async {
    try {
      final GoogleSignInAccount googleUser = await _googleSignIn.signIn();
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      /*final AuthCredential credential = GoogleAuthProvider.getCredential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );*/
      final authData = {
        'access_token': googleAuth.accessToken,
        'id': googleUser.id,
        'id_token': googleAuth.idToken
      };
      final splittedName = (googleUser.displayName ?? '').split(" ");
      final firstName = splittedName.removeAt(0);
      final lastName = splittedName.join(' ');
      return await loginWithSocial(
        authData,
        "google",
        email: googleUser.email,
        firstName: firstName,
        lastName: lastName,
      );
    } catch (_) {
      throw ServerException();
    }
  }

  @override
  Future<void> signOut() async {
    try {
      ParseUser user = await ParseUser.currentUser();
      final result = await user.logout();
      if (result.success) {
        return;
      }
      throw ServerException();
    } catch (_) {
      throw ServerException();
    }
  }

  @override
  Future<bool> signUp({String email, String password, String username}) async {
    try {
      final user = ParseUser(username, password, email);
      user.set("token", base64.encode(utf8.encode(password)));
      final response = await user.signUp();
      if (response.success) {
        await userProfileRemoteDataSource.saveUserProfile(UserProfileParse(
          user: response.result,
          archiveMemoryCollection: MemoryCollectionParse(
            code: uuid.v1(),
            name: 'ARCHIVE',
            memoryCount: 0,
            user: response.result as ParseUser,
          ),
          profilePictureCollection: MediaCollectionParse(
            code: uuid.v1(),
            name: 'Profile Pictures',
            mediaType: 'PHOTO',
            module: 'PROFILE_PICTURE',
            mediaCount: 1,
            user: response.result as ParseUser,
          ),
        ));
        return true;
      }
      throw ValidationException(response.error.message);
    } on ValidationException catch (e) {
      throw e;
    } catch (_) {
      throw ServerException();
    }
  }

  Future<ParseObject> getUserFromEmail({String email}) async {
    try {
      final QueryBuilder<ParseObject> queryBuilder =
          QueryBuilder<ParseObject>(ParseObject('_User'))
            ..whereEqualTo('email', email);
      final response = await queryBuilder.query();
      if (response.success) {
        return response.results?.first;
      } else {
        return null;
      }
    } catch (_) {
      throw ServerException();
    }
  }

  Future<User> signInWithFacebook() async {
    final FacebookLoginResult result =
        await facebookLogin.logIn(['email', 'public_profile']);
    switch (result.status) {
      case FacebookLoginStatus.loggedIn:
        final profile = await getProfileInfoFromFacebookLoginResult(result);
        final authData = facebook(result.accessToken.token,
            result.accessToken.userId, result.accessToken.expires);
        return await loginWithSocial(
          authData,
          'facebook',
          email: profile['email'],
          firstName: profile['first_name'],
          lastName: profile['last_name'],
        );
        break;
      case FacebookLoginStatus.cancelledByUser:
        throw ServerException();
        break;
      case FacebookLoginStatus.error:
        throw ServerException();
        break;
      default:
        throw ServerException();
    }
  }

  Future<User> loginWithSocial(Map<String, dynamic> authData, String social,
      {String firstName,
      String lastName,
      String email,
      String photoUrl}) async {
    ParseObject existingUser = await getUserFromEmail(
      email: email,
    );
    ParseResponse response;
    if (existingUser != null) {
      final existingAuthData = existingUser.get("authData") ?? {};
      existingUser[social] = authData;
      existingUser.set("authData", existingAuthData);
      response = await existingUser.save();
      if (!response.success) {
        throw ServerException();
      }
    }
    response = await ParseUser.loginWith(social, authData);
    if (response.success) {
      existingUser = response.result;
      existingUser.set('email', email);
      await existingUser.save();
      await userProfileRemoteDataSource.saveUserProfile(UserProfileParse(
        firstName: firstName,
        lastName: lastName,
        user: existingUser,
        archiveMemoryCollection: MemoryCollectionParse(
          code: uuid.v1(),
          name: 'ARCHIVE',
          memoryCount: 0,
          user: existingUser,
        ),
        profilePictureCollection: MediaCollectionParse(
          code: uuid.v1(),
          name: 'Profile Pictures',
          mediaType: 'PHOTO',
          module: 'PROFILE_PICTURE',
          mediaCount: 0,
          user: response.result as ParseUser,
        ),
      ));
      return UserParse.fromParseUser(response.result);
    }
    throw ServerException();
  }

  Future<Map<String, dynamic>> getProfileInfoFromFacebookLoginResult(
      FacebookLoginResult result) async {
    final token = result.accessToken.token;
    final graphResponse = await httpClient.get(
        'https://graph.facebook.com/v2.12/me?fields=name,first_name,last_name,email&access_token=${token}');
    final profile = json.decode(graphResponse.body);
    return profile;
  }

  Future<bool> isUserExist({String email}) async {
    try {
      final QueryBuilder<ParseObject> queryBuilder =
          QueryBuilder<ParseObject>(ParseObject('_User'))
            ..whereEqualTo('email', email);
      final response = await queryBuilder.query();
      if (response.success) {
        return response.count > 0;
      } else {
        return false;
      }
    } catch (_) {
      throw ServerException();
    }
  }

  Future<bool> isUsernameExist({String username}) async {
    try {
      final QueryBuilder<ParseObject> queryBuilder =
          QueryBuilder<ParseObject>(ParseObject('_User'))
            ..whereEqualTo('username', username);
      final response = await queryBuilder.query();
      if (response.success) {
        return response.count > 0;
      } else {
        return false;
      }
    } catch (_) {
      throw ServerException();
    }
  }

  Future<void> linkWithGoogle() async {
    try {
      final GoogleSignInAccount googleUser = await _googleSignIn.signIn();
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final authData = {
        'access_token': googleAuth.accessToken,
        'id': googleUser.id,
        'id_token': googleAuth.idToken
      };
      await linkWithSocial(authData, "google");
      return;
    } catch (_) {
      throw ServerException();
    }
  }

  Future<void> linkWithSocial(
      Map<String, dynamic> authData, String social) async {
    dynamic user = await ParseUser.currentUser();
    user = await getUserFromEmail(email: user.emailAddress);
    final existingAuthData = user.get("authData") ?? {};
    existingAuthData[social] = authData;
    user.set("authData", existingAuthData);
    final ParseResponse response = await user.save();
    if (response.success) {
      return;
    } else {
      throw ServerException();
    }
  }

  @override
  Future<void> linkWithFacebook() async {
    try {
      final FacebookLoginResult result =
          await facebookLogin.logIn(['email', 'public_profile']);
      switch (result.status) {
        case FacebookLoginStatus.loggedIn:
          final authData = facebook(result.accessToken.token,
              result.accessToken.userId, result.accessToken.expires);
          await linkWithSocial(
            authData,
            'facebook',
          );
          return;
          break;
        case FacebookLoginStatus.cancelledByUser:
          throw ServerException();
          break;
        case FacebookLoginStatus.error:
          throw ServerException();
          break;
        default:
          throw ServerException();
      }
    } catch (_) {
      throw ServerException();
    }
  }
}
