/*
Name: Akshath Jain
Date: 3/18/2019 - 1/25/2020
Purpose: Example app that implements the package: sliding_up_panel
Copyright: © 2020, Akshath Jain. All rights reserved.
Licensing: More information can be found here: https://github.com/akshathjain/sliding_up_panel/blob/master/LICENSE
*/

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:mood_manager/features/common/presentation/widgets/empty_widget.dart';
import 'package:mood_manager/features/memory/data/datasources/memory_remote_data_source.dart';
import 'package:mood_manager/features/memory/domain/entities/memory_collection.dart';
import 'package:mood_manager/injection_container.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

import 'package:cached_network_image/cached_network_image.dart';

class MemoryCollectionSelector extends StatefulWidget {
  @override
  _MemoryCollectionSelectorState createState() =>
      _MemoryCollectionSelectorState();
}

class _MemoryCollectionSelectorState extends State<MemoryCollectionSelector> {
  final double _initFabHeight = 120.0;
  double _panelHeightOpen;
  double _panelHeightClosed = 195.0;

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
    return MediaQuery.removePadding(
        context: context,
        removeTop: true,
        child: ListView(
          controller: sc,
          children: <Widget>[
            SizedBox(
              height: 18.0,
            ),
            ListTile(
              title: Text('Add to collection'),
              trailing: IconButton(
                  icon: Icon(Icons.close),
                  onPressed: () {
                    Navigator.of(context).pop();
                  }),
            ),
            SizedBox(
              height: 36.0,
            ),
            FutureBuilder<List<MemoryCollection>>(
              future: sl<MemoryRemoteDataSource>().getMemoryCollectionList(),
              initialData: [],
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
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
            )
          ],
        ));
  }

  Widget _body() {
    return EmptyWidget();
  }
}
