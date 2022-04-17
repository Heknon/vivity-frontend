import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sizer/sizer.dart';
import 'package:vivity/features/base_page.dart';
import 'package:vivity/features/cart/models/cart_item_model.dart';
import 'package:vivity/features/checkout/shipping_page/bloc/shipping_bloc.dart';
import 'package:vivity/features/checkout/ui_checkout_helper.dart';
import '../../address/models/address.dart';
import 'package:vivity/models/shipping_method.dart';

import '../../../widgets/appbar/appbar.dart';
import '../../item/ui_item_helper.dart';
import '../checkout_progress.dart';

class PickupPage extends StatefulWidget {
  const PickupPage({Key? key}) : super(key: key);

  @override
  _PickupPageState createState() => _PickupPageState();
}

class _PickupPageState extends State<PickupPage> {
  final Set<int> selectedAddresses = {};

  @override
  Widget build(BuildContext context) {
    return BasePage(
      resizeToAvoidBottomInset: true,
      appBar: VivityAppBar(
        bottom: buildTitle(context, "Checkout"),
      ),
      body: BlocBuilder<ShippingBloc, ShippingState>(
        builder: (context, state) {
          if (state is! ShippingPickupLoaded) {
            return Center(child: CircularProgressIndicator());
          }

          Map<Address, List<CartItemModel>> swappedData = {};
          Map<Address, int> addressToIndex = {};
          for (var entry in state.addresses.entries) {
            if (swappedData.containsKey(entry.value)) {
              swappedData[entry.value]!.add(entry.key);
            } else {
              swappedData[entry.value] = List.of([entry.key]);
              addressToIndex[entry.value] = 0;
            }
          }

          return SingleChildScrollView(
            child: Column(
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 15),
                  child: CheckoutProgress(step: 1),
                ),
                SizedBox(height: 10),
                buildShippingAddressList(
                  swappedData.keys.toList(),
                  context,
                  onExpandTap: (i, isOpen) => state.confirmationStageState.shippingMethod == ShippingMethod.pickup
                      ? setState(() => selectedAddresses.contains(i) ? selectedAddresses.remove(i) : selectedAddresses.add(i))
                      : null,
                  expandedIndices: selectedAddresses,
                  expandedBuilder: (ctx, address) {
                    Size gridSize = Size(100.w, 30.h);
                    EdgeInsets padding = const EdgeInsets.all(8);
                    List<CartItemModel> models = state.addresses.keys.toList();
                    return buildCartItemList(
                      models,
                      gridSize,
                      context,
                      hasQuantity: false,
                      itemBorderRadius: BorderRadius.all(Radius.circular(8)),
                      itemPadding: padding,
                      elevation: 2,
                      includeQuantityControls: false,
                      itemSize: Size(gridSize.width * 0.7, ((gridSize.height) - (models.length - 1) * padding.bottom) / 2.2),
                    );
                  },
                ),
                SizedBox(height: 50),
                buildPaymentButton(
                  context,
                  onPressed: () {
                    Navigator.pushNamed(context, '/checkout/payment', arguments: [context.read<ShippingBloc>(), null]);
                  },
                ),
                SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );
  }
}
