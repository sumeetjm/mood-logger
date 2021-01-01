import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:mood_manager/features/common/domain/entities/media_collection.dart';
import 'package:mood_manager/features/memory/domain/entities/memory.dart';
import 'package:mood_manager/features/memory/presentation/bloc/memory_bloc.dart';
import 'package:mood_manager/features/memory/presentation/widgets/memory_form_view.dart';
import 'package:mood_manager/injection_container.dart';

class MemoryFormPage extends StatefulWidget {
  final Map<dynamic, dynamic> arguments;
  DateTime selectedDate;
  final GlobalKey<NavigatorState> navigatorKey;
  MemoryFormPage({this.arguments, Key key, this.navigatorKey})
      : super(key: key) {
    if (arguments != null) {
      this.selectedDate = arguments['selectedDate'];
    }
  }
  @override
  State<StatefulWidget> createState() => _MemoryFormPageState();
}

class _MemoryFormPageState extends State<MemoryFormPage> {
  MemoryBloc _memoryBloc;
  Memory memory;
  Widget memoryFormViewWidget;

  @override
  void initState() {
    super.initState();
    this._memoryBloc = sl<MemoryBloc>();
  }

  @override
  Widget build(BuildContext context) {
    final memoryFormViewWidget = MemoryFormView(
      saveCallback: save,
      date: widget.selectedDate,
    );
    return Scaffold(
      body: BlocConsumer<MemoryBloc, MemoryState>(
        cubit: _memoryBloc,
        listener: (context, state) {
          if (state is MemorySaved) {
            memory = state.memory;
            Navigator.of(context).pop(memory);
          } else if (state is MemorySaving) {
            memory = state.memory;
          }
        },
        builder: (context, state) {
          if (state is MemorySaving) {
            return wrapWithLoader(memoryFormViewWidget);
          }
          return memoryFormViewWidget;
        },
      ),
    );
  }

  void save(Memory toBeSavedMemory, List<MediaCollection> mediaCollectionList) {
    _memoryBloc.add(SaveMemoryEvent(
        memory: toBeSavedMemory, mediaCollectionList: mediaCollectionList));
    setState(() {
      widget.selectedDate = toBeSavedMemory.logDateTime;
    });
  }

  wrapWithLoader(Widget widget) {
    return LoadingOverlay(
      color: Theme.of(context).primaryColor,
      isLoading: true,
      child: widget,
      opacity: 0.2,
      progressIndicator: CircularProgressIndicator(),
    );
  }
}
