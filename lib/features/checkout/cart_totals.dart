import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:radio_button_list/radio_button_list.dart';
import 'package:sizer/sizer.dart';
import 'package:vivity/models/shipping_method.dart';

class CartTotals extends StatelessWidget {
  final double cuponDiscount;
  final double shippingCost;
  final double deliveryCost;
  final double subtotal;
  final ShippingMethod shippingMethod;

  final void Function(ShippingMethod)? onShippingChange;

  final RadioButtonListController? radioController;

  const CartTotals({
    Key? key,
    required this.subtotal,
    required this.shippingCost,
    required this.cuponDiscount,
    required this.deliveryCost,
    required this.shippingMethod,
    this.onShippingChange,
    this.radioController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(5))),
      child: Column(
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
                  "\$${subtotal.toStringAsFixed(2)}",
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
              controller: radioController,
              initialSelection: shippingMethod.index,
              color: Theme.of(context).colorScheme.secondaryVariant,
              onChange: (index) => onShippingChange != null ? onShippingChange!(ShippingMethod.values[index]) : null,
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
                  "\$${(subtotal + deliveryCost - cuponDiscount).toStringAsFixed(2)}",
                  style: Theme.of(context).textTheme.headline4!.copyWith(fontSize: 13.5.sp),
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
        ],
      ),
    );
  }
}
