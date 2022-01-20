import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:vivity/config/themes/themes_config.dart';
import '../../helpers/ui_helpers.dart';

class VivityAppBar extends PreferredSize {
  VivityAppBar({Key? key, double height = 120, this.bottom, this.elevation = 7}) : super(key: key, preferredSize: Size.fromHeight(height), child: Container());

  final PreferredSizeWidget? bottom;
  final double elevation;

  @override
  Widget build(BuildContext context) {
    double appBarHeight = preferredSize.height;
    SvgPicture logo = SvgPicture.asset(
      "assets/icons/abstract_logo.svg",
      color: primaryComplementaryColor,
      width: MediaQuery.of(context).size.width * 0.35,
      height: (preferredSize.height - 20) * 0.6,
      key: key,
    );

    const double hamburgerMenuSize = 30;

    return AppBar(
      backgroundColor: Theme.of(context).primaryColor,
      toolbarHeight: appBarHeight,
      elevation: elevation,
      leading: Align(
        alignment: Alignment.topLeft,
        child: IconButton(
          key: key,
          onPressed: () {},
          icon: const Icon(
            Icons.menu,
            color: Colors.white,
            size: hamburgerMenuSize,
          ),
        ),
      ),
      centerTitle: true,
      title: logo,
      bottom: bottom,
    );
  }
}
