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
    return Material(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(topLeft: Radius.circular(30), bottomLeft: Radius.circular(30)),
      ),
      elevation: 7,
      clipBehavior: Clip.antiAlias,
      child: Container(
        width: sliderSize.width,
        height: sliderSize.height,
        color: Theme.of(context).primaryColor,
        child: Padding(
          padding: EdgeInsets.only(left: sliderSize.width - icon.width! * 1.5),
          child: FittedBox(
            child: icon,
            fit: BoxFit.scaleDown,
          ),
        ),
      ),
    );
  }
}
