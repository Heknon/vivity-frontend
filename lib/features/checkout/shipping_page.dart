import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:progress_bar/progress_bar.dart';
import 'package:sizer/sizer.dart';
import 'package:vivity/features/checkout/checkout_progress.dart';
import 'package:vivity/features/checkout/payment_page.dart';
import 'package:vivity/features/item/cart_item_list.dart';
import 'shipping/add_address.dart';

import '../../widgets/appbar/appbar.dart';
import 'shipping/address.dart';
import '../item/cart_item.dart';

class ShippingPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // TODO: Add switch between business pickup and user to house shipping
    // TODO: Address creation menu

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: VivityAppBar(
        bottom: buildTitle(context),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.only(top: 15),
              child: CheckoutProgress(step: 1),
            ),
            Address( // TODO: Swap to ListView
              name: "Ori Harel",
              city: "Kochav Yair, HaMerkaz",
              country: "Israel",
              houseNumber: "24",
              phone: "+972585551784",
              street: "HaHar",
              zipCode: "4486400",
            ),
            SizedBox(height: 50),
            GestureDetector(
              onTap: () => showDialog(context: context, builder: (ctx) => AddAddress()),
              child: Container(
                width: 250,
                height: 120,
                decoration: BoxDecoration(
                  border: Border.all(color: Theme.of(context).colorScheme.secondaryVariant, width: 1.5),
                  borderRadius: const BorderRadius.all(Radius.circular(7)),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.add,
                      size: 50.sp,
                    ),
                    Text(
                      'Add New Address',
                      style: Theme.of(context).textTheme.headline4!.copyWith(fontSize: 12.sp, fontWeight: FontWeight.normal, color: Colors.black),
                    )
                  ],
                ),
              ),
            ),
            SizedBox(height: 50),
            TextButton(
              style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Theme.of(context).colorScheme.secondaryVariant),
                  overlayColor: MaterialStateProperty.all(Colors.grey),
                  fixedSize: MaterialStateProperty.all(Size(90.w, 15.sp * 3))),
              child: Text(
                'Proceed To Payment',
                style: Theme.of(context).textTheme.headline4!.copyWith(fontSize: 20.sp, fontWeight: FontWeight.normal, color: Colors.white),
              ),
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(builder: (ctx) => PaymentPage()));
              },
            ),
            SizedBox(height: 20),
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

  Widget? buildItemsDialog(List<CartItem> items) {
    if (items.isEmpty) return null;

    // TODO: Dropdown menu instead when clicking a business address to show all items to pickup from business.

    return AlertDialog(

    );
  }
}
