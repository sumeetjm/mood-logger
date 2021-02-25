import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_wall_layout/flutter_wall_layout.dart';
import 'package:mood_manager/core/constants/app_constants.dart';
import 'package:mood_manager/features/common/domain/entities/media_collection_mapping.dart';

// ignore: must_be_immutable
class MediaWallLayout extends StatefulWidget {
  MediaWallLayout({
    Key key,
    this.title = 'Wall Layout Demo',
    this.mediaCollectionMappingList,
    this.onItemTapCallback,
  }) : super(key: key);
  List<MediaCollectionMapping> mediaCollectionMappingList;
  Function onItemTapCallback;

  final String title;

  @override
  _MediaWallLayoutState createState() => _MediaWallLayoutState();
}

class _MediaWallLayoutState extends State<MediaWallLayout>
    with TickerProviderStateMixin {
  AnimationController _controller;
  Axis _direction;
  final random = Random();
  bool isPhotoOnly = false;
  bool isVideoOnly = false;
  String mediaType;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(duration: Duration(milliseconds: 500), vsync: this);
    _direction = Axis.vertical;
    _controller.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(this.widget.title),
        actions: [
          PopupMenuButton(
            onSelected: (value) {
              setState(() {
                mediaType = mediaType == value ? null : value;
              });
            },
            itemBuilder: (context) {
              return [
                if (widget.mediaCollectionMappingList
                        .where((element) => element.media.mediaType == 'PHOTO')
                        .length >
                    0)
                  CheckedPopupMenuItem(
                    checked: mediaType == 'PHOTO',
                    child: Text('Photos only'),
                    enabled: true,
                    value: 'PHOTO',
                  ),
                if (widget.mediaCollectionMappingList
                        .where((element) => element.media.mediaType == 'VIDEO')
                        .length >
                    0)
                  CheckedPopupMenuItem(
                    checked: mediaType == 'VIDEO',
                    child: Text('Videos only'),
                    enabled: true,
                    value: 'VIDEO',
                  ),
                /*PopupMenuItem(
                      child: CheckboxListTile(
                          contentPadding: EdgeInsets.all(0),
                          secondary: const Icon(Icons.photo),
                          selected: isPhotoOnly,
                          value: isPhotoOnly,
                          controlAffinity: ListTileControlAffinity.leading,
                          onChanged: (value) {
                            setState(() {
                              isPhotoOnly = value;
                              if (isPhotoOnly) {
                                isVideoOnly = false;
                              }
                            });
                          },
                          title: Text('Photos only'))),
                  PopupMenuItem(
                      child: CheckboxListTile(
                          contentPadding: EdgeInsets.all(0),
                          secondary: const Icon(Icons.video_label),
                          selected: isVideoOnly,
                          value: isVideoOnly,
                          controlAffinity: ListTileControlAffinity.leading,
                          onChanged: (value) {
                            setState(() {
                              isVideoOnly = value;
                              if (isVideoOnly) {
                                isPhotoOnly = false;
                              }
                            });
                          },
                          title: Text('Videos only')))*/
              ];
            },
          ),
        ],
      ),
      body: buildWallLayout(),
    );
  }

  Widget buildWallLayout() {
    return WallLayout(
      stonePadding: 8,
      scrollDirection: _direction,
      stones: _buildStonesList(),
      layersCount: 3,
    );
  }

  List<Stone> _buildStonesList() {
    List<MediaCollectionMapping> mediaCollectionMappingList =
        widget.mediaCollectionMappingList.where((e) {
      if (mediaType != null) {
        return e.media.mediaType == mediaType;
      } else {
        return true;
      }
    }).toList();
    return List.generate(mediaCollectionMappingList.length, (index) {
      final map = AppConstants.wallLayoutStoneMap[index];

      return Stone(
          id: index,
          height: map['height'],
          width: map['width'],
          child: ScaleTransition(
            scale: CurveTween(
                    curve: Interval(
                        0.0,
                        min(
                            1.0,
                            0.25 +
                                (map['width'] * map['height']).toDouble() /
                                    6.0)))
                .animate(_controller),
            child: GestureDetector(
              onTap: () {
                widget.onItemTapCallback
                    ?.call(mediaCollectionMappingList, index);
              },
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    fit: BoxFit.cover,
                    image: CachedNetworkImageProvider(
                        mediaCollectionMappingList[index].media.thumbnail.url,
                        imageRenderMethodForWeb:
                            ImageRenderMethodForWeb.HtmlImage),
                  ),
                  border: Border.all(),
                  //borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ));
    });
  }
}
