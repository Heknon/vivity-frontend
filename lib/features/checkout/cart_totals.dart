import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:radio_button_list/radio_button_list.dart';
import 'package:sizer/sizer.dart';

import '../cart/cart_bloc/cart_bloc.dart';
import '../cart/cart_bloc/cart_state.dart';

class CartTotals extends StatefulWidget {
  const CartTotals({Key? key}) : super(key: key);

  @override
  State<CartTotals> createState() => _CartTotalsState();
}

class _CartTotalsState extends State<CartTotals> {
  late RadioButtonListController _radioController;

  @override
  void initState() {
    super.initState();
    _radioController = RadioButtonListController();

    _radioController.addListener(() {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    // TODO: Add dynamic shipping costs
    // TODO: Move shipping cost and whether selected to CART STATE BLOC
    int shippingCost = 12;

    return Material(
      color: Colors.white,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(5))),
      child: BlocBuilder<CartBloc, CartState>(
        builder: (context, state) => Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 15, left: 12),
                  child: Text(
                    'Subtotal -',
                    style: Theme.of(context).textTheme.headline4!.copyWith(fontSize: 13.sp, fontWeight: FontWeight.normal),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 15, right: 20),
                  child: Text(
                    "\$${state.priceTotal.toStringAsFixed(2)}",
                    style: Theme.of(context).textTheme.headline4!.copyWith(fontSize: 13.5.sp),
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            Divider(
              color: Theme.of(context).colorScheme.secondaryVariant,
              thickness: 1,
              indent: 25,
              endIndent: 25,
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.only(top: 15, left: 12),
                child: Text(
                  'Shipping - ',
                  style: Theme.of(context).textTheme.headline4!.copyWith(fontSize: 13.sp, fontWeight: FontWeight.normal),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 70),
              child: RadioButtonList(
                controller: _radioController,
                color: Theme.of(context).colorScheme.secondaryVariant,
                labels: [
                  RichText(
                    text: TextSpan(children: [
                      TextSpan(
                        text: 'Delivery: ',
                        style: Theme.of(context).textTheme.headline4!.copyWith(fontSize: 12.5.sp, fontWeight: FontWeight.normal),
                      ),
                      TextSpan(
                        text: "\$${shippingCost.toStringAsFixed(2)}",
                        style: Theme.of(context).textTheme.headline4!.copyWith(fontSize: 13.sp),
                      )
                    ]),
                  ),
                  RichText(
                    text: TextSpan(children: [
                      TextSpan(
                        text: 'Local pickup: ',
                        style: Theme.of(context).textTheme.headline4!.copyWith(fontSize: 12.5.sp, fontWeight: FontWeight.normal),
                      ),
                      TextSpan(
                        text: "FREE",
                        style: Theme.of(context).textTheme.headline4!.copyWith(fontSize: 13.sp),
                      )
                    ]),
                  )
                ],
              ),
            ),
            SizedBox(height: 10),
            Divider(
              color: Theme.of(context).colorScheme.secondaryVariant,
              thickness: 1,
              indent: 25,
              endIndent: 25,
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 12),
                  child: Text(
                    'Total -',
                    style: Theme.of(context).textTheme.headline4!.copyWith(fontSize: 13.sp, fontWeight: FontWeight.normal),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 20),
                  child: Text(
                    "\$${(state.priceTotal + (_radioController.selectedLabel == 0 ? shippingCost : 0)).toStringAsFixed(2)}",
                    style: Theme.of(context).textTheme.headline4!.copyWith(fontSize: 13.5.sp),
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
