import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sizer/sizer.dart';
import 'package:vivity/features/base_page.dart';
import 'package:vivity/features/checkout/checkout_progress.dart';
import 'package:vivity/features/checkout/payment_page/payment_page.dart';
import 'package:vivity/features/checkout/shipping_page/bloc/shipping_bloc.dart';
import 'package:vivity/features/checkout/ui_checkout_helper.dart';
import 'package:vivity/helpers/ui_helpers.dart';
import 'package:vivity/models/shipping_method.dart';
import '../../address/address.dart' as address_widget;

import '../../../widgets/appbar/appbar.dart';

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
        child: BlocBuilder<ShippingBloc, ShippingState>(
          builder: (context, state) {
            if (state is! ShippingDeliveryLoaded) {
              return const CircularProgressIndicator();
            }

            return Column(
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 15),
                  child: CheckoutProgress(step: 1),
                ),
                SizedBox(height: 5),
                SizedBox(
                  height: state.addresses.length > 1 ? 30.h : (state.addresses.length * 15).h,
                  child: buildShippingAddressList(
                    state.addresses,
                    context,
                    highlightIndex: selectedAddress,
                    onTap: (i) => state.confirmationStageState.shippingMethod == ShippingMethod.delivery
                        ? setState(() => selectedAddress = selectedAddress == i ? null : i)
                        : null,
                  ),
                ),
                SizedBox(height: 20),
                if (state.confirmationStageState.shippingMethod != ShippingMethod.pickup) buildAddressCreationWidget(context: context),
                SizedBox(height: 50),
                buildPaymentButton(
                  context,
                  onPressed: () {
                    if (selectedAddress == null) {
                      showSnackBar("Please select an address", context);
                      return;
                    }

                    Navigator.pushNamed(context, '/checkout/payment', arguments: state);
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
}
