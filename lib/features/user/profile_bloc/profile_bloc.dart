import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:meta/meta.dart';
import 'package:vivity/features/address/models/address.dart';
import 'package:vivity/features/address/service/address_service.dart';
import 'package:vivity/features/business/models/order.dart';
import 'package:vivity/features/business/models/order_item.dart';
import 'package:vivity/features/item/models/item_model.dart';
import 'package:vivity/features/item/repo/item_repository.dart';
import 'package:vivity/features/user/models/user.dart';
import 'package:vivity/features/user/repo/user_repository.dart';

part 'profile_event.dart';

part 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  UserRepository _userRepository = UserRepository();
  ItemRepository _itemRepository = ItemRepository();
  AddressService _addressService = AddressService();

  ProfileBloc() : super(ProfileUnloaded()) {
    on<ProfileLoadEvent>((event, emit) async {
      emit(ProfileLoading());
      User user = await _userRepository.getUser(update: true);
      List<String> orderItemIds = List.empty(growable: true);
      for (Order order in user.orderHistory) {
        for (OrderItem orderItem in order.items) {
          if (orderItem.itemId == null) continue;

          orderItemIds.add(orderItem.itemId!.hexString);
        }
      }

      List<ItemModel?> itemsUnfiltered = await _itemRepository.getItemModelsFromId(itemIds: orderItemIds);
      List<ItemModel> items = List.empty(growable: true);
      for (ItemModel? item in itemsUnfiltered) {
        if (item == null) continue;
        items.add(item);
      }

      emit(ProfileLoaded(addresses: user.addresses, orderItems: items, orders: user.orderHistory));
    });

    on<ProfileAddAddressEvent>((event, emit) async {
      if (state is! ProfileLoaded) return;

      AsyncSnapshot<List<Address>> snapshot = await _addressService.addAddress(address: event.address);
      if (snapshot.hasError || !snapshot.hasData) {
        return;
      }

      ProfileLoaded newState = (state as ProfileLoaded).copyWith(addresses: snapshot.data!);

      emit(newState);
    });

    on<ProfileDeleteAddressEvent>((event, emit) async {
      if (state is! ProfileLoaded) return;

      AsyncSnapshot<List<Address>> snapshot = await _addressService.removeAddress(index: event.index);
      if (snapshot.hasError || !snapshot.hasData) {
        return;
      }

      ProfileLoaded newState = (state as ProfileLoaded).copyWith(addresses: snapshot.data!);

      emit(newState);
    });

    on<ProfileUnloadEvent>((event, emit) {
      emit(ProfileUnloaded());
    });
  }
}
