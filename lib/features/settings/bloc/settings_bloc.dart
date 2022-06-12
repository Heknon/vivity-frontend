import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:vivity/features/auth/repo/authentication_repository.dart';
import 'package:vivity/features/user/models/user.dart';
import 'package:vivity/features/user/models/user_options.dart';
import 'package:vivity/features/user/repo/user_repository.dart';
import 'package:vivity/features/user/service/user_service.dart';
import 'package:vivity/services/network_exception.dart';

part 'settings_event.dart';

part 'settings_state.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  UserRepository _userRepository = UserRepository();
  UserService _userService = UserService();
  AuthenticationRepository _authRepository = AuthenticationRepository();

  SettingsBloc() : super(SettingsUnloaded()) {
    on<SettingsLoadEvent>((event, emit) async {
      emit(SettingsLoading());

      User user = await _userRepository.getUser();
      bool hasOTP = await _authRepository.hasOTP();

      emit(SettingsLoaded(
        hasOTP: hasOTP,
        email: user.email,
        phone: user.phone,
        unit: user.userOptions.unit,
        currency: user.userOptions.currencyType,
        otpSeed: null,
      ));
    });

    on<SettingsUpdateEmailEvent>((event, emit) async {
      if (state is! SettingsLoaded) return;

      User user;
      try {
        user = await _userRepository.updateUser(
          email: event.email,
        );
      } on Exception catch (e) {
        emit((state as SettingsLoaded).copyWith(
            responseMessage:
                e is NetworkException ? e.message ?? e.response?.data['error'] ?? "Failed to update email" : "Failed to update email",
            resetResponseMessage: true));
        return;
      }

      SettingsLoaded newState = (state as SettingsLoaded).copyWith(
        email: user.email,
        phone: user.phone,
        unit: user.userOptions.unit,
        currency: user.userOptions.currencyType,
        responseMessage: null,
      );

      emit(newState);
    });

    on<SettingsUpdatePhoneEvent>((event, emit) async {
      if (state is! SettingsLoaded) return;

      User user;
      try {
        user = await _userRepository.updateUser(
          phone: event.phone,
        );
      } on Exception catch (e) {
        emit((state as SettingsLoaded).copyWith(
            responseMessage:
            e is NetworkException ? e.message ?? e.response?.data['error'] ?? "Failed to update email" : "Failed to update email",
            resetResponseMessage: true));
        return;
      }

      SettingsLoaded newState = (state as SettingsLoaded).copyWith(
        email: user.email,
        phone: user.phone,
        unit: user.userOptions.unit,
        currency: user.userOptions.currencyType,
        responseMessage: null,
      );

      emit(newState);
    });

    on<SettingsUpdatePasswordEvent>((event, emit) async {
      if (state is! SettingsLoaded) return;

      SettingsLoaded newState;
      try {
        await _authRepository.changePassword(password: event.password, newPassword: event.newPassword);

        newState = (state as SettingsLoaded).copyWith(responseMessage: "Updated password!");
      } on Exception catch (e) {
        newState = (state as SettingsLoaded).copyWith(
          responseMessage:
              e is NetworkException ? e.message ?? e.response?.data['error'] ?? "Failed to update password" : "Failed to update password",
        );
      }
      emit(newState);
    });

    on<SettingsEnableOTPEvent>((event, emit) async {
      if (state is! SettingsLoaded) return;

      SettingsLoaded newState;
      try {
        String seed = await _authRepository.enableOTP();

        newState = (state as SettingsLoaded).copyWith(responseMessage: null, hasOTP: true, otpSeed: seed);
      } on Exception catch (e) {
        newState = (state as SettingsLoaded).copyWith(
          hasOTP: false,
          responseMessage: "Failed to enable OTP",
        );
      }
      emit(newState);
    });

    on<SettingsDisableOTPEvent>((event, emit) async {
      if (state is! SettingsLoaded) return;

      SettingsLoaded newState;
      try {
        bool hasOtp = await _authRepository.disableOTP();

        newState = (state as SettingsLoaded).copyWith(responseMessage: "Disabled OTP", hasOTP: hasOtp, otpSeed: null);
      } on Exception catch (e) {
        newState = (state as SettingsLoaded).copyWith(
          hasOTP: false,
          otpSeed: null,
          responseMessage: "Disabled OTP",
        );
      }
      emit(newState);
    });

    on<SettingsUnloadOTPSeedEvent>((event, emit) async {
      if (state is! SettingsLoaded) return;

      SettingsLoaded newState = (state as SettingsLoaded).copyWith(
        otpSeed: null,
        resetResponseMessage: true,
        responseMessage: null,
      );
      emit(newState);
    });

    on<SettingsResetMessageEvent>((event, emit) {
      SettingsState s = state;
      if (s is! SettingsLoaded) return;

      emit(s.copyWith(responseMessage: null, resetResponseMessage: true));
    });

    on<SettingsUnloadEvent>((event, emit) {
      emit(SettingsUnloaded());
    });
  }
}
