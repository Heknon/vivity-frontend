import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sizer/sizer.dart';
import 'package:vivity/features/cart/cart_bloc/cart_bloc.dart';

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

      List<CartItem> cartItems = List.generate(
        state.items.length,
        (i) => CartItem(
          itemModel: state.items[i],
          width: itemSize.width,
          height: itemSize.height,
          onQuantityIncrement: (_, id) => BlocProvider.of<CartBloc>(context).add(CartIncrementItemEvent(id!)),
          onQuantityDecrement: (_, id) => BlocProvider.of<CartBloc>(context).add(CartDecrementItemEvent(id!)),
          quantityController: state.getItemQuantityController(state.items[i].insertionId),
          id: state.items[i].insertionId,
          borderRadius: itemBorderRadius,
        ),
      );
      return SizedBox(
        width: listSize.width,
        height: state.items.length < 2 ? listSize.height / 3 : state.items.length < 3 ? listSize.height / 1.5 : listSize.height,
        child: state.items.isNotEmpty
            ? ListView.separated(
                padding: itemPadding.add(EdgeInsets.only(bottom: 6)),
                itemCount: cartItems.length,
                separatorBuilder: (ctx, i) => SizedBox(height: itemPadding.bottom),
                itemBuilder: (ctx, i) => cartItems[i],
              )
            : emptyCartWidget,
      );
    });
  }
}
