import 'package:dartz/dartz.dart';
import 'package:mood_manager/core/error/failures.dart';
import 'package:mood_manager/features/auth/domain/entitles/user.dart';
import 'package:mood_manager/features/mood_manager/domain/entities/album.dart';
import 'package:mood_manager/features/mood_manager/domain/entities/photo.dart';
import 'package:mood_manager/features/mood_manager/domain/entities/user_profile.dart';

abstract class UserProfileRepository {
  Future<Either<Failure, UserProfile>> getCurrentUserProfile();
  Future<Either<Failure, UserProfile>> getUserProfile(final User user);
  Future<Either<Failure, UserProfile>> saveUserProfile(UserProfile userProfile);
}
