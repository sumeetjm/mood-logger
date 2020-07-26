import 'package:mood_manager/features/mood_manager/data/models/m_mood_model.dart';
import 'package:custom_radio/custom_radio.dart';
import 'package:flutter/material.dart';
import 'package:mood_manager/features/mood_manager/domain/entities/m_mood.dart';
import 'dart:math';

import 'package:provider/provider.dart';

class RadioSelection extends StatefulWidget {
  RadioSelection(
      {Key key,
      this.initialValue,
      this.onChange,
      this.parentCircleRadius,
      this.parentCircleColor})
      : super(key: key);

  MMoodModel initialValue;
  final double parentCircleRadius;
  final Color parentCircleColor;
  final ValueChanged<MMoodModel> onChange;

  @override
  State<RadioSelection> createState() => _RadioSelectionState();
}

class _RadioSelectionState extends State<RadioSelection>
    with SingleTickerProviderStateMixin {
  _RadioSelectionState() {
    simpleBuilder = (BuildContext context, List<double> animValues,
        Function updateState, MMoodModel value) {
      final alpha = (animValues[0] * 255).toInt();
      final color = value.color;
      return GestureDetector(
          onTap: () {
            setState(() {
              widget.initialValue = value;
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
              child: Text(
                value.name,
              )));
    };
  }

  RadioBuilder<MMoodModel, double> simpleBuilder;
  AnimationController _controller;
  Animation<double> _animation;

  List<Widget> getChildren() {
    final moodList = Provider.of<List<MMood>>(context) ?? [];
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
      ...moodList
          .asMap()
          .keys
          .map((key) => Positioned(
                child: CustomRadio<MMoodModel, double>(
                    value: moodList.asMap()[key],
                    groupValue: widget.initialValue,
                    duration: Duration(milliseconds: 500),
                    animsBuilder: (AnimationController controller) => [
                          CurvedAnimation(
                              parent: controller, curve: Curves.easeInOut)
                        ],
                    builder: simpleBuilder),
                top: widget.parentCircleRadius *
                    (3 / 4 + cos(key * 2 * pi / moodList.length) * 2 / 3),
                left: widget.parentCircleRadius *
                    (3 / 4 + sin(key * 2 * pi / moodList.length) * 2 / 3),
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
    return Center(
      child: Stack(children: getChildren()),
    );
  }
}
