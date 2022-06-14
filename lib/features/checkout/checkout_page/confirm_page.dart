import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:no_interaction_dialog/load_dialog.dart';
import 'package:sizer/sizer.dart';
import 'package:vivity/features/base_page.dart';
import 'package:vivity/features/checkout/checkout_page/bloc/checkout_confirm_bloc.dart';
import 'package:vivity/features/checkout/cupon.dart';
import 'package:vivity/features/item/cart_item_list.dart';
import 'package:vivity/helpers/ui_helpers.dart';

import '../../../widgets/appbar/appbar.dart';
import '../cart_totals.dart';
import '../checkout_progress.dart';

class ConfirmPage extends StatefulWidget {
  ConfirmPage({Key? key}) : super(key: key);

  @override
  State<ConfirmPage> createState() => _ConfirmPageState();
}

class _ConfirmPageState extends State<ConfirmPage> {
  final TextEditingController _cuponController = TextEditingController();
  late final CheckoutConfirmBloc _bloc;
  final FocusNode _cuponFocusNode = FocusNode();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _bloc = context.read<CheckoutConfirmBloc>();
  }

  @override
  Widget build(BuildContext context) {
    double itemsToFitInList = 2.7;
    Size listSize = Size(90.w, 35.h);
    Size itemSize = Size(listSize.width * 0.95, (listSize.height) / itemsToFitInList);

    return BasePage(
      resizeToAvoidBottomInset: true,
      appBar: VivityAppBar(
        bottom: buildTitle(context),
      ),
      body: SingleChildScrollView(
        child: buildBody(context, itemSize, listSize),
      ),
    );
  }

  Widget buildBody(BuildContext context, Size itemSize, Size listSize) {
    return BlocBuilder<CheckoutConfirmBloc, CheckoutConfirmState>(
      builder: (context, state) {
        if (state is! CheckoutConfirmLoaded) {
          return Center(child: const CircularProgressIndicator());
        }

        return Column(
          children: [
            const Padding(
              padding: EdgeInsets.only(top: 15),
              child: CheckoutProgress(step: 0),
            ),
            const SizedBox(height: 10),
            CartItemList(
              items: state.items,
              listSize: listSize,
              itemsToFitInList: 2.2,
              emptyCartWidget: Center(
                child: Text(
                  "Start adding items to your cart!",
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headline4?.copyWith(fontSize: 16.sp),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: itemSize.width,
                  child: Cupon(
                    cuponTextController: _cuponController,
                    focusNode: _cuponFocusNode,
                    onApplyClicked: () {
                      _cuponFocusNode.unfocus();
                      _bloc.add(CheckoutConfirmUpdateCuponEvent(_cuponController.text));
                    },
                  ),
                ),
                if (state.cuponDiscount > 0)
                  Padding(
                    padding: EdgeInsets.only(top: 8),
                    child: Text(
                      'Cupon applied: ${min(state.cuponDiscount * 100, 100)}% off',
                      style: Theme.of(context).textTheme.subtitle1,
                    ),
                  ),
              ],
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
                child: FutureBuilder<double>(
                    future: _bloc.calculateShipping(state),
                    builder: (context, snapshot) {
                      return CartTotals(
                        subtotal: state.subtotal,
                        shippingCost: snapshot.hasError || !snapshot.hasData ? 0 : snapshot.data!,
                        cuponDiscount: state.cuponDiscount,
                        deliveryCost: state.deliveryCost,
                        shippingMethod: state.shippingMethod,
                        onShippingChange: (method) => _bloc.add(CheckoutConfirmUpdateShippingEvent(method)),
                      );
                    }),
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
                if (state.items.isEmpty) {
                  showSnackBar('You must have items in your cart to proceed.', context);
                  return;
                }

                Navigator.pushNamed(context, '/checkout/shipping', arguments: _bloc);
              },
            ),
            const SizedBox(height: 10),
          ],
        );
      },
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
