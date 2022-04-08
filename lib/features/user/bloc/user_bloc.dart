import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:async/async.dart';
import 'package:bloc/bloc.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:meta/meta.dart';
import 'package:objectid/objectid/objectid.dart';
import '../../../services/auth_service.dart';
import 'package:vivity/features/cart/cart_service.dart';
import 'package:vivity/features/item/models/item_model.dart';
import 'package:vivity/features/user/models/user_options.dart';
import 'package:vivity/features/user/user_service.dart';
import 'package:vivity/services/api_service.dart';
import 'package:vivity/services/business_service.dart' as business_service;
import 'package:vivity/services/item_service.dart';
import '../../../constants/api_path.dart';
import '../../../models/business.dart';
import '../../../models/address.dart';
import 'package:latlong2/latlong.dart';

import '../../../models/order.dart';
import '../../auth/auth_result.dart';

part 'user_event.dart';

part 'user_state.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  UserBloc() : super(UserLoggedOutState()) {
    on<UserLoginEvent>((event, emit) async {
      String accessToken = event.accessToken;
      JWT? jwt = parseAccessToken(accessToken);
      if (jwt == null) return emit(UserLoggedOutState());

      UserLoggedInState state = jwt.payload['business_id'] == null ? UserLoggedInState(accessToken) : BusinessUserLoggedInState(accessToken);

      String? result;
      try {
        emit(UserLoadingState());
        result = await state.init();
      } catch (e) {
        result = e.runtimeType.toString();
        emit(UserLoginFailedState(e.runtimeType.toString()));
        rethrow;
      }

      if (result != null) {
        emit(UserLoginFailedState(result));
        return;
      }

      emit(state);
    });

    on<UserLogoutEvent>((event, emit) {
      emit(UserLoggedOutState());
    });

    on<UserUpdateAddressesEvent>((event, emit) {
      if (state is! UserLoggedInState) return;
      emit((state as UserLoggedInState).copyWith(addresses: event.addresses));
    });

    on<UserRegisterBusinessEvent>((event, emit) async {
      if (state is! UserLoggedInState) return;
      BusinessUserLoggedInState? newState = await (state as UserLoggedInState).createBusiness(event);
      if (newState == null) return;
      emit(newState);
    });

    on<UserRenewTokenEvent>((event, emit) async {
      if (state is! UserLoggedInState) {
        return add(UserLoginEvent(event.accessToken));
      }

      UserState renewedState = (state as UserLoggedInState).copyWith(token: event.accessToken);

      emit(renewedState);
    });

    on<UserUpdateProfilePictureEvent>((event, emit) async {
      Response? response = await updateProfilePicture((state as UserLoggedInState).accessToken, event.picture);
      if (response == null) return;

      File? picture = await getProfilePicture((state as UserLoggedInState).accessToken);
      picture ??= File("");

      UserLoggedInState newState = (state as UserLoggedInState).copyWith(profilePicture: picture);
      emit(newState);
    });

    on<UserAddFavoriteEvent>((event, emit) async {
      List<ObjectId>? likedIds = (await addFavoriteItem((state as UserLoggedInState).accessToken, event.item.id))?.toList();
      if (likedIds == null) return;

      List<ItemModel> items = List.of((state as UserLoggedInState).likedItems);
      items.removeWhere((element) => element.id == event.item.id);
      items.add(event.item);
      UserLoggedInState newState = (state as UserLoggedInState).copyWith(likedItems: items);
      emit(newState);
    });

    on<UserRemoveFavoriteEvent>((event, emit) async {
      List<ObjectId>? likedIds = (await removeFavoriteItem((state as UserLoggedInState).accessToken, event.itemId))?.toList();
      if (likedIds == null) return;

      List<ItemModel> items = List.of((state as UserLoggedInState).likedItems);
      items.removeWhere((element) => element.id == event.itemId);
      UserLoggedInState newState = (state as UserLoggedInState).copyWith(likedItems: items);
      emit(newState);
    });

    on<BusinessUserFrontendUpdateItem>((event, emit) {
      if (state is! BusinessUserLoggedInState) return;

      Business business = (state as BusinessUserLoggedInState).business..updateItem(event.item);
      BusinessUserLoggedInState newState = (state as BusinessUserLoggedInState).copyWith(business: business);
      emit(newState);
    });

    on<BusinessUserFrontendUpdateOrder>((event, emit) {
      if (state is! BusinessUserLoggedInState) return;

      Business business = (state as BusinessUserLoggedInState).business..updateOrderStatus(event.order);
      BusinessUserLoggedInState newState = (state as BusinessUserLoggedInState).copyWith(business: business);
      emit(newState);
    });

    on<UpdateProfileData>((event, emit) async {
      if (state is! UserLoggedInState) return;

      UserLoggedInState prevState = state as UserLoggedInState;
      Map<String, dynamic>? mapUser = await getUserFromToken(prevState.accessToken);
      List<Address> addresses = UserLoggedInState.buildAddressesFromUserMap(prevState.accessToken, mapUser!['shipping_addresses']);
      List<Order> orderHistory = await UserLoggedInState.buildOrderHistoryFromUserMap(prevState.accessToken, mapUser['order_history'] ?? []);
      UserLoggedInState newState = (state as UserLoggedInState).copyWith(
        addresses: addresses,
        orderHistory: orderHistory,
      );
      emit(newState);
    });

    on<UpdateBusinessDataEvent>((event, emit) async {
      if (state is! BusinessUserLoggedInState) return;

      BusinessUserLoggedInState prevState = state as BusinessUserLoggedInState;
      Response businessData = await sendGetRequest(subRoute: businessRoute, token: prevState.accessToken);
      Business business = Business.fromMap(prevState.accessToken, businessData.data);
      BusinessUserLoggedInState newState = prevState.copyWith(business: business);
      emit(newState);
    });

    on<UserFrontendUpdate>((event, emit) {
      if (state is! UserLoggedInState) return;

      UserLoggedInState prevState = state as UserLoggedInState;
      UserLoggedInState newState = prevState.copyWith(userOptions: event.options, email: event.email, phone: event.phone);
      emit(newState);
    });
  }
}
