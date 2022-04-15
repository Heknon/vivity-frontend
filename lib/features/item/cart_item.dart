import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:sizer/sizer.dart';
import 'package:vivity/constants/asset_path.dart';
import 'package:vivity/features/cart/models/cart_item_model.dart';
import 'package:vivity/features/item/ui_item_helper.dart';
import 'package:vivity/widgets/quantity.dart';
import 'package:vivity/widgets/simple_card.dart';

import '../../services/item_service.dart';
import 'item_data_section.dart';

class CartItem extends StatefulWidget {
  final CartItemModel item;
  final double? width;
  final double? height;
  final void Function(QuantityController)? onQuantityIncrement;
  final void Function(QuantityController)? onQuantityDecrement;
  final void Function(QuantityController)? onQuantityDelete;
  final double elevation;
  final bool includeQuantityControls;
  final bool onlyQuantity;
  final BorderRadius? borderRadius;

  CartItem({
    Key? key,
    required this.item,
    this.width,
    this.height,
    this.onQuantityIncrement,
    this.onQuantityDecrement,
    this.onQuantityDelete,
    this.borderRadius,
    this.elevation = 7,
    this.includeQuantityControls = true,
    this.onlyQuantity = false,
  }) : super(key: key);

  @override
  State<CartItem> createState() => _CartItemState();
}

class _CartItemState extends State<CartItem> {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (ctx, constraints) {
        double usedWidth = widget.width ?? constraints.maxWidth;
        double usedHeight = widget.height ?? constraints.maxHeight;

        return SizedBox(
          width: usedWidth,
          height: usedHeight,
          child: SimpleCard(
            elevation: widget.elevation,
            borderRadius: widget.borderRadius,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  height: usedHeight,
                  width: usedWidth * 0.4,
                  padding: const EdgeInsets.only(top: 5, bottom: 5, left: 8, right: 12),
                  child: buildPreviewImage(
                    widget.item.item.previewImage ?? noImageAvailable,
                    borderRadius: const BorderRadius.all(Radius.circular(50)),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: ItemDataSection(
                    itemModel: widget.item,
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
                        '\$${widget.item.item.price.toStringAsFixed(2)}',
                        style: Theme.of(context).textTheme.headline4!.copyWith(fontSize: 13.sp),
                      ),
                      const Spacer(),
                      if (widget.includeQuantityControls || widget.onlyQuantity)
                        ConstrainedBox(
                          constraints: BoxConstraints(maxWidth: constraints.maxWidth * 0.25, maxHeight: constraints.maxWidth * 0.25 / 3),
                          child: Quantity(
                            initialCount: widget.item.quantity,
                            color: Theme.of(context).primaryColor,
                            onDecrement: widget.onQuantityDecrement,
                            onIncrement: widget.onQuantityIncrement,
                            deletable: true,
                            onDelete: widget.onQuantityDelete,
                            onlyQuantity: widget.onlyQuantity,
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
}
