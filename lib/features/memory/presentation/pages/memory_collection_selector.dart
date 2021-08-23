import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mood_manager/features/common/data/datasources/common_remote_data_source.dart';
import 'package:mood_manager/features/common/presentation/widgets/empty_widget.dart';
import 'package:mood_manager/features/memory/data/datasources/memory_remote_data_source.dart';
import 'package:mood_manager/features/memory/domain/entities/memory_collection.dart';
import 'package:mood_manager/injection_container.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:mood_manager/home.dart';

class MemoryCollectionSelector extends StatefulWidget {
  @override
  _MemoryCollectionSelectorState createState() =>
      _MemoryCollectionSelectorState();
}

class _MemoryCollectionSelectorState extends State<MemoryCollectionSelector> {
  double _panelHeightOpen;
  double _panelHeightClosed = 195.0;
  final memoryRemoteDataSource = sl<MemoryRemoteDataSource>();
  final commonRemoteDataSource = sl<CommonRemoteDataSource>();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _panelHeightOpen = MediaQuery.of(context).size.height * .80;

    return Material(
      color: Colors.black.withOpacity(0.5),
      child: Stack(
        alignment: Alignment.topCenter,
        children: <Widget>[
          SlidingUpPanel(
            maxHeight: _panelHeightOpen,
            minHeight: _panelHeightClosed,
            parallaxEnabled: true,
            parallaxOffset: .5,
            body: _body(),
            panelBuilder: (sc) => _panel(sc),
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(18.0),
                topRight: Radius.circular(18.0)),
          ),
          Positioned(
              top: 0,
              child: ClipRRect(
                  child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).padding.top,
                        color: Colors.transparent,
                      )))),
        ],
      ),
    );
  }

  Widget _panel(ScrollController sc) {
    final memoryCollectionList =
        memoryRemoteDataSource.getMemoryCollectionList();
    final isConnected = commonRemoteDataSource.isConnected();
    return MediaQuery.removePadding(
        context: context,
        removeTop: true,
        child: AnimationLimiter(
          child: ListView(
          controller: sc,
          children: AnimationConfiguration.toStaggeredList(
              duration: const Duration(milliseconds: 375),
              childAnimationBuilder: (widget) => SlideAnimation(
                horizontalOffset: 50.0,
                child: FadeInAnimation(
                  child: widget,
                ),
              ),
              children: <Widget>[
            SizedBox(
              height: 18.0,
            ),
            ListTile(
              title: Text('Add to collection'),
              trailing: IconButton(
                  icon: Icon(Icons.close),
                  onPressed: () {
                    Navigator.of(appNavigatorContext(context)).pop();
                  }),
            ),
            SizedBox(
              height: 36.0,
            ),
            FutureBuilder<bool>(
                future: isConnected,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    if (snapshot.data) {
                      return FutureBuilder<List<MemoryCollection>>(
                        future: memoryCollectionList,
                        initialData: [],
                        builder: (context, snapshot1) {
                          if (snapshot1.hasData) {
                            return ListView.builder(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              itemCount: snapshot1.data.length,
                              itemBuilder: (context, index) {
                                return ListTile(
                                  leading: CircleAvatar(
                                    child: Icon(Icons.book_online_rounded),
                                  ),
                                );
                              },
                            );
                          } else {
                            return EmptyWidget();
                          }
                        },
                      );
                    } else {
                      Fluttertoast.showToast(
                          gravity: ToastGravity.TOP,
                          msg: 'Unable to connect',
                          backgroundColor: Colors.red);
                      return EmptyWidget();
                    }
                  } else {
                    return EmptyWidget();
                  }
                })
          ])),
        ));
  }

  Widget _body() {
    return EmptyWidget();
  }
}
