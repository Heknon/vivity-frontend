import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sizer/sizer.dart';
import 'package:vivity/features/checkout/checkout_progress.dart';
import 'package:vivity/features/checkout/payment_page.dart';
import 'package:vivity/models/payment_method.dart';
import 'package:vivity/models/shipping_method.dart';
import '../../models/address.dart';
import './shipping/address.dart' as address_widget;
import '../user/bloc/user_bloc.dart';
import 'bloc/checkout_bloc.dart';
import 'shipping/add_address.dart';

import '../../widgets/appbar/appbar.dart';
import '../item/cart_item.dart';

class ShippingPage extends StatefulWidget {
  @override
  State<ShippingPage> createState() => _ShippingPageState();
}

class _ShippingPageState extends State<ShippingPage> {
  int? selectedAddress;

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
        child: BlocConsumer<CheckoutBloc, CheckoutState>(
          listener: (context, state) {
            if (state is CheckoutStatePaymentStage) {
              Navigator.of(context).push(MaterialPageRoute(builder: (ctx) => PaymentPage()));
            }
          },
          builder: (context, checkoutState) {
            if (checkoutState is! CheckoutStateConfirmationStage) {
              return const CircularProgressIndicator();
            }

            return Column(
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 15),
                  child: CheckoutProgress(step: 1),
                ),
                BlocBuilder<UserBloc, UserState>(
                  builder: (ctx, state) {
                    if (state is! UserLoggedInState) {
                      return Text(
                        "You must be logged in to have addresses",
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.headline4?.copyWith(fontSize: 16.sp),
                      );
                    }

                    return ListView.builder(
                      itemCount: state.addresses.length,
                      itemBuilder: (ctx, i) {
                        Address curr = state.addresses[i];
                        address_widget.Address widget = address_widget.Address(
                          name: curr.name,
                          country: curr.country,
                          city: curr.city,
                          street: curr.street,
                          houseNumber: curr.houseNumber,
                          zipCode: curr.zipCode,
                          phone: curr.phone,
                        );

                        return (checkoutState).shippingMethod == ShippingMethod.pickup
                            ? widget
                            : GestureDetector(
                                onTap: () => setState(() {
                                  selectedAddress = i;
                                }),
                                child: selectedAddress == i
                                    ? Container(
                                        color: Colors.red,
                                        child: widget,
                                      )
                                    : widget,
                              );
                      },
                    );
                  },
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
                      backgroundColor: MaterialStateProperty.all(
                        Theme.of(context).colorScheme.secondaryVariant,
                      ),
                      overlayColor: MaterialStateProperty.all(Colors.grey),
                      fixedSize: MaterialStateProperty.all(Size(90.w, 15.sp * 3))),
                  child: Text(
                    'Proceed To Payment',
                    style: Theme.of(context).textTheme.headline4!.copyWith(fontSize: 20.sp, fontWeight: FontWeight.normal, color: Colors.white),
                  ),
                  onPressed: () {
                    context.read<CheckoutBloc>().add(
                          CheckoutApplyShippingEvent(
                              address:
                                  selectedAddress != null ? (context.read<UserBloc>().state as UserLoggedInState).addresses[selectedAddress!] : null),
                        );
                    context.read<CheckoutBloc>().add(
                      CheckoutSelectPaymentEvent(paymentMethod: null),
                    );
                  },
                ),
                SizedBox(height: 20),
              ],
            );
          },
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

    return AlertDialog();
  }
}
