import 'package:custom_radio/custom_radio.dart';
import 'package:flutter/material.dart';
import 'package:invert_colors/invert_colors.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:mood_manager/features/metadata/domain/entities/m_mood.dart';
import 'dart:math';

import 'package:mood_manager/features/common/presentation/widgets/empty_widget.dart';

class RadioSelection extends StatefulWidget {
  RadioSelection(
      {Key key,
      this.initialValue,
      this.onChange,
      this.parentCircleRadius,
      this.parentCircleColor,
      this.initialSubValue,
      this.moodList,
      this.showLabel = true,
      this.showClear = false})
      : super(key: key);

  MMood initialValue;
  MMood initialSubValue;
  List<MMood> moodList;
  final double parentCircleRadius;
  final Color parentCircleColor;
  final Function onChange;
  bool showLabel;
  bool showClear;

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
      if (value.mMoodList.contains(widget.initialSubValue)) {
        value = widget.initialSubValue;
      }
      return GestureDetector(
          onTap: () {
            setState(() {
              widget.onChange(value);
            });
          },
          child: value == widget.initialSubValue ||
                  value.mMoodList.contains(widget.initialSubValue)
              ? Stack(children: <Widget>[
                  Positioned.fill(
                    child: CircleAvatar(
                      // child: Text(value.moodName),
                      backgroundColor: color.withAlpha(alpha),
                      radius: widget.parentCircleRadius / 4, // Color
                    ),
                  ),
                  InvertColors(
                    child: ImageIcon(
                      AssetImage('assets/${value.moodName}.png'),
                      size: widget.parentCircleRadius / 2,
                      //color: color,
                    ),
                  ),
                ])
              : ImageIcon(
                  AssetImage(
                    'assets/${value.moodName}.png',
                  ),
                  size: widget.parentCircleRadius / 2,
                  color: color,
                ));
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
          .toList(),
      if (widget.showClear)
        Positioned(
          top: widget.parentCircleRadius * 0.675,
          left: widget.parentCircleRadius * 0.675,
          child: IconButton(
              icon: Icon(
                MdiIcons.restore,
                color: Colors.black.withOpacity(0.2),
                size: widget.parentCircleRadius / 2,
              ),
              onPressed: () {
                setState(() {
                  widget.initialValue = null;
                  widget.onChange(null);
                });
              }),
        )
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
