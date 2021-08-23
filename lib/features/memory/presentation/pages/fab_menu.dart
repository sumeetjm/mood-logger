import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:mood_manager/core/util/hex_color.dart';
import 'package:mood_manager/injection_container.dart';
import 'package:tinycolor/tinycolor.dart';
import 'package:uuid/uuid.dart';

class FancyFab extends StatefulWidget {
  final Function() onPressed;
  final String tooltip;
  final IconData icon;
  final Function addMemory;
  final Function addTask;

  FancyFab({
    this.onPressed,
    this.tooltip,
    this.icon,
    Key key,
    this.addMemory,
    this.addTask,
  }) : super(key: key);

  @override
  FancyFabState createState() => FancyFabState();
}

class FancyFabState extends State<FancyFab>
    with SingleTickerProviderStateMixin {
  bool isOpened = false;
  AnimationController _animationController;
  Animation<Color> _buttonColor;
  Animation<double> _animateIcon;
  Animation<double> _translateButton;
  Curve _curve = Curves.easeOut;
  double _fabHeight = 56.0;
  Uuid uuid = sl<Uuid>();

  @override
  initState() {
    _animationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 250))
          ..addListener(() {
            setState(() {});
          });
    _animateIcon =
        Tween<double>(begin: 0.0, end: 1.0).animate(_animationController);
    _buttonColor = ColorTween(
      begin: HexColor.fromHex('#eb8b5e'),
      end: Colors.red,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Interval(
        0.00,
        1.00,
        curve: Curves.linear,
      ),
    ));
    _translateButton = Tween<double>(
      begin: _fabHeight,
      end: -14.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Interval(
        0.0,
        0.75,
        curve: _curve,
      ),
    ));
    super.initState();
  }

  @override
  dispose() {
    _animationController.dispose();
    super.dispose();
  }

  animate() {
    if (!isOpened) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
    isOpened = !isOpened;
  }

  close() {
    if (isOpened) {
      _animationController.reverse();
    }
  }

  Widget add() {
    return Container(
      child: FloatingActionButton(
        backgroundColor: Colors.green,
        onPressed: null,
        tooltip: 'Add',
        child: Icon(Icons.add),
        heroTag: uuid.v1(),
      ),
    );
  }

  Widget memory() {
    return Container(
      child: FloatingActionButton(
        backgroundColor: Colors.green,
        onPressed: widget.addMemory,
        child: Stack(
          children: [
            Icon(
              Icons.list_rounded,
              color: Colors.white,
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: CircleAvatar(
                backgroundColor: Colors.green,
                radius: 6.5,
                child: CircleAvatar(
                  backgroundColor: Colors.white,
                  radius: 5,
                  child: Icon(
                    Icons.add,
                    size: 10,
                    color: Colors.green,
                  ),
                ),
              ),
            ),
          ],
        ),
        heroTag: uuid.v1(),
      ),
    );
  }

  Widget task() {
    return Container(
      child: FloatingActionButton(
        backgroundColor: Colors.blue,
        onPressed: () => widget.addTask(),
        tooltip: 'Inbox',
        child: Stack(
          children: [
            Icon(
              Icons.list_alt_rounded,
              color: Colors.white,
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: CircleAvatar(
                backgroundColor: Colors.blue,
                radius: 6.5,
                child: CircleAvatar(
                  backgroundColor: Colors.white,
                  radius: 5,
                  child: Icon(
                    Icons.add,
                    size: 10,
                    color: Colors.green,
                  ),
                ),
              ),
            ),
          ],
        ),
        heroTag: uuid.v1(),
      ),
    );
  }

  Widget toggle() {
    return Container(
      child: FloatingActionButton(
        backgroundColor: _buttonColor.value,
        onPressed: animate,
        tooltip: 'Toggle',
        child: AnimatedIcon(
          color: Colors.white,
          icon: AnimatedIcons.menu_close,
          progress: _animateIcon,
        ),
        heroTag: uuid.v1(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        Transform(
          transform: Matrix4.translationValues(
            0.0,
            _translateButton.value * 2.0,
            0.0,
          ),
          child: memory(),
        ),
        Transform(
          transform: Matrix4.translationValues(
            0.0,
            _translateButton.value,
            0.0,
          ),
          child: task(),
        ),
        toggle(),
      ],
    );
  }
}
