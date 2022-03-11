import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:meta/meta.dart';
import 'package:vivity/features/auth/auth_service.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends HydratedBloc<AuthEvent, AuthState> {
  AuthBloc() : super(const AuthState(loggedIn: false, previouslyLoggedIn: false, loginResult: null)) {
    on<AuthLoginEvent>((event, emit) async {
      String? token = await login(event.email, event.password);
      bool successLogin = token != null;

      if (successLogin) {
        securelyStoreCredentials(event.email, event.password);
      }

      emit(AuthState(loggedIn: successLogin, previouslyLoggedIn: state.previouslyLoggedIn || successLogin, loginResult: token));
    });

    on<AuthRegisterEvent>((event, emit) async {
      String? token = await login(event.email, event.password);
      bool successRegister = token != null;

      if (successRegister) {
        securelyStoreCredentials(event.email, event.password);
      }

      emit(AuthState(loggedIn: successRegister, previouslyLoggedIn: state.previouslyLoggedIn || successRegister, loginResult: token));
    });

    on<AuthConfirmationEvent>((event, emit) async {
      String? loginResult = await state.verifyCredentials();

      emit(AuthState(loggedIn: loginResult != null, previouslyLoggedIn: state.previouslyLoggedIn, loginResult: loginResult));
    });

    on<AuthUpdateEvent>((event, emit) async {
      emit(AuthState(loggedIn: event.token != null, previouslyLoggedIn: state.previouslyLoggedIn, loginResult: event.token));
    });

    //add(AuthConfirmationEvent());
  }

  @override
  AuthState? fromJson(Map<String, dynamic> json) {
    return AuthState.fromMap(json);
  }

  @override
  Map<String, dynamic> toJson(AuthState state) {
    return state.toMap();
  }
}
