import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sizer/sizer.dart';
import 'package:vivity/config/themes/themes_config.dart';
import 'package:vivity/features/base_page.dart';
import 'package:vivity/features/checkout/checkout_progress.dart';
import 'package:vivity/features/checkout/payment_page.dart';
import 'package:vivity/features/checkout/ui_checkout_helper.dart';
import 'package:vivity/models/payment_method.dart';
import 'package:vivity/models/shipping_method.dart';
import '../shipping/add_address.dart';
import '../../models/address.dart';
import '../shipping/address.dart' as address_widget;
import '../user/bloc/user_bloc.dart';
import 'bloc/checkout_bloc.dart';

import '../../widgets/appbar/appbar.dart';
import '../item/cart_item.dart';

class ShippingPage extends StatefulWidget {
  const ShippingPage({Key? key}) : super(key: key);

  @override
  State<ShippingPage> createState() => _ShippingPageState();
}

class _ShippingPageState extends State<ShippingPage> {
  int? selectedAddress;

  @override
  Widget build(BuildContext context) {
    // TODO: Add switch between business pickup and user to house shipping
    // TODO: Address creation menu

    return BasePage(
      resizeToAvoidBottomInset: true,
      appBar: VivityAppBar(
        bottom: buildTitle(context, "Checkout"),
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
                        onTap: (i) => checkoutState.shippingMethod == ShippingMethod.delivery
                            ? setState(() => selectedAddress = selectedAddress == i ? null : i)
                            : null,
                        canDelete: false,
                      ),
                    );
                  },
                ),
                SizedBox(height: 20),
                if (checkoutState.shippingMethod != ShippingMethod.pickup) buildAddressCreationWidget(context),
                SizedBox(height: 50),
                buildPaymentButton(context, onPressed: () {
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
                }),
                SizedBox(height: 20),
              ],
            );
          },
        ),
      ),
    );
  }
}
