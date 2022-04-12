import 'package:async/async.dart';
import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:meta/meta.dart';
import 'package:vivity/features/auth/models/authentication_result.dart';
import 'package:vivity/features/auth/repo/authentication_repository.dart';
import 'package:vivity/features/auth/service/authentication_service.dart';
import 'package:vivity/features/storage/storage_service.dart';
import 'package:vivity/services/network_exception.dart';

import '../models/token_container.dart';

part 'auth_event.dart';

part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  late final RestartableTimer _renewTokenTimer =
      RestartableTimer(const Duration(minutes: 5), tokenRenewalRoutine);

  final AuthenticationRepository _authRepository = AuthenticationRepository();
  final AuthenticationService _authService = AuthenticationService();
  final StorageService _storageService = StorageService();

  AuthBloc() : super(AuthLoggedOutState()) {
    on<AuthLoginEvent>((event, emit) async {
      emit(AuthLoadingState());

      try {
        TokenContainer loginResult = await _authRepository.login(
          email: event.email,
          password: event.password,
          otp: event.otp,
        );

        _storageService.setPreviouslyLoggedIn();
        if (event.stayLoggedIn)
          _storageService.storeRefreshToken(loginResult.refreshToken);

        emit(AuthLoggedInState(loginResult));
        _renewTokenTimer.reset();
      } on NetworkException catch (e) {
        return emit(
          AuthFailedState(
              message: e.response?.data['error'] ??
                  e.message ??
                  'Authorization failed.'),
        );
      }
    });

    on<AuthHandlePre2FA>((event, emit) async {
      emit(AuthLoadingState());

      AuthenticationResult authResult = event.authResult;

      if (authResult.tokenContainer == null ||
          authResult.authStatus != AuthenticationStatus.success) {
        emit(AuthFailedState(
            message: authResult.authStatus?.getMessage() ??
                AuthenticationStatus.passwordIncorrect.getMessage()));
        return;
      }
    });

    on<AuthRegisterEvent>((event, emit) async {
      emit(AuthLoadingState());

      TokenContainer registerResult = await _authRepository.register(
        email: event.email,
        password: event.password,
        name: event.name,
        phone: event.phone,
      );

      _storageService.setPreviouslyLoggedIn();
      _storageService.storeRefreshToken(registerResult.refreshToken);

      emit(AuthLoggedInState(registerResult));
    });

    on<AuthConfirmationEvent>((event, emit) async {
      if (!event.isSilentLogin) {
        emit(AuthLoadingState());
      }

      try {
        emit(
          AuthLoggedInState(
            TokenContainer(
              accessToken: await _authRepository.getAccessToken(),
              refreshToken: await _authRepository.getRefreshToken(),
            ),
          ),
        );
      } catch (e) {
        return emit(AuthLoggedOutState());
      }
    });

    on<AuthLogoutEvent>((event, emit) async {
      if (state is! AuthLoggedOutState) {
        _authService.logout();
        _authRepository.logout();
        _storageService.deleteRefreshToken();

        _renewTokenTimer.cancel();
        emit(AuthLoggedOutState());
      }
    });
  }

  void tokenRenewalRoutine() {
    add(AuthConfirmationEvent(true));
    _renewTokenTimer.reset();
  }
}
