import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:mood_manager/features/common/domain/entities/media.dart';
import 'package:mood_manager/features/common/domain/entities/media_collection.dart';
import 'package:mood_manager/features/common/presentation/widgets/empty_widget.dart';

class ImageSlider extends StatefulWidget {
  final Map<dynamic, dynamic> arguments;
  ImageSlider({this.arguments}) {
    this.fetchPhotoListCallback = arguments['callback'];
    this.initialPhoto = arguments['initial'];
  }
  Function fetchPhotoListCallback;
  MediaCollection initialPhoto;
  @override
  ImageSliderWidgetState createState() {
    return new ImageSliderWidgetState();
  }
}

class ImageSliderWidgetState extends State<ImageSlider> {
  Future<List<MediaCollection>> mediaCollectionList;
  PageController _controller;
  bool init = true;
  @override
  void initState() {
    super.initState();
    mediaCollectionList = widget.fetchPhotoListCallback();
  }

  @override
  Widget build(BuildContext context) {
    return _buildingImageSlider();
  }

  Widget _buildingImageSlider() {
    return Scaffold(
      backgroundColor: Colors.black,
      body: _buildPagerViewSlider(),
    );
  }

  Widget _buildPagerViewSlider() {
    return StreamBuilder<List<MediaCollection>>(
        stream: mediaCollectionList.asStream(),
        initialData: [if (widget.initialPhoto != null) widget.initialPhoto],
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final List<Media> photoList =
                snapshot.data.map((e) => e.media).toList();
            _controller = PageController(
                initialPage: photoList
                    .indexWhere((e) => widget.initialPhoto.media.id == e.id));
            return PageView.builder(
                physics: AlwaysScrollableScrollPhysics(),
                controller: _controller,
                itemCount: photoList.length,
                itemBuilder: (BuildContext context, int index) {
                  return Hero(
                    tag: photoList[index].id,
                    child: ClipRRect(
                        child: CachedNetworkImage(
                      imageUrl: photoList[index].file.url,
                      placeholder: (context, url) =>
                          new Center(child: CircularProgressIndicator()),
                      errorWidget: (context, url, error) =>
                          new Icon(Icons.error),
                    )),
                  );
                });
          } else {
            return EmptyWidget();
          }
        });
  }
}
