import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sizer/sizer.dart';
import 'package:vivity/config/themes/themes_config.dart';
import 'package:vivity/features/checkout/checkout_progress.dart';
import 'package:vivity/features/checkout/payment_page.dart';
import 'package:vivity/features/checkout/ui_checkout_helper.dart';
import 'package:vivity/models/payment_method.dart';
import 'package:vivity/models/shipping_method.dart';
import '../shipping/add_address.dart';
import '../user/models/address.dart';
import '../shipping/address.dart' as address_widget;
import '../user/bloc/user_bloc.dart';
import 'bloc/checkout_bloc.dart';

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
              Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (ctx) => PaymentPage()));
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
                SizedBox(height: 5),
                BlocBuilder<UserBloc, UserState>(
                  builder: (ctx, state) {
                    if (state is! UserLoggedInState) {
                      return Text(
                        "You must be logged in to have addresses",
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.headline4?.copyWith(fontSize: 16.sp),
                      );
                    }

                    return SizedBox(
                        height: 30.h,
                        child: buildShippingAddressList(
                          state.addresses,
                          context,
                          token: state.token,
                          highlightIndex: selectedAddress,
                          onTap: (i) => checkoutState.shippingMethod == ShippingMethod.pickup
                              ? null
                              : setState(() {
                                  if (selectedAddress == i) {
                                    selectedAddress = null;
                                    return;
                                  }
                                  selectedAddress = i;
                                }),
                        ));
                  },
                ),
                SizedBox(height: 20),
                buildAddressCreationWidget(context),
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
                    if (selectedAddress == null) {
                      ScaffoldMessenger.of(context).clearSnackBars();
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please select an address")));
                      return;
                    }

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
