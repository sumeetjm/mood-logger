import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';

class UserCredential extends Equatable {
  final String email;
  final String password;

  UserCredential({@required this.email, @required this.password});
  @override
  List<Object> get props => [email, password];
}
