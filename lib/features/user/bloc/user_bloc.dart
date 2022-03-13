import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:vivity/features/item/models/item_model.dart';
import 'package:vivity/features/user/models/user_options.dart';
import 'package:vivity/features/user/user_service.dart';
import 'package:vivity/models/address.dart';
import 'package:vivity/models/payment_method.dart';

part 'user_event.dart';
part 'user_state.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  UserBloc() : super(UserLoggedOutState()) {
    on<UserLoginEvent>((event, emit) async {
      emit(UserLoggingInState());

      UserLoggedInState s = UserLoggedInState(event.token);
      String? result = await s.initUserState();
      if (result != null) {
        emit(UserLoginFailedState(result));
        return;
      }

      emit(s);
    });

    on<UserLogoutEvent>((event, emit) {
      emit(UserLoggedOutState());
    });
  }
}
