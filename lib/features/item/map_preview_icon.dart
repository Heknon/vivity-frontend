import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:vivity/features/item/models/item_model.dart';

import '../../helpers/ui_helpers.dart' as ui;


class MapPreviewIcon extends StatelessWidget {
  final ItemModel item;
  final void Function(ItemModel)? onTap;

  const MapPreviewIcon({
    Key? key,
    required this.item,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22.0)),
      elevation: 7,
      clipBehavior: Clip.antiAlias,
      child: Container(
        color: Colors.white,
        child: Center(
          child: InkWell(
            overlayColor: MaterialStateProperty.all(Colors.white.withOpacity(0.6)),
            splashFactory: InkRipple.splashFactory,
            onTap: () => onTap != null ? onTap!(item) : null,
            child: _buildTextWidget(item.price, context),
          ),
        ),
      ),
    );
  }

  static Text _buildTextWidget(double price, BuildContext context) {
    return Text(
        "₪${price.toStringAsFixed(2)}", // TODO: Future currency conversion
        style: Theme
            .of(context)
            .textTheme
            .headline4
            ?.copyWith(fontSize: 10.sp, fontFamily: "Arial", fontWeight: FontWeight.bold)
    );
  }

  static Size getTextSize(double price, BuildContext context) {
    return ui.getTextSize(_buildTextWidget(price, context));
  }
}
