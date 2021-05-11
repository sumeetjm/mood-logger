import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mood_manager/features/common/domain/entities/base_states.dart';
import 'package:mood_manager/features/common/presentation/widgets/empty_widget.dart';
import 'package:mood_manager/features/memory/domain/entities/memory_collection.dart';
import 'package:mood_manager/features/memory/presentation/bloc/memory_bloc.dart';
import 'package:mood_manager/injection_container.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:uuid/uuid.dart';

// ignore: must_be_immutable
class MemoryCollectionListPage extends StatefulWidget {
  String title;
  Map<String, dynamic> arguments;

  MemoryCollectionListPage({
    Key key,
    this.arguments = const {},
  }) : super(key: key);
  @override
  _MemoryCollectionListPageState createState() =>
      _MemoryCollectionListPageState();
}

class _MemoryCollectionListPageState extends State<MemoryCollectionListPage> {
  final Uuid uuid = sl<Uuid>();
  String uniqueKey;
  List<MemoryCollection> memoryCollectionList = [];
  MemoryBloc _memoryBloc;
  AutoScrollController scrollController;

  @override
  void initState() {
    _memoryBloc = BlocProvider.of<MemoryBloc>(context);
    _memoryBloc.add(GetMemoryCollectionListEvent());
    scrollController = AutoScrollController(
        viewportBoundaryGetter: () =>
            Rect.fromLTRB(0, 0, 0, MediaQuery.of(context).padding.bottom),
        axis: Axis.vertical);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title ?? 'Your collection'),
      ),
      body: BlocConsumer<MemoryBloc, MemoryState>(
          listener: (context, state) {
            if (state is MemoryCollectionListLoaded) {
              memoryCollectionList = state.memoryCollectionList;
            }
            handleLoader(state, context);
          },
          cubit: _memoryBloc,
          builder: (context, state) {
            if (memoryCollectionList.isNotEmpty) {
              return ListView.separated(
                itemCount: memoryCollectionList.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor:
                          memoryCollectionList[index].averageMemoryMoodColor,
                      child: Icon(
                        Icons.book,
                        color: Colors.white,
                      ),
                    ),
                    title: Text(memoryCollectionList[index].name),
                    onTap: () {
                      Navigator.of(context)
                          .pushNamed('/memory/list/collection', arguments: {
                        'listType': 'COLLECTION',
                        'title':
                            'Collection > ${memoryCollectionList[index].name}',
                        'collection': memoryCollectionList[index],
                      });
                    },
                  );
                },
                separatorBuilder: (context, index) {
                  return Divider(
                    thickness: 1,
                    height: 5,
                  );
                },
              );
            }
            return EmptyWidget();
          }),
    );
  }
}
