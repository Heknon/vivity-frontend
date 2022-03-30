import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sizer/sizer.dart';
import 'package:vivity/features/cart/cart_bloc/cart_bloc.dart';
import 'package:vivity/features/item/ui_item_helper.dart';

import '../../widgets/quantity.dart';
import '../cart/cart_bloc/cart_state.dart';
import 'cart_item.dart';

class CartItemList extends StatelessWidget {
  final Size listSize;
  final double itemsToFitInList;
  final double listWidthItemWidthRatio;
  final EdgeInsets itemPadding;
  final BorderRadius itemBorderRadius;
  final Widget? emptyCartWidget;

  const CartItemList({
    Key? key,
    required this.listSize,
    required this.itemsToFitInList,
    this.listWidthItemWidthRatio = 0.95,
    this.itemPadding = const EdgeInsets.all(8),
    this.itemBorderRadius = const BorderRadius.all(Radius.circular(8)),
    this.emptyCartWidget,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CartBloc, CartState>(builder: (ctx, CartState state) {
      Size itemSize =
          Size(listSize.width * listWidthItemWidthRatio, ((listSize.height) - (state.items.length - 1) * itemPadding.bottom) / itemsToFitInList);

      return buildCartItemList(
        state.items,
        listSize,
        context,
        onQuantityDelete: (controller, id) => onDelete(controller, id, context),
        emptyCart: emptyCartWidget,
        quantityController: (i) => state.getItemQuantityController(state.items[i].insertionId),
        hasQuantity: true,
        itemBorderRadius: itemBorderRadius,
        itemPadding: itemPadding,
        itemSize: itemSize
      );
    });
  }

  void onDelete(QuantityController quantityController, int? id, BuildContext context) {
    BlocProvider.of<CartBloc>(context).add(CartDeleteItemEvent(id!));
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Deleting item')));
  }
}
