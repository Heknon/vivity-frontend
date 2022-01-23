import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:sizer/sizer.dart';
import 'package:vivity/features/item/models/item_model.dart';

import '../../../widgets/preview_dialog.dart';

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

  ClipRRect buildPreviewImage() {
    return ClipRRect(
      borderRadius: const BorderRadius.all(Radius.circular(50)),
      clipBehavior: Clip.antiAlias,
      child: CachedNetworkImage(
        imageUrl: itemModel.previewImage,
      ),
    );
  }

  Iterable<Widget> buildItemDataTexts(BuildContext ctx, double usedWidth) {
    return itemModel.chosenData.map(
      (e) {
        if (e.dataType == ModificationButtonDataType.text) {
          return Text(
            "${e.name}: ${e.dataChosen.join(", ")}",
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

  Iterable<Widget> buildImageDataType(ModificationButtonDataHost e) {
    return e.dataChosen.map(
      (d) => Padding(
        padding: const EdgeInsets.only(left: 3.0),
        child: buildImageCircle(e.name, d as String),
      ),
    );
  }

  Iterable<Widget> buildColoredDataType(BuildContext context, ModificationButtonDataHost e) {
    return e.dataChosen.map(
      (d) => Padding(
        padding: const EdgeInsets.only(left: 3.0),
        child: buildColoredCircle(context, e.name, Color(d as int)),
      ),
    );
  }

  Widget buildColoredCircle(BuildContext ctx, String title, Color color) {
    return ClipRRect(
      borderRadius: const BorderRadius.all(Radius.circular(100)),
      child: InkWell(
        onTap: () => showDialog(
          context: ctx,
          builder: (ctx) => PreviewDialog(
            title: title,
            content: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.all(Radius.circular(8))
              ),
            ),
          ),
        ),
        child: Container(
          width: 10.5.sp,
          height: 10.5.sp,
          color: color,
        ),
      ),
    );
  }

  Widget buildImageCircle(String title, String url) {
    return CachedNetworkImage(
      imageUrl: url,
      imageBuilder: (ctx, prov) => InkWell(
        onTap: () => showDialog(
          context: ctx,
          builder: (ctx) => PreviewDialog(
            title: title,
            content: Image(image: prov),
          ),
        ),
        child: CircleAvatar(
          radius: 5.25.sp,
          foregroundImage: prov,
        ),
      ),
    );
  }
}
