import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:progress_bar/progress_bar.dart';
import 'package:sizer/sizer.dart';
import 'package:vivity/features/checkout/cupon.dart';
import 'package:vivity/features/checkout/shipping_page.dart';
import 'package:vivity/features/item/cart_item_list.dart';

import '../../config/themes/themes_config.dart';
import '../../widgets/appbar/appbar.dart';
import '../cart/cart_bloc/cart_bloc.dart';
import '../cart/cart_bloc/cart_state.dart';
import '../item/cart_item.dart';
import 'cart_totals.dart';
import 'checkout_progress.dart';

class ConfirmPage extends StatelessWidget {
  const ConfirmPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double itemsToFitInList = 2.7;
    Size listSize = Size(90.w, 35.h);
    Size itemSize = Size(listSize.width * 0.95, (listSize.height) / itemsToFitInList);

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: VivityAppBar(
        bottom: buildTitle(context),
      ),
      body: SingleChildScrollView(
        child: buildBody(context, itemSize, listSize),
      ),
    );
  }

  Column buildBody(BuildContext context, Size itemSize, Size listSize) {
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 15),
          child: CheckoutProgress(step: 0),
        ),
        const SizedBox(height: 10),
        CartItemList(
          listSize: listSize,
          itemsToFitInList: 2.4,
          emptyCartWidget: Center(
            child: Text(
              "Start adding items to your cart!",
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headline4?.copyWith(fontSize: 16.sp),
            ),
          ),
        ),
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
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (ctx) => ShippingPage()));
          },
        ),
        const SizedBox(height: 10),
      ],
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
}