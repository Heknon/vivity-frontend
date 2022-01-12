import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/svg.dart';

class SideTab extends StatelessWidget {
  const SideTab({
    Key? key,
    required this.sliderSize,
    required this.icon,
  }) : super(key: key);

  final Size sliderSize;
  final SvgPicture icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: sliderSize.width,
      height: sliderSize.height,
      child: Padding(
        padding: EdgeInsets.only(left: sliderSize.width - icon.width! * 1.5),
        child: FittedBox(
          child: icon,
          fit: BoxFit.scaleDown,
        ),
      ),
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.only(topLeft: Radius.circular(30), bottomLeft: Radius.circular(30)),
        color: Theme.of(context).primaryColor,
      ),
    );
  }
}