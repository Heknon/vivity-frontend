import 'package:fade_in_widget/fade_in_widget.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import 'package:vivity/features/cart/bloc/cart_bloc.dart';
import 'package:vivity/features/checkout/bloc/checkout_bloc.dart';
import 'package:vivity/features/checkout/confirm_page.dart';
import 'package:vivity/helpers/ui_helpers.dart';
import 'package:vivity/models/shipping_method.dart';
import 'package:vivity/widgets/quantity.dart';
import '../item/cart_item.dart';

class CartView extends StatefulWidget {
  final ScrollController? scrollController;

  CartView({Key? key, this.scrollController}) : super(key: key) {}

  @override
  State<CartView> createState() => _CartViewState();
}

FadeInController controller = FadeInController();

class _CartViewState extends State<CartView> {
  double price = -1;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (ctx, constraints) {
        double itemsToFitInList = 2.7;
        double listPadding = 15;
        double itemsPadding = 25;
        Size listSize = Size(constraints.maxWidth * 0.9, constraints.maxHeight * 0.8);
        Size itemSize = Size(listSize.width * 0.95, (listSize.height) / itemsToFitInList);

        return Material(
          elevation: 7,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(15),
              bottomLeft: Radius.circular(15),
            ),
          ),
          clipBehavior: Clip.antiAlias,
          child: BlocConsumer<CartBloc, CartState>(
            buildWhen: (prev, curr) {
              return curr != prev;
            },
            listener: (ctx, CartState state) {
              if (state is! CartLoaded) return;

              if (price != state.total) {
                updateCost(state.total);
              }

              price = state.total;
            },
            builder: (context, CartState state) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: EdgeInsets.only(top: listPadding),
                    height: listSize.height,
                    width: listSize.width,
                    child: state is! CartLoaded
                        ? Align(
                            alignment: Alignment.center.add(Alignment(constraints.maxWidth / 4, 0)),
                            child: Text(
                              "There was an error loading the cart",
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.headline4?.copyWith(fontSize: 16.sp),
                            ),
                          )
                        : state.items.isEmpty
                            ? Align(
                                alignment: Alignment.center.add(Alignment(constraints.maxWidth / 4, 0)),
                                child: Text(
                                  "Start adding items to your cart!",
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context).textTheme.headline4?.copyWith(fontSize: 16.sp),
                                ),
                              )
                            : buildItemsList(itemsPadding, itemSize, state),
                  ),
                  Spacer(),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        buildCheckoutButton(context, state),
                        buildCheckoutCostInfo(state is! CartLoaded ? 0 : state.total),
                      ],
                    ),
                  )
                ],
              );
            },
          ),
        );
      },
    );
  }

  Widget buildItemsList(double itemsPadding, Size itemSize, CartLoaded state) {
    return ListView.builder(
      itemCount: state.items.length,
      controller: widget.scrollController,
      itemBuilder: (ctx, i) => Padding(
        padding: i != 0 ? EdgeInsets.only(top: itemsPadding) : const EdgeInsets.only(),
        child: Align(
          alignment: Alignment.centerLeft,
          child: CartItem(
            item: state.items[i],
            width: itemSize.width,
            height: itemSize.height,
            onQuantityIncrement: (qc) => onQuantityIncrement(qc, i),
            onQuantityDecrement: (qc) => onQuantityDecrement(qc, i),
            onQuantityDelete: (qc) => onDelete(qc, i),
            onlyQuantity: false,
          ),
        ),
      ),
    );
  }

  Padding buildCheckoutCostInfo(double priceTotal) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: 18.sp + 8, minHeight: 18.sp + 8),
        child: NotificationListener(
          onNotification: (SizeChangedLayoutNotification notification) {
            WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
              controller.swapCurrentWidget(
                Text(
                  'Total: \$' + priceTotal.toStringAsFixed(2),
                  style: GoogleFonts.raleway(fontSize: 18.sp),
                ),
              );
            });
            return true;
          },
          child: SizeChangedLayoutNotifier(
            child: FadeInWidget(
              duration: Duration(milliseconds: 500),
              controller: controller,
              initialWidget: Text(
                'Total: \$' + priceTotal.toStringAsFixed(2),
                style: GoogleFonts.raleway(fontSize: 18.sp),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Padding buildCheckoutButton(BuildContext context, CartState state) {
    return Padding(
      padding: EdgeInsets.only(left: 8),
      child: TextButton(
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all(Theme.of(context).colorScheme.primary),
          elevation: MaterialStateProperty.all(7),
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
          ),
          splashFactory: InkSplash.splashFactory,
        ),
        onPressed: () {
          context.read<CheckoutBloc>().add(
                CheckoutInitializeEvent(
                  items: state is! CartLoaded ? [] : state.items,
                  shippingMethod: state is! CartLoaded ? ShippingMethod.delivery : state.shippingMethod,
                  cuponCode: "",
                ),
              );
          Navigator.push(context, MaterialPageRoute(builder: (ctx) => ConfirmPage()));
        },
        child: Text(
          'Checkout',
          style: TextStyle(
            color: Colors.white,
            fontFamily: "Futura",
            fontSize: 18.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  void onQuantityIncrement(QuantityController quantityController, int index) {
    BlocProvider.of<CartBloc>(context).add(CartIncrementItemEvent(index));
  }

  void onQuantityDecrement(QuantityController quantityController, int index) {
    BlocProvider.of<CartBloc>(context).add(CartDecrementItemEvent(index));
  }

  void onDelete(QuantityController quantityController, index) {
    BlocProvider.of<CartBloc>(context).add(CartRemoveItemEvent(index));
    showSnackBar('Removing from cart...', context);
  }

  void updateCost(double priceTotal) {
    controller.gracefullySwapCurrentAnimatedWidget(
      Text(
        'Total: \$' + priceTotal.toStringAsFixed(2),
        style: GoogleFonts.raleway(fontSize: 18.sp),
      ),
    );
  }
}
