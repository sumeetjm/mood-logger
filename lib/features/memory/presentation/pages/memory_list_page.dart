import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mood_manager/core/constants/app_constants.dart';
import 'package:mood_manager/features/memory/domain/entities/memory.dart';
import 'package:mood_manager/features/memory/presentation/bloc/memory_bloc.dart';
import 'package:mood_manager/features/mood_manager/presentation/widgets/widgets.dart';
import 'package:mood_manager/injection_container.dart';
import 'package:sticky_headers/sticky_headers.dart';
import 'package:intl/intl.dart';

class MemoryListPage extends StatefulWidget {
  MemoryListPage({Key key}) : super(key: key);

  @override
  _MemoryListPageState createState() => _MemoryListPageState();
}

class _MemoryListPageState extends State<MemoryListPage> {
  List<Memory> memoryList = [];
  final MemoryBloc _memoryBloc = sl<MemoryBloc>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Your memories"),
      ),
      body: BlocConsumer<MemoryBloc, MemoryState>(
        cubit: _memoryBloc,
        listener: (context, state) {
          if (state is MemoryListLoaded) {
            memoryList = state.memoryList;
          }
        },
        builder: (context, state) {
          if (state is MemoryListLoading || memoryList.isEmpty) {
            return LoadingWidget();
          }
          return ListView.builder(
              itemBuilder: (context, index) => StickyHeader(
                    header: Center(
                        child: Text(
                      DateFormat(AppConstants.HEADER_DATE_FORMAT)
                          .format(memoryList[0].logDateTime),
                    )),
                    content: Column(
                      children: [],
                    ),
                  ));
        },
      ),
    );
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _memoryBloc.close();
  }
}
