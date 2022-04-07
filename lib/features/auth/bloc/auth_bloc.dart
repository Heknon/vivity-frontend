import 'dart:async';

import 'package:async/async.dart';
import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:meta/meta.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vivity/features/user/bloc/user_bloc.dart';
import '../../../services/auth_service.dart';
import 'package:vivity/features/auth/register_result.dart';

import '../auth_result.dart';

part 'auth_event.dart';

part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  late final RestartableTimer _renewTokenTimer = RestartableTimer(const Duration(minutes: 5), tokenRenewalRoutine);

  AuthBloc() : super(AuthLoggedOutState()) {
    on<AuthLoginEvent>((event, emit) async {
      emit(AuthLoadingState());

      RegisterResult? authResult;
      try {
        authResult = await login(event.email, event.password, event.otp, event.onFail);
      } catch (e) {
        if (event.onFail != null) event.onFail!(null);
        emit(AuthLoggedOutState());
        rethrow;
      }

      if (authResult == null || authResult.authStatus != AuthenticationResult.success) {
        if (event.onFail != null) event.onFail!(null);
        emit(AuthLoggedOutState(status: authResult?.authStatus ?? AuthenticationResult.passwordIncorrect));
        return;
      }

      if (event.stayLoggedIn) {
        securelyStoreCredentials(authResult.authResult!.refreshToken);
      }

      _setPreviouslyLoggedInFlag();
      emit(AuthLoggedInState(authResult: authResult.authResult!));
      _renewTokenTimer.reset();
    });

    on<AuthHandlePre2FA>((event, emit) async {
      emit(AuthLoadingState());

      RegisterResult? authResult;

      if (authResult == null || authResult.authStatus != AuthenticationResult.success) {
        emit(AuthLoggedOutState(status: authResult?.authStatus ?? AuthenticationResult.passwordIncorrect));
        return;
      }
    });

    on<AuthRegisterEvent>((event, emit) async {
      emit(AuthLoadingState());

      RegisterResult res;
      try {
        res = await register(event.email, event.password, event.name, event.phone);

        if (res.authResult == null) {
          emit(AuthRegisterFailedState(res.authStatus!));
          return;
        }
      } catch (e) {
        emit(AuthRegisterFailedState(AuthenticationResult.tokenInvalid));
        rethrow;
      }

      securelyStoreCredentials(res.authResult!.refreshToken);
      _setPreviouslyLoggedInFlag();
      _renewTokenTimer.reset();
      emit(AuthLoggedInState(authResult: res.authResult!));
    });

    on<AuthConfirmationEvent>((event, emit) async {
      if (!event.isSilentLogin) {
        emit(AuthLoadingState());
      }

      AuthResult? verificationResult;
      try {
        verificationResult = await state.verifyCredentials();
      } catch (e) {
        emit(AuthLoggedOutState());
        rethrow;
      }

      if (verificationResult == null) {
        emit(AuthLoggedOutState());
        return;
      }

      emit(AuthLoggedInState(authResult: verificationResult));
    });

    on<AuthLogoutEvent>((event, emit) async {
      if (state is! AuthLoggedOutState) {
        eraseCredentialsFromStorage();
        _renewTokenTimer.cancel();
        emit(AuthLoggedOutState());
      }
    });
  }

  void _setPreviouslyLoggedInFlag() async {
    SharedPreferences shared = await SharedPreferences.getInstance();
    shared.setBool("previouslyLoggedIn", true);
  }

  void tokenRenewalRoutine() {
    add(AuthConfirmationEvent(true));
    _renewTokenTimer.reset();
  }
}
