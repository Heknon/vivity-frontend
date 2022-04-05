import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:sizer/sizer.dart';
import 'package:vivity/features/item/models/item_model.dart';
import 'package:vivity/helpers/item_data_helper.dart';

class ItemDataSection extends StatelessWidget {
  final double contextWidth;
  final double contextHeight;
  final CartItemModel itemModel;

  const ItemDataSection({
    Key? key,
    required this.itemModel,
    required this.contextWidth,
    required this.contextHeight,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Iterable<Widget> itemDataTexts = buildItemDataTexts(context, contextWidth);

    return Padding(
      padding: const EdgeInsets.only(top: 5),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              itemModel.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.headline4!.copyWith(fontSize: 12.sp),
            ),
            ...itemDataTexts,
          ],
        ),
      ),
    );
  }

  Iterable<Widget> buildItemDataTexts(BuildContext ctx, double usedWidth) {
    return itemModel.modifiersChosen.map(
      (e) {
        if (e.dataType == ModificationButtonDataType.text) {
          return Text(
            "${e.name}: ${e.selectedData.join(", ")}",
            style: Theme.of(ctx).textTheme.subtitle2!.copyWith(fontSize: 10.sp),
          );
        }
        return Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(
              "${e.name}:",
              style: Theme.of(ctx).textTheme.subtitle2!.copyWith(fontSize: 10.sp),
            ),
            if (e.dataType == ModificationButtonDataType.color)
              ...buildColoredDataType(ctx, e)
            else if (e.dataType == ModificationButtonDataType.image)
              ...buildImageDataType(e),
          ],
        );
      },
    );
  }
}
