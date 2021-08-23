import 'package:equatable/equatable.dart';

// ignore: must_be_immutable
class User extends Equatable {
  String id;
  String userId;
  String email;
  String password;
  User({this.id, this.userId, this.email, this.password});

  @override
  List<Object> get props => [id, userId, email, password];
}
