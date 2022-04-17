part of 'settings_bloc.dart';

@immutable
abstract class SettingsState {
  const SettingsState();
}

class SettingsUnloaded extends SettingsState {}

class SettingsLoading extends SettingsState {}

class SettingsLoaded extends SettingsState {
  final bool hasOTP;
  final String? otpSeed;
  final String email;
  final String phone;
  final Unit? unit;
  final String? currency;

  final String? responseMessage;

//<editor-fold desc="Data Methods">

  const SettingsLoaded({
    required this.hasOTP,
    required this.otpSeed,
    required this.email,
    required this.phone,
    this.unit,
    this.currency,
    this.responseMessage,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SettingsLoaded &&
          runtimeType == other.runtimeType &&
          hasOTP == other.hasOTP &&
          otpSeed == other.otpSeed &&
          email == other.email &&
          phone == other.phone &&
          unit == other.unit &&
          currency == other.currency &&
          responseMessage == other.responseMessage);

  @override
  int get hashCode =>
      hasOTP.hashCode ^ otpSeed.hashCode ^ email.hashCode ^ phone.hashCode ^ unit.hashCode ^ currency.hashCode ^ responseMessage.hashCode;

  @override
  String toString() {
    return 'SettingsLoaded{' +
        ' hasOTP: $hasOTP,' +
        ' otpSeed: $otpSeed,' +
        ' email: $email,' +
        ' phone: $phone,' +
        ' unit: $unit,' +
        ' currency: $currency,' +
        ' responseMessage: $responseMessage,' +
        '}';
  }

  SettingsLoaded copyWith({
    bool? hasOTP,
    String? otpSeed,
    String? email,
    String? phone,
    Unit? unit,
    String? currency,
    String? responseMessage,
    bool resetResponseMessage = false,
  }) {
    return SettingsLoaded(
      hasOTP: hasOTP ?? this.hasOTP,
      otpSeed: otpSeed ?? this.otpSeed,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      unit: unit ?? this.unit,
      currency: currency ?? this.currency,
      responseMessage: resetResponseMessage ? responseMessage : responseMessage ?? this.responseMessage,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'hasOTP': this.hasOTP,
      'otpSeed': this.otpSeed,
      'email': this.email,
      'phone': this.phone,
      'unit': this.unit,
      'currency': this.currency,
      'responseMessage': this.responseMessage,
    };
  }

  factory SettingsLoaded.fromMap(Map<String, dynamic> map) {
    return SettingsLoaded(
      hasOTP: map['hasOTP'] as bool,
      otpSeed: map['otpSeed'] as String,
      email: map['email'] as String,
      phone: map['phone'] as String,
      unit: map['unit'] as Unit,
      currency: map['currency'] as String?,
      responseMessage: map['responseMessage'] as String?,
    );
  }

//</editor-fold>
}
