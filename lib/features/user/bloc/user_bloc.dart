import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:meta/meta.dart';
import 'package:objectid/objectid/objectid.dart';
import 'package:vivity/features/cart/cart_service.dart';
import 'package:vivity/features/item/models/item_model.dart';
import 'package:vivity/features/user/models/user_options.dart';
import 'package:vivity/features/user/user_service.dart';
import 'package:vivity/services/api_service.dart';
import 'package:vivity/services/item_service.dart';
import '../models/address.dart';
import 'package:vivity/models/payment_method.dart';

import '../models/order.dart';
import '../models/order_item.dart';

part 'user_event.dart';
part 'user_state.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  UserBloc() : super(UserLoggedOutState()) {
    on<UserLoginEvent>((event, emit) async {
      UserLoggedInState state = UserLoggedInState(event.token);

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
  }
}
