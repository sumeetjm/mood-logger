import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../error/failures.dart';

abstract class UseCase<Type, Params> {
  Future<Either<Failure, Type>> call(Params params);
}

class NoParams extends Equatable {
  @override
  List<Object> get props => [];
}

class Params<T> extends Equatable {
  final T param;

  Params(this.param);
  @override
  List<Object> get props => [param];
}

class MultiParams extends Equatable {
  final List param;

  MultiParams(this.param);
  @override
  List<Object> get props => [...param];
}
