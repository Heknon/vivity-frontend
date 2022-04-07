import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:form_validator/form_validator.dart';
import 'package:no_interaction_dialog/load_dialog.dart';
import 'package:no_interaction_dialog/no_interaction_dialog.dart';
import 'package:sizer/sizer.dart';
import 'package:vivity/constants/regex.dart';
import 'package:vivity/features/auth/register_result.dart';
import 'package:vivity/helpers/ui_helpers.dart';
import 'package:vivity/services/auth_service.dart';

import '../../config/themes/themes_config.dart';
import 'bloc/auth_bloc.dart';

class LoginModule extends StatefulWidget {
  final TextEditingController? emailController;
  final TextEditingController? passwordController;

  const LoginModule({this.emailController, this.passwordController});

  @override
  State<LoginModule> createState() => _LoginModuleState();
}

class _LoginModuleState extends State<LoginModule> {
  late final TextEditingController emailController;
  late final TextEditingController passwordController;

  bool stayLoggedIn = false;
  bool _passwordVisible = false;
  final GlobalKey<FormState> _formKey = GlobalKey();

  @override
  void initState() {
    super.initState();

    emailController = widget.emailController ?? TextEditingController();
    passwordController = widget.passwordController ?? TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Form(
        key: _formKey,
        child: Padding(
          padding: EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 15),
              Center(
                child: SizedBox(
                  width: 85.w,
                  child: TextFormField(
                    controller: emailController,
                    validator: ValidationBuilder().minLength(5).maxLength(80).build(),
                    style: TextStyle(fontSize: 12.sp, color: Colors.black),
                    decoration: InputDecoration(
                      labelText: "Email",
                      labelStyle: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 15),
              Center(
                child: SizedBox(
                  width: 85.w,
                  child: TextFormField(
                    controller: passwordController,
                    validator: ValidationBuilder().minLength(8).maxLength(80).build(),
                    style: TextStyle(fontSize: 12.sp, color: Colors.black),
                    obscureText: !_passwordVisible,
                    obscuringCharacter: '*',
                    decoration: InputDecoration(
                      labelText: "Password",
                      labelStyle: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _passwordVisible ? Icons.visibility : Icons.visibility_off,
                          color: fillerColor,
                        ),
                        onPressed: () {
                          setState(() {
                            _passwordVisible = !_passwordVisible;
                          });
                        },
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 15),
              Center(
                child: SizedBox(
                  width: 85.w,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Stay logged in',
                        style: Theme.of(context).textTheme.headline4!.copyWith(fontSize: 13.sp, color: fillerColor, fontWeight: FontWeight.normal),
                      ),
                      Switch(
                        value: stayLoggedIn,
                        activeColor: Colors.white,
                        activeTrackColor: fillerColor,
                        onChanged: (val) => setState(() {
                          stayLoggedIn = val;
                        }),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 25),
              Center(
                child: TextButton(
                  style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(Theme.of(context).colorScheme.secondaryVariant),
                      overlayColor: MaterialStateProperty.all(Colors.grey),
                      fixedSize: MaterialStateProperty.all(Size(85.w, 15.sp * 3))),
                  child: Text(
                    'Login',
                    style: Theme.of(context).textTheme.headline4!.copyWith(fontSize: 20.sp, fontWeight: FontWeight.normal, color: Colors.white),
                  ),
                  onPressed: () async {
                    if (!(_formKey.currentState?.validate() ?? true)) {
                      ScaffoldMessenger.of(context).clearSnackBars();
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fill out correctly.')));
                      return;
                    }
                    _formKey.currentState?.save();

                    NoInteractionDialogController _dialogController = NoInteractionDialogController();
                    LoadDialog loadDialog = LoadDialog(controller: _dialogController);
                    showDialog(context: context, builder: (ctx) => loadDialog);
                    bool otpEnabled = await hasOTP(emailController.text);
                    RegisterResult? preLoginCheck = otpEnabled ? await shouldOpenOTP(emailController.text, passwordController.text) : null;
                    Navigator.pop(context);
                    bool shouldRequestOTP = false;
                    if (preLoginCheck != null) {
                      if (preLoginCheck.authStatus != AuthenticationResult.wrongOTP) {
                        context.read<AuthBloc>().add(
                          AuthHandlePre2FA(preLoginCheck),
                        );
                        return;
                      } else {
                        shouldRequestOTP = true;
                      }
                    }
                    String? otp;
                    if (otpEnabled && shouldRequestOTP) {
                      Completer<int> completer = Completer();
                      ValueDialog dialog = ValueDialog(
                        "2FA",
                        "6 digit code",
                        completer,
                        isNumber: true,
                        showCancel: false,
                        validator: ValidationBuilder().add((value) {
                          if (value == null || value.length != 6) return 'Must be a 6 digit code';
                          if (int.tryParse(value) == null) return 'Must be a 6 digit code';
                          return null;
                        }),
                      );
                      showDialog(
                          context: context,
                          builder: (ctx) => WillPopScope(
                                onWillPop: () async => false,
                                child: dialog,
                              ));
                      otp = (await completer.future).toString();
                    }

                    handleLogin(emailController.text, passwordController.text, otp);
                    ScaffoldMessenger.of(context).clearSnackBars();
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Logging in!')));
                  },
                ),
              ),
              SizedBox(height: 15),
            ],
          ),
        ),
      ),
    );
  }

  Future<RegisterResult?> shouldOpenOTP(String email, String password) async {
    RegisterResult? loginResult = await login(email, password, null, null);

    return loginResult;
  }

  void handleLogin(String email, String password, String? otp) {
    print("Handling login - Email: $email, Password: $password");
    context.read<AuthBloc>().add(
          AuthLoginEvent(email.trim(), password, otp, stayLoggedIn),
        );
  }
}
