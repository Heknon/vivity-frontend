import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SimpleCard extends StatelessWidget {
  final Widget child;
  final double elevation;

  final double? topLeftRadius;
  final double? topRightRadius;
  final double? bottomLeftRadius;
  final double? bottomRightRadius;
  final double? radius;

  const SimpleCard({
    Key? key,
    this.elevation = 0,
    this.topLeftRadius,
    this.topRightRadius,
    this.bottomLeftRadius,
    this.bottomRightRadius,
    this.radius,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: elevation,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: radius != null
            ? BorderRadius.all(Radius.circular(radius!))
            : BorderRadius.only(
                topRight: topRightRadius != null ? Radius.circular(topRightRadius!) : const Radius.circular(0),
                topLeft: topLeftRadius != null ? Radius.circular(topLeftRadius!) : const Radius.circular(0),
                bottomRight: bottomRightRadius != null ? Radius.circular(bottomRightRadius!) : const Radius.circular(0),
                bottomLeft: bottomLeftRadius != null ? Radius.circular(bottomLeftRadius!) : const Radius.circular(0),
              ),
      ),
      child: child,
    );
  }
}
