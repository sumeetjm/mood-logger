import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  @override
  List<Object> get props => [];
}

// General failures
class ServerFailure extends Failure {}

class NoInternetFailure extends Failure {
  @override
  String toString() {
    return "Unable to connect";
  }
}

class CacheFailure extends Failure {}

class ValidationFailure extends Failure {
  final String message;
  ValidationFailure(this.message);

  @override
  String toString() {
    return message;
  }
}
