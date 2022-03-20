import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:meta/meta.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vivity/features/auth/auth_service.dart';
import 'package:vivity/features/auth/register_result.dart';

part 'auth_event.dart';

part 'auth_state.dart';

class AuthBloc extends HydratedBloc<AuthEvent, AuthState> {
  AuthBloc() : super(const AuthLoggedOutState()) {
    on<AuthLoginEvent>((event, emit) async {
      emit(AuthLoadingState());

      String? token;
      try {
        token = await login(event.email, event.password);
      } catch (e) {
        emit(const AuthLoggedOutState());
        rethrow;
      }
      print(token);
      if (token == null) {
        emit(const AuthLoggedOutState());
        return;
      }

      if (event.stayLoggedIn) {
        securelyStoreCredentials(event.email, event.password);
      }

      _setPreviouslyLoggedInFlag();
      emit(AuthLoggedInState(token: token));
    });

    on<AuthRegisterEvent>((event, emit) async {
      emit(AuthLoadingState());

      RegisterResult res;
      try {
        res = await register(event.email, event.password, event.name, event.phone);

        if (res.token == null) {
          emit(AuthRegisterFailedState(res.authResult!));
          return;
        }
      } catch (e) {
        emit(const AuthRegisterFailedState(AuthenticationResult.tokenInvalid));
        rethrow;
      }

      securelyStoreCredentials(event.email, event.password);
      _setPreviouslyLoggedInFlag();
      emit(AuthLoggedInState(token: res.token!));
    });

    on<AuthConfirmationEvent>((event, emit) async {
      if (!event.isSilentLogin) {
        emit(AuthLoadingState());
      }

      print("sending request");
      String? loginResult;
      try {
        loginResult = await state.verifyCredentials();
      } catch (e) {
        emit(const AuthLoggedOutState());
        rethrow;
      }

      print("Confirmation result: $loginResult");
      if (loginResult == null) {
        emit(const AuthLoggedOutState());
        return;
      }

      emit(AuthLoggedInState(token: loginResult));
    });

    on<AuthLogoutEvent>((event, emit) async {
      if (state is! AuthLoggedOutState) {
        eraseCredentialsFromStorage();
        emit(const AuthLoggedOutState());
      }
    });
  }

  @override
  AuthState? fromJson(Map<String, dynamic> json) {
    return AuthLoggedInState.fromMap(json);
  }

  @override
  Map<String, dynamic> toJson(AuthState state) {
    if (state is! AuthLoggedInState) {
      return {};
    }

    return state.toMap();
  }

  void _setPreviouslyLoggedInFlag() async {
    SharedPreferences shared = await SharedPreferences.getInstance();
    shared.setBool("previouslyLoggedIn", true);
  }
}
