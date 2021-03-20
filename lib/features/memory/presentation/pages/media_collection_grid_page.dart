import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mood_manager/features/common/domain/entities/media_collection.dart';
import 'package:mood_manager/features/common/domain/entities/media_collection_mapping.dart';
import 'package:mood_manager/features/common/presentation/widgets/empty_widget.dart';
import 'package:mood_manager/features/common/presentation/widgets/media_page_view.dart';
import 'package:mood_manager/features/memory/presentation/bloc/memory_bloc.dart';
import 'package:mood_manager/features/memory/presentation/pages/memory_list_page.dart';
import 'package:mood_manager/features/memory/presentation/pages/media_wall_layout.dart';
import 'package:mood_manager/features/memory/presentation/widgets/shadow_text.dart';
import 'package:mood_manager/injection_container.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:uuid/uuid.dart';
import 'package:mood_manager/features/common/data/datasources/common_remote_data_source.dart';

// ignore: must_be_immutable
class MediaCollectionGridPage extends StatefulWidget {
  String title;
  Map<String, dynamic> arguments;

  MediaCollectionGridPage({
    Key key,
    this.arguments = const {},
  }) : super(key: key);
  @override
  _MediaCollectionGridPageState createState() =>
      _MediaCollectionGridPageState();
}

class _MediaCollectionGridPageState extends State<MediaCollectionGridPage> {
  final Uuid uuid = sl<Uuid>();
  String uniqueKey;
  List<MediaCollection> mediaCollectionList = [];
  Map<String, Future<List<MediaCollectionMapping>>>
      mediaCollectionListMapByCollectionId = {};
  MemoryBloc _memoryBloc;
  AutoScrollController scrollController;
  CommonRemoteDataSource commonRemoteDataSource;

  @override
  void initState() {
    _memoryBloc = sl<MemoryBloc>();
    _memoryBloc.add(GetMediaCollectionListEvent());
    scrollController = AutoScrollController(
        viewportBoundaryGetter: () =>
            Rect.fromLTRB(0, 0, 0, MediaQuery.of(context).padding.bottom),
        axis: Axis.vertical);
    commonRemoteDataSource = sl<CommonRemoteDataSource>();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title ?? 'All media'),
      ),
      body: BlocConsumer<MemoryBloc, MemoryState>(
          listener: (context, state) {
            if (state is MediaCollectionListLoaded) {
              mediaCollectionList = state.mediaCollectionList;
              final Map<String, Future<List<MediaCollectionMapping>>>
                  mediaCollectionMap = {};
              for (final mediaCollection in mediaCollectionList) {
                mediaCollectionMap[mediaCollection.id ?? mediaCollection.code] =
                    commonRemoteDataSource
                        .getMediaCollectionMappingByCollection(mediaCollection,
                            limit: 4);
              }
              mediaCollectionListMapByCollectionId = mediaCollectionMap;
            }
          },
          cubit: _memoryBloc,
          builder: (context, state) {
            if (state is MediaCollectionListLoaded) {
              return GridView.builder(
                itemCount: mediaCollectionList.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 6,
                  mainAxisSpacing: 6,
                ),
                itemBuilder: (context, index) {
                  return FutureBuilder<List<MediaCollectionMapping>>(
                      future: mediaCollectionListMapByCollectionId[
                          mediaCollectionList[index].id ??
                              mediaCollectionList[index].code],
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          final photoCollectionTitle =
                              mediaCollectionList[index].name +
                                  (mediaCollectionList[index].mediaCount == null
                                      ? ''
                                      : '(' +
                                          mediaCollectionList[index]
                                              .mediaCount
                                              .toString() +
                                          ')');
                          return ColorFiltered(
                              colorFilter: ColorFilter.mode(
                                Colors.black.withOpacity(0.1),
                                BlendMode.darken,
                              ),
                              child: Container(
                                decoration: BoxDecoration(
                                  border:
                                      Border.all(color: Colors.grey, width: 1),
                                ),
                                child: Stack(
                                  children: [
                                    MemoryMediaGrid(
                                        mediaCollectionList: snapshot.data),
                                    Center(
                                      child: ShadowText(
                                        photoCollectionTitle,
                                        style: TextStyle(
                                            fontSize: 18,
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () async {
                                        commonRemoteDataSource
                                            .getMediaCollectionMappingByCollection(
                                                mediaCollectionList[index])
                                            .then((value) async {
                                          Navigator.of(context)
                                              .push(MaterialPageRoute(
                                            builder: (context) =>
                                                MediaWallLayout(
                                              title: mediaCollectionList[index]
                                                  .name,
                                              mediaCollectionMappingList: value,
                                              onItemTapCallback:
                                                  (mediaCollectionMappingList,
                                                      index) {
                                                Navigator.of(context).push(
                                                    MaterialPageRoute(
                                                        builder: (context) {
                                                  return MediaPageView(
                                                      mediaCollectionList:
                                                          mediaCollectionMappingList,
                                                      initialIndex: index,
                                                      goToMemoryCallback:
                                                          (media) {
                                                        Navigator.of(context)
                                                            .push(
                                                                MaterialPageRoute(
                                                          builder: (context) {
                                                            return MemoryListPage(
                                                              arguments: {
                                                                'media': media
                                                              },
                                                            );
                                                          },
                                                        ));
                                                      });
                                                }));
                                              },
                                            ),
                                          ));
                                        });
                                      },
                                      child: Container(
                                        color: Colors.transparent,
                                      ),
                                    )
                                  ],
                                ),
                              ));
                        } else {
                          return GridPlaceholder(
                            mediaCount: 4,
                          );
                        }
                      });
                },
              );
            }
            return EmptyWidget();
          }),
    );
  }
}
