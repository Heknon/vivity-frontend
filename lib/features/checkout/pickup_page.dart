import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geocoding/geocoding.dart';
import 'package:sizer/sizer.dart';
import 'package:vivity/features/base_page.dart';
import 'package:vivity/features/checkout/payment_page.dart';
import 'package:vivity/features/checkout/shipping_page.dart';
import 'package:vivity/features/checkout/ui_checkout_helper.dart';
import 'package:vivity/features/item/cart_item.dart';
import '../../models/address.dart';
import 'package:vivity/models/shipping_method.dart';

import '../../widgets/appbar/appbar.dart';
import '../item/models/item_model.dart';
import '../item/ui_item_helper.dart';
import '../user/bloc/user_bloc.dart';
import 'bloc/checkout_bloc.dart';
import 'checkout_progress.dart';
import 'package:latlong2/latlong.dart';

class PickupPage extends StatefulWidget {
  const PickupPage({Key? key}) : super(key: key);

  @override
  _PickupPageState createState() => _PickupPageState();
}

class _PickupPageState extends State<PickupPage> {
  Future<Map<CartItemModel, Address>>? addresses;
  Set<int> selectedAddresses = {};

  @override
  void initState() {
    super.initState();
    addresses = null;
  }

  @override
  Widget build(BuildContext context) {
    return BasePage(
      resizeToAvoidBottomInset: true,
      appBar: VivityAppBar(
        bottom: buildTitle(context, "Checkout"),
      ),
      body: BlocConsumer<CheckoutBloc, CheckoutState>(listener: (context, state) {
        if (state is CheckoutStatePaymentStage) {
          Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (ctx) => PaymentPage()));
        }
      }, builder: (context, checkoutState) {
        if (checkoutState is! CheckoutStateConfirmationStage) {
          return const CircularProgressIndicator();
        }
        addresses ??= getAddresses(checkoutState, getPlaces(checkoutState));

        return SingleChildScrollView(
          child: Column(
            children: [
              const Padding(
                padding: EdgeInsets.only(top: 15),
                child: CheckoutProgress(step: 1),
              ),
              SizedBox(height: 10),
              BlocBuilder<UserBloc, UserState>(builder: (ctx, state) {
                if (state is! UserLoggedInState) {
                  return Text(
                    "You must be logged in to have addresses",
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headline4?.copyWith(fontSize: 16.sp),
                  );
                }

                return SizedBox(
                  child: FutureBuilder(
                    future: addresses,
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return CircularProgressIndicator();
                      }

                      Map<CartItemModel, Address> data = snapshot.data as Map<CartItemModel, Address>;
                      Map<Address, List<CartItemModel>> swappedData = {};
                      Map<Address, int> addressToIndex = {};
                      for (var entry in data.entries) {
                        if (swappedData.containsKey(entry.value)) {
                          swappedData[entry.value]!.add(entry.key);
                        } else {
                          swappedData[entry.value] = List.of([entry.key]);
                          addressToIndex[entry.value] = 0;
                        }
                      }

                      return buildShippingAddressList(
                        swappedData.keys.toList(),
                        context,
                        token: state.token,
                        onExpandTap: (i, isOpen) => checkoutState.shippingMethod == ShippingMethod.pickup
                            ? setState(() => selectedAddresses.contains(i) ? selectedAddresses.remove(i) : selectedAddresses.add(i))
                            : null,
                        canDelete: false,
                        expandedIndices: selectedAddresses,
                        expandedBuilder: (ctx, address) {
                          Size gridSize = Size(100.w, 30.h);
                          EdgeInsets padding = const EdgeInsets.all(8);
                          List<CartItemModel> models = data.keys.toList();
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
                      );
                    },
                  ),
                );
              }),
              SizedBox(height: 50),
              buildPaymentButton(context, onPressed: () {
                context.read<CheckoutBloc>().add(
                      CheckoutSelectPaymentEvent(paymentMethod: null),
                    );
              }),
              SizedBox(height: 20),
            ],
          ),
        );
      }),
    );
  }

  Future<Map<CartItemModel, Address>> getAddresses(CheckoutStateConfirmationStage state, Future<Map<LatLng, Placemark>> geoPlaces) async {
    Map<LatLng, Placemark> places = await geoPlaces;
    Map<LatLng, List<CartItemModel>> locToItem = {};
    for (var element in state.items) {
      if (locToItem.containsKey(element.item.location)) {
        locToItem[element.item.location]!.add(element);
        continue;
      }

      locToItem[element.item.location] = List.of([element]);
    }

    Map<CartItemModel, Address> result = {};

    for (var locItemsEntry in locToItem.entries) {
      for (var cartItem in locItemsEntry.value) {
        Placemark mark = places[cartItem.item.location]!;
        result[cartItem] = Address(
          name: int.tryParse(mark.name ?? "f") != null ? null : mark.name,
          street: mark.street ?? "",
          country: mark.isoCountryCode ?? "",
          city: mark.locality ?? "",
          province: mark.administrativeArea ?? "",
        );
      }
    }

    return result;
  }

  Future<Map<LatLng, Placemark>> getPlaces(CheckoutStateConfirmationStage state) async {
    Map<LatLng, Future<List<Placemark>>> resultFuture = {};

    for (var item in state.items) {
      resultFuture[item.item.location] = placemarkFromCoordinates(item.item.location.latitude, item.item.location.longitude);
    }

    List<Future<List<Placemark>>> futures = resultFuture.values.toList();
    await Future.wait(futures);

    Map<LatLng, Placemark> result = {};
    for (var entry in resultFuture.entries) {
      result[entry.key] = (await entry.value)[0];
    }

    return result;
  }
}
