import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SimpleCard extends StatelessWidget {
  final Widget child;
  final double elevation;

  final BorderRadius? borderRadius;

  const SimpleCard({
    Key? key,
    this.elevation = 0,
    this.borderRadius,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: elevation,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: borderRadius ?? const BorderRadius.only(topRight: Radius.circular(8), bottomRight: Radius.circular(8)),
      ),
      child: child,
    );
  }
}
