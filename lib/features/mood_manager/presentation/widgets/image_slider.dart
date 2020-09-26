import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:mood_manager/features/mood_manager/domain/entities/photo.dart';
import 'package:mood_manager/features/mood_manager/presentation/widgets/empty_widget.dart';

class ImageSlider extends StatefulWidget {
  final Map<dynamic, dynamic> arguments;
  ImageSlider({this.arguments}) {
    this.fetchPhotoListCallback = arguments['callback'];
    this.initialPhoto = arguments['initial'];
  }
  Function fetchPhotoListCallback;
  Photo initialPhoto;
  @override
  ImageSliderWidgetState createState() {
    return new ImageSliderWidgetState();
  }
}

class ImageSliderWidgetState extends State<ImageSlider> {
  Future<List<Photo>> photoList;
  PageController _controller;
  bool init = true;
  @override
  void initState() {
    super.initState();
    photoList = widget.fetchPhotoListCallback();
    /*WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        init = false;
      });
    });*/
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
    /*if (init) {
      return PageView(
        children: [
          Hero(
            tag: widget.initialPhoto.id,
            child: ClipRRect(
                child: CachedNetworkImage(
              imageUrl: widget.initialPhoto.image.url,
              placeholder: (context, url) =>
                  new Center(child: CircularProgressIndicator()),
              errorWidget: (context, url, error) => new Icon(Icons.error),
            )),
          )
        ],
      );
    }*/
    return StreamBuilder<List<Photo>>(
        stream: photoList.asStream(),
        initialData: [widget.initialPhoto],
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final List<Photo> photoList = snapshot.data;
            _controller = PageController(
                initialPage: photoList
                    .indexWhere((e) => widget.initialPhoto.id == e.id));
            return PageView.builder(
                physics: AlwaysScrollableScrollPhysics(),
                controller: _controller,
                itemCount: photoList.length,
                itemBuilder: (BuildContext context, int index) {
                  return Hero(
                    tag: photoList[index].id,
                    child: ClipRRect(
                        child: CachedNetworkImage(
                      imageUrl: photoList[index].image.url,
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
