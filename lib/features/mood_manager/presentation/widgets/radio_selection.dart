import 'package:custom_radio/custom_radio.dart';
import 'package:flutter/material.dart';
import 'package:mood_manager/features/mood_manager/domain/entities/m_mood.dart';
import 'dart:math';

import 'package:mood_manager/features/mood_manager/presentation/widgets/empty_widget.dart';

class RadioSelection extends StatefulWidget {
  RadioSelection(
      {Key key,
      this.initialValue,
      this.onChange,
      this.parentCircleRadius,
      this.parentCircleColor,
      this.initialSubValue,
      this.moodList,
      this.showLabel = true})
      : super(key: key);

  MMood initialValue;
  MMood initialSubValue;
  List<MMood> moodList;
  final double parentCircleRadius;
  final Color parentCircleColor;
  final Function onChange;
  bool showLabel;

  @override
  State<RadioSelection> createState() => _RadioSelectionState();
}

class _RadioSelectionState extends State<RadioSelection>
    with SingleTickerProviderStateMixin {
  _RadioSelectionState() {
    simpleBuilder = (BuildContext context, List<double> animValues,
        Function updateState, MMood value) {
      final alpha = (animValues[0] * 255).toInt();
      final color = value.color;
      return GestureDetector(
          onTap: () {
            setState(() {
              widget.onChange(value);
            });
          },
          child: Container(
              width: widget.parentCircleRadius / 2,
              height: widget.parentCircleRadius / 2,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color.withAlpha(alpha),
                  border: Border.all(
                    color: color.withAlpha(255 - alpha),
                    width: 3.0,
                  )),
              child: widget.showLabel
                  ? Text(
                      value == widget.initialValue &&
                              widget.initialSubValue != null
                          ? widget.initialSubValue.moodName.toUpperCase()
                          : value.moodName.toUpperCase(),
                      style: TextStyle(color: alpha > 0 ? Colors.white : color))
                  : EmptyWidget()));
    };
  }

  RadioBuilder<MMood, double> simpleBuilder;
  AnimationController _controller;
  Animation<double> _animation;

  List<Widget> getChildren() {
    Widget bigCircle = Container(
      width: widget.parentCircleRadius * 2,
      height: widget.parentCircleRadius * 2,
      decoration: BoxDecoration(
        color: widget.parentCircleColor,
        shape: BoxShape.circle,
      ),
    );
    return [
      bigCircle,
      ...widget.moodList
          .asMap()
          .keys
          .map((key) => Positioned(
                child: CustomRadio<MMood, double>(
                    value: widget.moodList.asMap()[key],
                    groupValue: widget.initialValue,
                    duration: Duration(milliseconds: 500),
                    animsBuilder: (AnimationController controller) => [
                          CurvedAnimation(
                              parent: controller, curve: Curves.easeInOut)
                        ],
                    builder: simpleBuilder),
                top: widget.parentCircleRadius *
                    (3 / 4 +
                        cos(key * 2 * pi / widget.moodList.length) * 2 / 3),
                left: widget.parentCircleRadius *
                    (3 / 4 +
                        sin(key * 2 * pi / widget.moodList.length) * 2 / 3),
              ))
          .toList()
    ];
  }

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(duration: Duration(milliseconds: 100), vsync: this);
    _animation =
        CurvedAnimation(parent: _controller, curve: Curves.bounceInOut);
    _controller.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Center(
          child: Stack(children: getChildren()),
        ),
      ],
    );
  }
}
