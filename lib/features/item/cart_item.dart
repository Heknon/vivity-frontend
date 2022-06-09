import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:sizer/sizer.dart';
import 'package:vivity/constants/asset_path.dart';
import 'package:vivity/features/cart/models/cart_item_model.dart';
import 'package:vivity/features/item/ui_item_helper.dart';
import 'package:vivity/models/navigation_models.dart';
import 'package:vivity/widgets/quantity.dart';
import 'package:vivity/widgets/simple_card.dart';

import '../../config/routes/routes_config.dart';
import 'item_data_section.dart';

class CartItem extends StatelessWidget {
  final CartItemModel item;
  final double? width;
  final double? height;
  final void Function(QuantityController)? onQuantityIncrement;
  final void Function(QuantityController)? onQuantityDecrement;
  final void Function(QuantityController)? onQuantityDelete;
  final QuantityController? quantityController;
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
    this.quantityController,
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
            onTap: () {
              ModalRoute<Object?>? modalRoute = ModalRoute.of(context);
              NavigatorState nav = Navigator.of(context);

              var arguments = modalRoute?.settings.arguments;
              var name = modalRoute?.settings.name;
              if (name == "/item") {
                nav.pushReplacementNamed("/item", arguments: ItemPageNavigation(item: item.item));
                return;
              } else if (arguments is ItemPageNavigation && arguments.item == item.item) return;
              nav.pushNamed("/item", arguments: ItemPageNavigation(item: item.item));
            },
            elevation: elevation,
            borderRadius: borderRadius,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  height: usedHeight,
                  width: usedWidth * 0.4,
                  padding: const EdgeInsets.only(top: 5, bottom: 5, left: 8, right: 12),
                  child: buildPreviewImage(
                    item.item.previewImage ?? noImageAvailable,
                    borderRadius: const BorderRadius.all(Radius.circular(50)),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: ItemDataSection(
                    itemModel: item,
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
                        '\$${item.item.price.toStringAsFixed(2)}',
                        style: Theme.of(context).textTheme.headline4!.copyWith(fontSize: 13.sp),
                      ),
                      const Spacer(),
                      if (includeQuantityControls || onlyQuantity)
                        ConstrainedBox(
                          constraints: BoxConstraints(maxWidth: constraints.maxWidth * 0.25, maxHeight: constraints.maxWidth * 0.25 / 3),
                          child: Quantity(
                            color: Theme.of(context).primaryColor,
                            onDecrement: onQuantityDecrement,
                            onIncrement: onQuantityIncrement,
                            deletable: true,
                            onDelete: onQuantityDelete,
                            onlyQuantity: onlyQuantity,
                            controller: quantityController,
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
