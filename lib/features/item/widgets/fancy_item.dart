import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:vivity/features/item/models/item_model.dart';

class FancyItem extends StatelessWidget {
  final ItemModel itemModel;
  final double? width;
  final double? height;

  const FancyItem({Key? key, required this.itemModel, this.width, this.height}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (ctx, constraints) {
        return SizedBox(
        width: width ?? constraints.maxWidth,
        height: height ?? constraints.maxHeight,
        child: const Card(
          margin: EdgeInsets.only(left: 0),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
            topRight: Radius.circular(8),
            bottomRight: Radius.circular(8),
          )),
          elevation: 5,
          color: Colors.white,
        ),
      );
      },
    );
  }
}
