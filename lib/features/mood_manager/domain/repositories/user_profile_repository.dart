import 'package:dartz/dartz.dart';
import 'package:mood_manager/core/error/failures.dart';
import 'package:mood_manager/features/mood_manager/domain/entities/media.dart';
import 'package:mood_manager/features/mood_manager/domain/entities/user_profile.dart';
import 'package:parse_server_sdk/parse_server_sdk.dart';

abstract class UserProfileRepository {
  Future<Either<Failure, UserProfile>> getCurrentUserProfile();
  Future<Either<Failure, UserProfile>> getUserProfile(ParseUser user);
  Future<Either<Failure, UserProfile>> saveUserProfile(UserProfile userProfile);
  Future<Either<Failure, Media>> saveProfilePicture(
      Media photo, UserProfile userProfile);
}
