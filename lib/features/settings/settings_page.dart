import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:form_validator/form_validator.dart';
import 'package:intl/intl.dart';
import 'package:no_interaction_dialog/load_dialog.dart';
import 'package:no_interaction_dialog/no_interaction_dialog.dart';
import 'package:sizer/sizer.dart';
import 'package:vivity/config/themes/themes_config.dart';
import 'package:vivity/constants/regex.dart';
import 'package:vivity/features/auth/password_field.dart';
import 'package:vivity/features/base_page.dart';
import 'package:vivity/features/settings/otp_preview.dart';
import 'package:vivity/features/user/bloc/user_bloc.dart';
import 'package:vivity/services/auth_service.dart';
import 'package:vivity/services/user_service.dart';
import 'package:vivity/widgets/simple_card.dart';

import '../../helpers/ui_helpers.dart';
import '../user/models/user_options.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  Future<bool>? hasOTPFuture;
  late final NoInteractionDialogController _dialogController;
  late final LoadDialog _loadDialog;

  @override
  void initState() {
    super.initState();
    _dialogController = NoInteractionDialogController();
    _loadDialog = LoadDialog(controller: _dialogController);
  }

  @override
  Widget build(BuildContext context) {
    return BasePageBlocBuilder<UserBloc, UserState>(
      builder: (ctx, state) {
        if (state is! UserLoggedInState) return Text('You must be logged in to be here...');

        String currencyName = state.userOptions.currencyType!.toUpperCase();
        hasOTPFuture ??= hasOTP(id: state.id.hexString);

        return defaultGradientBackground(
          child: SingleChildScrollView(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Center(
                    child: Text(
                      'Personal',
                      style: Theme.of(context).textTheme.headline3?.copyWith(fontSize: 20.sp),
                    ),
                  ),
                ),
                SizedBox(
                  width: 90.w,
                  child: SimpleCard(
                    elevation: 7,
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                    child: Column(
                      children: [
                        buildPreferenceListTile("EMAIL", state.email, context, onPressed: () async {
                          Completer<String?> completer = Completer();
                          ValueDialog dialog = ValueDialog(
                            "Change email",
                            "Email",
                            completer,
                            validator: ValidationBuilder().add((value) => validEmail.hasMatch(value ?? "f") ? null : "Invalid email"),
                          );

                          await showDialog(context: context, builder: (ctx) => dialog);
                          String? email = await completer.future;
                          if (email == null) return;
                          showDialog(context: context, builder: (ctx) => _loadDialog);
                          dynamic result = await updateUser(state.accessToken, email: email);
                          handleUserUpdate(result, failureMessage: "Email already exists", successMessage: "Updated email address");
                        }),
                        buildPreferenceListTile("PHONE NUMBER", state.phone, context, onPressed: () async {
                          Completer<String?> completer = Completer();
                          ValueDialog dialog = ValueDialog(
                            "Change phone number",
                            "Phone number",
                            completer,
                            isNumber: true,
                            parseToNumber: false,
                            validator: ValidationBuilder().add((value) {
                              if (value == null || value.length != 10) return 'Must be a 10 digit number';
                              return numbersRegex.hasMatch(value) ? null : 'Must be a 10 digit number';
                            }),
                          );

                          await showDialog(context: context, builder: (ctx) => dialog);
                          String? phone = await completer.future;
                          if (phone == null) return;
                          showDialog(context: context, builder: (ctx) => _loadDialog);
                          dynamic result = await updateUser(state.accessToken, phone: phone.toString());
                          handleUserUpdate(result, failureMessage: "Failed to update phone number", successMessage: "Updated phone number");
                        }),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Center(
                    child: Text(
                      'Preferences',
                      style: Theme.of(context).textTheme.headline3?.copyWith(fontSize: 20.sp),
                    ),
                  ),
                ),
                SizedBox(
                  width: 90.w,
                  child: SimpleCard(
                    elevation: 7,
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                    child: Column(
                      children: [
                        buildPreferenceListTile(
                          "UNITS",
                          state.userOptions.unit == Unit.metric ? "Metric" : "Empirical",
                          context,
                          onPressed: () async {},
                        ),
                        buildPreferenceListTile(
                          "CURRENCY",
                          "${currency(currencyName)} $currencyName",
                          context,
                          onPressed: () {},
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Center(
                    child: Text(
                      'Password and Authentication',
                      style: Theme.of(context).textTheme.headline3?.copyWith(fontSize: 20.sp),
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () => changePassword(state.accessToken, ctx),
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(fillerColor),
                    padding: MaterialStateProperty.all(EdgeInsets.all(12)),
                    overlayColor: MaterialStateProperty.all(Colors.white.withOpacity(0.6)),
                  ),
                  child: Text(
                    'Change Password',
                    style: Theme.of(context).textTheme.headline4?.copyWith(fontSize: 12.sp, color: Colors.white),
                  ),
                ),
                FutureBuilder<bool>(
                  future: hasOTPFuture,
                  builder: (ctx, snapshot) {
                    if (!snapshot.hasData) return Container();

                    bool hasOtp = snapshot.data!;
                    return hasOtp
                        ? TextButton(
                            onPressed: () => disableTwoFactor(state.accessToken, ctx),
                            style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all(fillerColor),
                              padding: MaterialStateProperty.all(EdgeInsets.all(12)),
                              overlayColor: MaterialStateProperty.all(Colors.white.withOpacity(0.6)),
                            ),
                            child: Text(
                              'Remove 2FA',
                              style: Theme.of(context).textTheme.headline4?.copyWith(fontSize: 12.sp, color: Colors.white),
                            ),
                          )
                        : TextButton(
                            onPressed: () => enableTwoFactor(state.email, state.accessToken, ctx),
                            style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all(fillerColor),
                              padding: MaterialStateProperty.all(EdgeInsets.all(12)),
                              overlayColor: MaterialStateProperty.all(Colors.white.withOpacity(0.6)),
                            ),
                            child: Text(
                              'Enable Two-Factor Auth',
                              style: Theme.of(context).textTheme.headline4?.copyWith(fontSize: 12.sp, color: Colors.white),
                            ),
                          );
                  },
                )
              ],
            ),
          ),
        );
      },
    );
  }

  void handleUserUpdate(
    dynamic result, {
    String? failureMessage,
    String? successMessage,
  }) {
    if (result == null) {
      Navigator.pop(context);
      if (failureMessage != null) {
        showSnackBar(failureMessage, context);
      }
      return;
    }

    context.read<UserBloc>().add(UserFrontendUpdate(options: result['options'], email: result['email'], phone: result['phone']));
    context.read<UserBloc>().add(UserRenewTokenEvent(result['access_token']));
    Navigator.pop(context);
    if (successMessage != null) {
      showSnackBar(successMessage, context);
    }
  }

  void changePassword(String token, BuildContext context) async {
    TextEditingController _newPasswordController = TextEditingController();
    Completer<String?> completer = Completer();
    ValueDialog dialog = ValueDialog(
      "Change password",
      "Current password",
      completer,
      isPassword: true,
      size: Size(0, 40.h),
      validator: ValidationBuilder().add((value) => securePasswordRegex.hasMatch(value ?? 'f') ? null : "Must be a secure, valid password."),
      miscContentAfter: (ctx, _setState, state) {
        return PasswordField(
          controller: _newPasswordController,
          labelText: "New password",
          showTips: true,
        );
      },
    );
    await showDialog(
      context: context,
      builder: (ctx) => dialog,
    );
    String? currentPassword = await completer.future;
    String? newPassword = _newPasswordController.text;
    if (currentPassword == null || newPassword == null) return;
    showDialog(context: context, builder: (ctx) => _loadDialog);
    Response response = await updatePassword(token, currentPassword, newPassword);
    if (response.statusCode! > 300) {
      showSnackBar(response.data['error'], context);
      Navigator.pop(context);
      return;
    }

    context.read<UserBloc>().add(UserRenewTokenEvent(response.data['access_token']));
    Navigator.pop(context);
    showSnackBar('Successfully changed password', context);
  }

  void disableTwoFactor(String token, BuildContext context) async {
    showDialog(context: context, builder: (ctx) => _loadDialog);
    Response response = await disableOTP(token);
    Navigator.pop(context);
    if (response.statusCode! > 300) {
      showSnackBar('Failed to disable 2FA', context);
      return;
    }

    setState(() {
      hasOTPFuture = Future.value(false);
    });
  }

  void enableTwoFactor(String email, String token, BuildContext context) async {
    showDialog(context: context, builder: (ctx) => _loadDialog);
    Response response = await enableOTP(token);
    Navigator.pop(context);
    if (response.statusCode! > 300) {
      showSnackBar('Failed to enable 2FA', context);
      return;
    }

    setState(() {
      hasOTPFuture = Future.value(true);
    });
    showDialog(
      context: context,
      builder: (ctx) => SizedBox(
        child: OTPPreview(email: email, seed: response.data['secret']),
      ),
    );
  }

  Widget buildPreferenceListTile(
    String title,
    String subtitle,
    BuildContext context, {
    VoidCallback? onPressed,
  }) {
    return ListTile(
      title: Text(
        title,
        style: Theme.of(context).textTheme.headline4?.copyWith(fontSize: 12.sp),
      ),
      subtitle: Text(
        subtitle,
        style: Theme.of(context).textTheme.headline4?.copyWith(fontSize: 11.sp, fontWeight: FontWeight.normal, color: fillerColor),
      ),
      trailing: TextButton(
        onPressed: onPressed,
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all(fillerColor),
          overlayColor: MaterialStateProperty.all(Colors.white.withOpacity(0.6)),
        ),
        child: Text(
          'Edit',
          style: Theme.of(context).textTheme.headline4?.copyWith(fontSize: 12.sp, color: Colors.white),
        ),
      ),
    );
  }

  String formatNumber(num? number) {
    if (number is double) {
      if (number.floor() == number) return number.toStringAsFixed(0);
      return number.toStringAsFixed(2);
    }

    return number?.toStringAsFixed(0) ?? "0";
  }

  String currency(String currency) {
    var format = NumberFormat.simpleCurrency(name: "ILS");
    return format.currencySymbol;
  }
}
