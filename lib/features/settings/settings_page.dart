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
import 'package:vivity/features/settings/bloc/settings_bloc.dart';
import 'package:vivity/features/settings/otp_preview.dart';
import 'package:vivity/widgets/simple_card.dart';

import '../../helpers/ui_helpers.dart';
import '../user/models/user_options.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late final SettingsBloc _settingsBloc;

  Future<bool>? hasOTPFuture;
  late final LoadDialog _loadDialog = LoadDialog();
  bool _loadDialogOpen = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _settingsBloc = context.read<SettingsBloc>();
  }

  @override
  Widget build(BuildContext context) {
    return BasePage(
      body: defaultGradientBackground(
        child: SingleChildScrollView(
          child: BlocConsumer<SettingsBloc, SettingsState>(
            listener: (context, state) {
              if (_loadDialogOpen) {
                Navigator.pop(context);
                _loadDialogOpen = false;
              }
              if (state is! SettingsLoaded) return;

              if (state.responseMessage != null && state.responseMessage!.isNotEmpty) {
                showSnackBar(state.responseMessage!, context);
              }

              bool cancelingOtp = false;
              bool resetMessage = true;
              if (state.hasOTP && state.otpSeed != null) {
                resetMessage = false;
                showDialog(
                  context: context,
                  builder: (ctx) => SizedBox(
                    height: 300,
                    width: 70.w,
                    child: OTPPreview(
                      email: state.email,
                      seed: state.otpSeed!,
                      onCancelPressed: (ctx) {
                        Navigator.pop(ctx);
                        showDialog(context: context, builder: (ctx) => _loadDialog);
                        _loadDialogOpen = true;
                        cancelingOtp = true;

                        context.read<SettingsBloc>().add(SettingsDisableOTPEvent());
                      },
                    ),
                  ),
                ).then((value) {
                  if (cancelingOtp) return;
                  _settingsBloc.add(SettingsUnloadOTPSeedEvent());
                  showSnackBar('Enabled 2FA', context);
                });
              }

              if (state.responseMessage != null && resetMessage) {
                _settingsBloc.add(SettingsResetMessageEvent());
              }
            },
            builder: (ctx, state) {
              if (state is! SettingsLoaded) return Center(child: CircularProgressIndicator());

              return Column(
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
                              validator: ValidationBuilder().add((value) => validEmail.hasMatch(value?.trim() ?? "f") ? null : "Invalid email"),
                            );

                            await showDialog(context: context, builder: (ctx) => dialog);
                            String? email = (await completer.future)?.trim().toLowerCase();
                            if (email == null || state.email == email) return;
                            showDialog(context: context, builder: (ctx) => _loadDialog);
                            _loadDialogOpen = true;
                            _settingsBloc.add(SettingsUpdateEmailEvent(email));
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
                                String? trimmed = value?.trim();
                                if (trimmed == null || trimmed.length != 10) return 'Must be a 10 digit number';
                                return numbersRegex.hasMatch(trimmed) ? null : 'Must be a 10 digit number';
                              }),
                            );

                            await showDialog(context: context, builder: (ctx) => dialog);
                            String? phone = (await completer.future)?.trim();
                            if (phone == null || state.phone == phone) return;
                            showDialog(context: context, builder: (ctx) => _loadDialog);
                            _loadDialogOpen = true;
                            _settingsBloc.add(SettingsUpdatePhoneEvent(phone));
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
                        textAlign: TextAlign.center,
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
                            state.unit == Unit.metric ? "Metric" : "Empirical",
                            context,
                            onPressed: () async {
                              showSnackBar("This is feature is under development", context);
                            },
                          ),
                          buildPreferenceListTile(
                            "CURRENCY",
                            state.currency != null ? "${currency(state.currency!)} ${state.currency}" : "SELECT",
                            context,
                            onPressed: () {
                              showSnackBar("This is feature is under development", context);
                            },
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
                        'Password & Authentication',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.headline3?.copyWith(fontSize: 20.sp),
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () => changePassword(context),
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
                  state.hasOTP
                      ? TextButton(
                          onPressed: () => _settingsBloc.add(SettingsDisableOTPEvent()),
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
                          onPressed: () => _settingsBloc.add(SettingsEnableOTPEvent()),
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all(fillerColor),
                            padding: MaterialStateProperty.all(EdgeInsets.all(12)),
                            overlayColor: MaterialStateProperty.all(Colors.white.withOpacity(0.6)),
                          ),
                          child: Text(
                            'Enable Two-Factor Auth',
                            style: Theme.of(context).textTheme.headline4?.copyWith(fontSize: 12.sp, color: Colors.white),
                          ),
                        ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  void changePassword(BuildContext context) async {
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
    _loadDialogOpen = true;
    _settingsBloc.add(SettingsUpdatePasswordEvent(currentPassword, newPassword));
  }

  void disableTwoFactor(String token, BuildContext context) async {
    showDialog(context: context, builder: (ctx) => _loadDialog);
    _loadDialogOpen = true;
    _settingsBloc.add(SettingsDisableOTPEvent());
  }

  void enableTwoFactor(String email, String token, BuildContext context) async {
    showDialog(context: context, builder: (ctx) => _loadDialog);
    _loadDialogOpen = true;
    _settingsBloc.add(SettingsEnableOTPEvent());
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
