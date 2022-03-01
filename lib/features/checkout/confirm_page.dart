import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:progress_bar/progress_bar.dart';
import 'package:sizer/sizer.dart';
import 'package:vivity/features/checkout/cupon.dart';

import '../../widgets/appbar/appbar.dart';
import '../cart/cart_bloc/cart_bloc.dart';
import '../cart/cart_bloc/cart_state.dart';
import '../item/cart_item/cart_item.dart';
import 'cart_totals.dart';

class ConfirmPage extends StatelessWidget {
  const ConfirmPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double itemsToFitInList = 2.7;
    Size listSize = Size(90.w, 35.h);
    Size itemSize = Size(listSize.width * 0.95, (listSize.height) / itemsToFitInList);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: VivityAppBar(
        bottom: buildTitle(context),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 15),
              child: buildProgressBar(context),
            ),
            const SizedBox(height: 10),
            BlocBuilder<CartBloc, CartState>(builder: (ctx, CartState state) {
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
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                ),
              );
              return SizedBox(
                width: listSize.width,
                height: listSize.height,
                child: ListView.separated(
                  padding: EdgeInsets.all(8),
                  itemCount: cartItems.length,
                  separatorBuilder: (ctx, i) => SizedBox(height: 10),
                  itemBuilder: (ctx, i) => cartItems[i],
                ),
              );
            }),
            const SizedBox(height: 20),
            SizedBox(
              width: itemSize.width,
              child: const Cupon(),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: listSize.width - 20,
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text('Cart totals', style: Theme.of(context).textTheme.headline3!.copyWith(fontSize: 15.sp)),
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: EdgeInsets.all(8),
              child: SizedBox(
                width: listSize.width - 20,
                child: CartTotals(),
              ),
            ),
            const SizedBox(height: 20),
            TextButton(
              style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Theme.of(context).colorScheme.secondaryVariant),
                  overlayColor: MaterialStateProperty.all(Colors.grey),
                  fixedSize: MaterialStateProperty.all(Size(listSize.width - 20, 15.sp * 3))),
              child: Text(
                'Proceed To Shipping',
                style: Theme.of(context).textTheme.headline4!.copyWith(fontSize: 20.sp, fontWeight: FontWeight.normal, color: Colors.white),
              ),
              onPressed: () {},
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  PreferredSize buildTitle(BuildContext context) {
    return PreferredSize(
      preferredSize: const Size(double.infinity, kToolbarHeight),
      child: Align(
        alignment: Alignment.topCenter,
        child: Container(
          color: Theme.of(context).colorScheme.primary,
          padding: EdgeInsets.only(bottom: 8),
          child: Text(
            "Checkout",
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.headline4?.copyWith(color: Colors.white, fontSize: 24.sp),
          ),
        ),
      ),
    );
  }

  Widget buildProgressBar(BuildContext context) {
    return ProgressBar(activeColor: const Color(0xffBA2435), inactiveColor: const Color(0xffE7C6CA), labelsActive: [
      Text(
        'Confirm',
        style: Theme.of(context).textTheme.headline3?.copyWith(color: Colors.black, fontSize: 12.sp),
      ),
      Text(
        'Shipping',
        style: Theme.of(context).textTheme.headline3?.copyWith(color: Colors.black, fontSize: 12.sp),
      ),
      Text(
        'Payment',
        style: Theme.of(context).textTheme.headline3?.copyWith(color: Colors.black, fontSize: 12.sp),
      ),
    ], labelsInactive: [
      Text(
        'Confirm',
        style: Theme.of(context).textTheme.headline3?.copyWith(color: Colors.grey, fontSize: 11.sp),
      ),
      Text(
        'Shipping',
        style: Theme.of(context).textTheme.headline3?.copyWith(color: Colors.grey, fontSize: 11.sp),
      ),
      Text(
        'Payment',
        style: Theme.of(context).textTheme.headline3?.copyWith(color: Colors.grey, fontSize: 11.sp),
      ),
    ]);
  }
}
