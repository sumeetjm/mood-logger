import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mood_manager/core/util/date_util.dart';
import 'package:mood_manager/features/common/domain/entities/media_collection_mapping.dart';
import 'package:mood_manager/features/memory/domain/entities/memory.dart';
import 'package:mood_manager/features/memory/presentation/bloc/memory_bloc.dart';
import 'package:mood_manager/features/memory/presentation/widgets/memory_form_view.dart';

// ignore: must_be_immutable
class MemoryFormPage extends StatefulWidget {
  final Map<dynamic, dynamic> arguments;
  DateTime selectedDate;
  final GlobalKey<NavigatorState> navigatorKey;
  Memory memory;
  MemoryFormPage({this.arguments = const {}, Key key, this.navigatorKey})
      : super(key: key) {
    if (arguments['memory'] != null) {
      memory = arguments['memory'];
      selectedDate = DateUtil.getDateOnly(memory.logDateTime);
    } else {
      this.selectedDate = arguments['selectedDate'] ?? DateTime.now();
    }
  }
  @override
  State<StatefulWidget> createState() => _MemoryFormPageState();
}

class _MemoryFormPageState extends State<MemoryFormPage> {
  MemoryBloc _memoryBloc;
  Memory memory;

  @override
  void initState() {
    super.initState();
    _memoryBloc = BlocProvider.of<MemoryBloc>(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<MemoryBloc, MemoryState>(
        cubit: _memoryBloc,
        listener: (context, state) {
          if (state is MemorySaved) {
            memory = state.memory;
            //pr.hide();
            Navigator.of(context)
                .pop(MapEntry(widget.memory != null ? 'U' : 'I', memory));
          }
        },
        builder: (context, state) {
          return MemoryFormView(
            saveCallback: save,
            date: widget.selectedDate,
            memory: widget.memory,
          );
        },
      ),
    );
  }

  void save(Memory toBeSavedMemory,
      List<MediaCollectionMapping> mediaCollectionList) {
    /*Navigator.of(context).pop(SaveMemoryEvent(
        memory: toBeSavedMemory,
        mediaCollectionMappingList: mediaCollectionList));*/
    _memoryBloc.add(SaveMemoryEvent(
        memory: toBeSavedMemory,
        mediaCollectionMappingList: mediaCollectionList));
    //pr.show();
    setState(() {
      widget.selectedDate = toBeSavedMemory.logDateTime;
    });
  }

  /*progressDialogListener(state) async {
    if (state is MemoryProcessing) {
      await pr.show();
    } else if (state is MemoryCompleted) {
      await pr.hide();
    }
  }*/
}
