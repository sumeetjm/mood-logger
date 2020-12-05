part of 'memory_bloc.dart';

abstract class MemoryState extends Equatable {
  const MemoryState();

  @override
  List<Object> get props => [];
}

class MemoryInitial extends MemoryState {}

class MemorySaved extends MemoryState {
  final Memory memory;

  MemorySaved({this.memory});

  @override
  List<Object> get props => [memory];
}

class MemorySaving extends MemoryState {
  final Memory memory;

  MemorySaving({this.memory});

  @override
  List<Object> get props => [memory];
}

class MemorySaveError extends MemoryState {
  final String message;

  MemorySaveError({this.message});

  @override
  List<Object> get props => [message];
}

class MemoryListError extends MemoryState {
  final String message;

  MemoryListError({this.message});

  @override
  List<Object> get props => [message];
}

class MemoryListLoading extends MemoryState {}

class MemoryListLoaded extends MemoryState {
  final List<Memory> memoryList;

  MemoryListLoaded({this.memoryList});

  @override
  List<Object> get props => [memoryList];
}
