import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vivity/features/cart/bloc/cart_bloc.dart';
import 'package:vivity/features/cart/models/cart_item_model.dart';
import 'package:vivity/features/item/ui_item_helper.dart';
import 'package:vivity/helpers/ui_helpers.dart';

import '../../widgets/quantity.dart';

class CartItemList extends StatelessWidget {
  final List<CartItemModel> items;
  final Size listSize;
  final double itemsToFitInList;
  final double listWidthItemWidthRatio;
  final EdgeInsets itemPadding;
  final BorderRadius itemBorderRadius;
  final Widget? emptyCartWidget;

  const CartItemList({
    Key? key,
    required this.items,
    required this.listSize,
    required this.itemsToFitInList,
    this.listWidthItemWidthRatio = 0.95,
    this.itemPadding = const EdgeInsets.all(8),
    this.itemBorderRadius = const BorderRadius.all(Radius.circular(8)),
    this.emptyCartWidget,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Size itemSize =
        Size(listSize.width * listWidthItemWidthRatio, ((listSize.height) - (items.length - 1) * itemPadding.bottom) / itemsToFitInList);

    return buildCartItemList(
      items,
      listSize,
      context,
      onQuantityDelete: (controller, index) => onDelete(controller, items[index].hashCode, context),
      quantityController: (ctx, item) => (BlocProvider.of<CartBloc>(context).state as CartLoaded).getQuantityController(item),
      emptyCart: emptyCartWidget,
      hasQuantity: true,
      itemBorderRadius: itemBorderRadius,
      itemPadding: itemPadding,
      itemSize: itemSize,
    );
  }

  void onDelete(QuantityController quantityController, int index, BuildContext context) {
    BlocProvider.of<CartBloc>(context).add(CartRemoveItemEvent(index));
    showSnackBar('Removing from cart...', context);
  }
}
