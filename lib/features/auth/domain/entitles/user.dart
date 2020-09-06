import 'package:equatable/equatable.dart';

class User extends Equatable {
  String userId;
  String email;
  String password;
  User({this.userId, this.email, this.password});

  @override
  List<Object> get props => [];
}
