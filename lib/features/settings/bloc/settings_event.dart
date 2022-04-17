part of 'settings_bloc.dart';

@immutable
abstract class SettingsEvent {}

class SettingsLoadEvent extends SettingsEvent {}

class SettingsUnloadEvent extends SettingsEvent {}

class SettingsUpdateEmailEvent extends SettingsEvent {
  final String email;

  SettingsUpdateEmailEvent(this.email);
}

class SettingsUpdatePhoneEvent extends SettingsEvent {
  final String phone;

  SettingsUpdatePhoneEvent(this.phone);
}

class SettingsUpdatePasswordEvent extends SettingsEvent {
  final String password;
  final String newPassword;

  SettingsUpdatePasswordEvent(this.password, this.newPassword);
}

class SettingsEnableOTPEvent extends SettingsEvent {}

class SettingsDisableOTPEvent extends SettingsEvent {}

class SettingsUnloadOTPSeedEvent extends SettingsEvent {}

class SettingsResetMessageEvent extends SettingsEvent {}
