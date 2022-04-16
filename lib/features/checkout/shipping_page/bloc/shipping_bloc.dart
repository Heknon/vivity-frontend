import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:geocoding/geocoding.dart';
import 'package:meta/meta.dart';
import 'package:place_picker/place_picker.dart';
import 'package:vivity/features/address/models/address.dart';
import 'package:vivity/features/cart/models/cart_item_model.dart';
import 'package:vivity/features/checkout/checkout_page/bloc/checkout_confirm_bloc.dart';
import 'package:vivity/features/item/cart_item.dart';
import 'package:vivity/features/user/models/user.dart';
import 'package:vivity/features/user/repo/user_repository.dart';
import 'package:latlng/latlng.dart' as latlng;
import 'package:vivity/models/shipping_method.dart';

part 'shipping_event.dart';

part 'shipping_state.dart';

class ShippingBloc extends Bloc<ShippingEvent, ShippingState> {
  final UserRepository _userRepository = UserRepository();

  ShippingBloc() : super(ShippingUnloaded()) {
    on<ShippingLoadEvent>((event, emit) async {
      emit(ShippingLoading());
      CheckoutConfirmBloc bloc = event.confirmationStageBloc;
      CheckoutConfirmState confirmationStageState = bloc.state;
      if (confirmationStageState is! CheckoutConfirmLoaded) throw Exception('Must confirm cart to confirm delivery');

      bloc.stream.listen((confirmationState) {
        if (confirmationState is CheckoutConfirmUnloaded && confirmationState is! CheckoutConfirmLoading) {
          return emit(ShippingUnloaded());
        }

        if (confirmationState is! CheckoutConfirmLoaded || state is! ShippingLoaded) return;

        ShippingLoaded s = (state as ShippingLoaded).copyWith(confirmationStageState: confirmationState);
        emit(s);
      });

      if (confirmationStageState.shippingMethod == ShippingMethod.delivery) {
        User user = await _userRepository.getUser();
        emit(ShippingDeliveryLoaded(confirmationStageState: confirmationStageState, addresses: user.addresses));
      } else {
        Map<CartItemModel, Address> addresses = await getAddresses(confirmationStageState.items, await getPlaces(confirmationStageState.items));
        emit(ShippingPickupLoaded(confirmationStageState: confirmationStageState, addresses: addresses));
      }
    });
  }

  Future<Map<CartItemModel, Address>> getAddresses(List<CartItemModel> items, Map<LatLng, Placemark> geoPlaces) async {
    Map<LatLng, Placemark> places = await geoPlaces;
    Map<LatLng, List<CartItemModel>> locToItem = {};

    for (var element in items) {
      LatLng loc = LatLng(element.item.location.latitude, element.item.location.longitude);
      if (locToItem.containsKey(loc)) {
        locToItem[loc]!.add(element);
        continue;
      }

      locToItem[loc] = List.of([element]);
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

  Future<Map<LatLng, Placemark>> getPlaces(List<CartItemModel> items) async {
    Map<LatLng, Future<List<Placemark>>> resultFuture = {};

    for (var item in items) {
      LatLng loc = LatLng(item.item.location.latitude, item.item.location.longitude);
      resultFuture[loc] = placemarkFromCoordinates(loc.latitude, loc.longitude);
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
