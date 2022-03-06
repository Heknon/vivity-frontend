import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:sizer/sizer.dart';
import 'package:vivity/features/item/models/item_model.dart';
import 'package:vivity/widgets/quantity.dart';
import 'package:vivity/widgets/simple_card.dart';

import 'item_data_section.dart';


class CartItem extends StatelessWidget {
  final CartItemModel itemModel;
  final double? width;
  final double? height;
  final void Function(QuantityController, int?)? onQuantityIncrement;
  final void Function(QuantityController, int?)? onQuantityDecrement;
  final void Function(QuantityController, int?)? onQuantityDelete;
  final QuantityController? quantityController;
  final int? id;
  final BorderRadius? borderRadius;

  const CartItem({
    Key? key,
    required this.itemModel,
    this.width,
    this.height,
    this.onQuantityIncrement,
    this.onQuantityDecrement,
    this.onQuantityDelete,
    this.quantityController,
    this.id,
    this.borderRadius
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (ctx, constraints) {
        double usedWidth = width ?? constraints.maxWidth;
        double usedHeight = height ?? constraints.maxHeight;

        return SizedBox(
          width: usedWidth,
          height: usedHeight,
          child: SimpleCard(
            elevation: 7,
            borderRadius: borderRadius,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  height: usedHeight,
                  padding: const EdgeInsets.only(top: 5, bottom: 5, left: 8, right: 12),
                  child: buildPreviewImage(),
                ),
                Expanded(
                  flex: 2,
                  child: ItemDataSection(
                    itemModel: itemModel,
                    contextWidth: usedWidth,
                    contextHeight: usedHeight,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        '\$${itemModel.price.toStringAsFixed(2)}',
                        style: Theme.of(context).textTheme.headline4!.copyWith(fontSize: 13.sp),
                      ),
                      const Spacer(),
                      ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: constraints.maxWidth * 0.25,
                          maxHeight: constraints.maxWidth * 0.25 / 3
                        ),
                        child: Quantity(
                          initialCount: itemModel.quantity,
                          color: Theme.of(context).primaryColor,
                          onDecrement: onQuantityDecrement,
                          onIncrement: onQuantityIncrement,
                          onDelete: onQuantityDelete,
                          controller: quantityController,
                          id: id,
                        ),
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
        );
      },
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
}
