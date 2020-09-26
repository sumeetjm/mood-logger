import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
part 'metadata_event.dart';
part 'metadata_state.dart';
class MetadataBloc extends Bloc<MetadataEvent, MetadataState> {
  MetadataBloc() : super(MetadataInitial());
  @override
  Stream<MetadataState> mapEventToState(
    MetadataEvent event,
  ) async* {
    // TODO: implement mapEventToState
  }
}
