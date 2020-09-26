part of 'metadata_bloc.dart';
abstract class MetadataState extends Equatable {
  const MetadataState();
}
class MetadataInitial extends MetadataState {
  @override
  List<Object> get props => [];
}
