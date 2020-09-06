import 'dart:developer';

import 'package:flutter/material.dart';

enum ScrollDirection { horizontal, vertical }
int _listRotation;
int _listItemRotation;

class ScrollSelect<T> extends StatefulWidget {
  // properties
  final Function onChanged;
  final T initialValue;
  final ScrollDirection scrollDirection;
  final Color backgroundColor;
  final double itemFontSize;
  final List<ScrollSelectOption> options;
  final double height;
  final double itemExtent;

  // contructor
  ScrollSelect(
      {@required this.options,
      @required this.initialValue,
      @required this.scrollDirection,
      @required this.onChanged,
      this.backgroundColor = Colors.white,
      this.itemFontSize = 20.0,
      this.height = 100.0,
      this.itemExtent = 60.0})
      : assert(onChanged != null);

  @override
  _ScrollSelectState createState() => _ScrollSelectState();
}

class _ScrollSelectState extends State<ScrollSelect> {
  // similar to scrollcontroller but with added mechanism to stop and read the given indices
  FixedExtentScrollController _scrollController;
  // to store value, fontsize, and color of the text in the picker
  @override
  void initState() {
    super.initState();
    _scrollController = FixedExtentScrollController();
  }

  scrollToSelected(context) {
    //debugger(when:false);
    _scrollController.jumpToItem(widget.options
        .map((e) => e.value)
        .toList()
        .indexOf(widget.initialValue));
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance
        .addPostFrameCallback((_) => scrollToSelected(context));
    ScrollSelectOption curItem;
    switch (widget.scrollDirection) {
      case ScrollDirection.horizontal:
        _listRotation = 3;
        _listItemRotation = 1;
        break;
      case ScrollDirection.vertical:
        _listRotation = 2;
        _listItemRotation = 2;
        break;
    }

    return Container(
      height: widget.height,
      width: double.infinity,
      alignment: Alignment.center,
      child: RotatedBox(
          quarterTurns: _listRotation,
          child: ListWheelScrollView.useDelegate(
              physics: FixedExtentScrollPhysics(),
              controller: _scrollController,
              itemExtent: widget.itemExtent,
              onSelectedItemChanged: (item) {
                curItem = widget.options[item];
                setState(() {
                  widget.onChanged(curItem.value);
                });
              },
              childDelegate: ListWheelChildLoopingListDelegate(
                  children: List<Widget>.generate(
                widget.options.length,
                (index) => ItemWidget(
                    widget.options[index],
                    widget.backgroundColor,
                    widget.itemFontSize,
                    widget.initialValue),
              ))
              /*childDelegate: ListWheelChildBuilderDelegate(
                builder: (context, index) => ListTile(
                      onTap: () =>
                          {debugger(when:false), _scrollController.jumpToItem(index)},
                      title: ItemWidget(
                          widget.options[index],
                          widget.backgroundColor,
                          widget.itemFontSize,
                          widget.initialValue),
                    ),
                childCount: widget.options.length),*/
              /*children: widget.options.map((curValue) {
              //debugger(when:false);
              return ListTile(
                onTap: () => {
                  debugger(when:false),
                  _scrollController.jumpToItem(widget.options.indexOf(curValue))
                },
                title: ItemWidget(curValue, widget.backgroundColor,
                    widget.itemFontSize, widget.initialValue),
              );
            }).toList()),*/
              )),
    );
  }
}

class ItemWidget<T> extends StatefulWidget {
  final ScrollSelectOption<T> curItem;
  final double fontSize;
  final Color backgroundColor;
  T initialValue;
  ItemWidget(
      this.curItem, this.backgroundColor, this.fontSize, this.initialValue);

  @override
  _ItemWidgetState createState() => _ItemWidgetState();
}

class _ItemWidgetState extends State<ItemWidget> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // debugger(when:false);
    return RotatedBox(
      quarterTurns: _listItemRotation,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            widget.curItem.label,
            style: TextStyle(
              fontSize: widget.fontSize,
              fontWeight: widget.curItem.value == widget.initialValue
                  ? FontWeight.bold
                  : FontWeight.normal,
              color: widget.curItem.value == widget.initialValue
                  ? widget.curItem.color
                  : widget.curItem.color.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
            softWrap: false,
          ),
        ],
      ),
    );
  }
}

class ScrollSelectOption<T> {
  final T value;
  final String label;
  final Color color;

  ScrollSelectOption({
    @required this.value,
    @required this.color,
    @required this.label,
  });

  /// Helper to create option list from any list
  static List<ScrollSelectOption<R>> listFrom<R, E>(
          {@required List<E> source,
          @required _ScrollSelectOptionProp<E, R> value,
          @required _ScrollSelectOptionProp<E, String> label,
          @required _ScrollSelectOptionProp<E, Color> color}) =>
      source
          .asMap()
          .map((index, item) => MapEntry(
              index,
              ScrollSelectOption<R>(
                value: value?.call(index, item),
                label: label?.call(index, item),
                color: color?.call(index, item),
              )))
          .values
          .toList()
          .cast<ScrollSelectOption<R>>();
}

typedef R _ScrollSelectOptionProp<T, R>(int index, T item);
