import 'package:flutter/material.dart';
import 'package:parse_server_sdk/parse_server_sdk.dart';

class MemoryImageSlider extends StatefulWidget {
  final Map<String, ParseFile> imagesMap;
  final int initialIndex;
  List<String> thumbnailPathList;
  MemoryImageSlider({this.imagesMap, this.initialIndex}) {
    thumbnailPathList = this.imagesMap.keys.toList();
  }
  @override
  _MemoryImageSliderState createState() {
    return new _MemoryImageSliderState();
  }
}

class _MemoryImageSliderState extends State<MemoryImageSlider> {
  PageController _controller;
  bool init = true;
  @override
  void initState() {
    super.initState();
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
    _controller = PageController(initialPage: widget.initialIndex);
    return PageView.builder(
        physics: AlwaysScrollableScrollPhysics(),
        controller: _controller,
        itemCount: widget.imagesMap.length,
        itemBuilder: (BuildContext context, int index) {
          return Hero(
            tag: index,
            child: ClipRRect(
                child: Image.file(
                    widget.imagesMap[widget.thumbnailPathList[index]].file)),
          );
        });
  }
}
