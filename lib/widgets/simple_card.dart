import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SimpleCard extends StatelessWidget {
  final Widget child;
  final double elevation;

  final BorderRadius? borderRadius;
  final VoidCallback? onTap;
  final VoidCallback? onLongTap;
  final Color? overlayColor;
  final InteractiveInkFeatureFactory? splashFactory;

  const SimpleCard({
    Key? key,
    this.elevation = 0,
    this.borderRadius,
    required this.child,
    this.onTap,
    this.overlayColor,
    this.splashFactory,
    this.onLongTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: elevation,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: borderRadius ?? const BorderRadius.only(topRight: Radius.circular(8), bottomRight: Radius.circular(8)),
      ),
      child: InkWell(
        overlayColor: overlayColor != null ? MaterialStateProperty.all(overlayColor) : null,
        splashFactory: splashFactory,
        onTap: onTap,
        onLongPress: onLongTap,
        child: child,
      ),
    );
  }
}
