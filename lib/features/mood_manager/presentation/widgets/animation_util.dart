import 'package:flutter/material.dart';

Widget Function(
  BuildContext context,
  Animation<double> animation,
) animationBuilder(
  Widget child, {
  double xOffset = 0,
  EdgeInsets padding = EdgeInsets.zero,
}) =>
    (
      BuildContext context,
      Animation<double> animation,
    ) =>
        FadeTransition(
          opacity: Tween<double>(
            begin: 0,
            end: 1,
          ).animate(animation),
          child: SlideTransition(
            position: Tween<Offset>(
              begin: Offset(xOffset, 0.1),
              end: Offset.zero,
            ).animate(animation),
            child: Padding(
              padding: padding,
              child: child,
            ),
          ),
        );
