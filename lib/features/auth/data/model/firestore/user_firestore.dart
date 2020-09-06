import 'package:flutter/material.dart';
import 'package:mood_manager/features/auth/domain/entitles/user.dart';

class UserFirestore extends User {
  UserFirestore({@required String uId, @required String email})
      : super(userId: uId, email: email);
}
