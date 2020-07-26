import 'package:flutter/material.dart';
import 'package:mood_manager/features/mood_manager/data/models/t_mood_model.dart';
import 'package:intl/intl.dart';
import 'package:mood_manager/features/mood_manager/presentation/widgets/empty_widget.dart';
import 'package:tinycolor/tinycolor.dart';

class GroupList extends StatefulWidget {
  final List<TMoodModel> tMoodList;
  final TMoodModel scrollToMood;
  Map<String, List<TMoodModel>> groupedMap;
  List<String> groupedKeys;
  final DateFormat dateFormat = DateFormat('dd MMMM yyyy');
  GroupList({@required this.tMoodList, this.scrollToMood}) {
    groupedMap = Map.fromEntries(tMoodList
        .map((tMood) => dateFormat.format(tMood.logDateTime))
        .toList()
        .toSet()
        .toList()
        .map((dateStr) => MapEntry<String, List<TMoodModel>>(
            dateStr,
            tMoodList
                .where((element) =>
                    dateFormat.format(element.logDateTime) == dateStr)
                .toList())));
    groupedKeys = groupedMap.keys.toList();
  }

  @override
  _GroupListState createState() => _GroupListState();
}

class _GroupListState extends State<GroupList>
    with SingleTickerProviderStateMixin {
  ScrollController controller = ScrollController();
  void initState() {
    super.initState();
    if (widget.scrollToMood != null) {}
    WidgetsBinding.instance.addPostFrameCallback((_) {
      scrollToItem();
    });
  }

  scrollToItem() {
    if (widget.scrollToMood != null) {
      int groupIndex = widget.groupedKeys
          .asMap()
          .entries
          .firstWhere((entry) =>
              entry.value ==
              widget.dateFormat.format(widget.scrollToMood.logDateTime))
          .key;
      int itemIndex = widget.tMoodList
          .asMap()
          .entries
          .firstWhere((entry) =>
              entry.value.transMoodId == widget.scrollToMood.transMoodId)
          .key;
      controller.animateTo(groupIndex * 30.0 + itemIndex * 100.0,
          duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
    }
  }

  List<Widget> buildListItem(List<TMoodModel> transactionList) {
    Map<int, TMoodModel> map = transactionList.asMap();
    return map.keys
        .map(
          (index) => Column(children: [
            index == map.keys.first
                ? buildGroupHeader(map, index)
                : EmptyWidget(),
            buildItem(map, index),
          ]),
        )
        .toList();
  }

  Widget buildItem(Map<int, TMoodModel> map, int index) {
    return Container(
      height: 100,
      decoration: BoxDecoration(
          border: index != map.keys.last
              ? Border(bottom: BorderSide(width: 0))
              : Border()),
      child: Column(
        children: <Widget>[
          Stack(children: [
            Container(
              width: MediaQuery.of(context).size.width * 1,
              height: 90,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.rectangle,
              ),
            ),
            Padding(
              padding: EdgeInsets.all(10),
              child: Container(
                  width: 60,
                  height: 60,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: map[index].mMood.color,
                  ),
                  child: Text(map[index].mMood.name)),
            ),
            Positioned(
                right: 5,
                child: Text(
                  DateFormat(DateFormat.HOUR_MINUTE)
                      .format(map[index].logDateTime),
                  style: TextStyle(fontWeight: FontWeight.bold),
                )),
            Positioned(
                top: 20,
                left: 80,
                child: Container(
                    //color: Colors.blue,
                    width: MediaQuery.of(context).size.width * 0.7,
                    child: Text(
                      map[index]
                          .tActivityList
                          .map((item) => item.mActivity.name)
                          .join(" | "),
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.normal,
                          color: TinyColor(map[index].mMood.color)
                              .darken(25)
                              .color),
                    ))),
          ]),
        ],
      ),
    );
  }

  Container buildGroupHeader(Map<int, TMoodModel> map, int index) {
    return Container(
        height: 30,
        decoration: new BoxDecoration(
            color: getAverageColor(
                map.keys.map((key) => map[key].mMood.color).toList()),
            borderRadius: new BorderRadius.only(
              topLeft: const Radius.circular(15.0),
              topRight: const Radius.circular(15.0),
            )),
        child: Center(
            child: Text(
          widget.dateFormat.format(map[index].logDateTime),
          style: TextStyle(
              color: Colors.grey[50],
              fontSize: 18,
              fontWeight: FontWeight.bold,
              fontStyle: FontStyle.italic),
        )));
  }

  Color getAverageColor(List<Color> colors) {
    return Color.fromRGBO(
        colors
                .map((color) => color.red)
                .reduce((value, element) => value + element) ~/
            colors.length,
        colors
                .map((color) => color.green)
                .reduce((value, element) => value + element) ~/
            colors.length,
        colors
                .map((color) => color.blue)
                .reduce((value, element) => value + element) ~/
            colors.length,
        1);
  }

  @override
  Widget build(BuildContext context) {
    List<String> groupKeys = widget.groupedMap.keys.toList();
    return ListView.builder(
      controller: controller,
      physics: BouncingScrollPhysics(),
      scrollDirection: Axis.vertical,
      padding: const EdgeInsets.all(8),
      itemCount: widget.groupedMap.length,
      itemBuilder: (BuildContext context, int index) {
        List<TMoodModel> dayWiseTransList = widget.groupedMap[groupKeys[index]];
        return Column(
          children: <Widget>[
            Card(
              color: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0)),
              child: Column(children: buildListItem(dayWiseTransList)),
            ),
            index == groupKeys.length - 1
                ? SizedBox(
                    height: 80,
                  )
                : EmptyWidget()
          ],
        );
      },
    );
  }
}
