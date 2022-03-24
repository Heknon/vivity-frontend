import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:vivity/features/explore/explore.dart';
import 'package:vivity/features/item/item_page.dart';
import 'package:vivity/features/item/like_button.dart';
import 'package:vivity/widgets/rating.dart';
import 'package:vivity/widgets/simple_card.dart';

import 'models/item_model.dart';

class PreviewItem extends StatelessWidget {
  final Size? size;
  final ItemModel item;

  const PreviewItem({Key? key, this.size, required this.item}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      double usedWidth = size?.width ?? constraints.maxWidth;
      double usedHeight = size?.height ?? constraints.maxHeight;

      return SizedBox(
        height: usedHeight,
        width: usedWidth,
        child: SimpleCard(
          elevation: 7,
          borderRadius: const BorderRadius.all(Radius.circular(15)),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                height: usedHeight,
                padding: const EdgeInsets.only(top: 5, bottom: 5, left: 8, right: 12),
                child: buildPreviewImage(),
              ),
              SizedBox(width: 10),
              Expanded(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.only(top: 6, bottom: 6),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.itemStoreFormat.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.headline4!.copyWith(fontSize: 14.sp),
                      ),
                      SizedBox(height: 2),

                      Spacer(),
                      Rating.fromReviews(item.reviews, fontSize: 10,),
                    ],
                  ),
                ),
              ),
              Spacer(),
              Padding(
                padding: const EdgeInsets.only(right: 5, top: 5, bottom: 5),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    LikeButton(
                      color: Theme.of(context).primaryColor,
                      controller: LikeButtonController(), // TODO: Connect to user liked items using onClick
                    ),
                    Text(
                      "₪${item.price.toStringAsFixed(2)}",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.headline4!.copyWith(fontSize: 14.sp),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  ClipRRect buildPreviewImage() {
    return ClipRRect(
      borderRadius: const BorderRadius.all(Radius.circular(15)),
      clipBehavior: Clip.antiAlias,
      child: CachedNetworkImage(
        imageUrl: item.images[item.previewImageIndex],
      ),
    );
  }
}
