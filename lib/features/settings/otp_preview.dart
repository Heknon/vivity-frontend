import 'package:dotp/dotp.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:form_validator/form_validator.dart';
import 'package:no_interaction_dialog/load_dialog.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:sizer/sizer.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vivity/features/auth/repo/authentication_repository.dart';
import 'package:vivity/features/settings/bloc/settings_bloc.dart';
import 'package:vivity/helpers/ui_helpers.dart';

import '../../config/themes/themes_config.dart';

class OTPPreview extends StatelessWidget {
  final String seed;
  final String email;
  final TextEditingController _controller = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey();
  final FocusNode _focusNode = FocusNode();
  final AuthenticationRepository _authRepository = AuthenticationRepository();
  final LoadDialog _loadDialog = LoadDialog();

  OTPPreview({Key? key, required this.email, required this.seed}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    TOTP totp = TOTP(seed);
    String url = "otpauth://totp/Vivity:${email}?secret=${seed}&issuer=Vivity";

    return AlertDialog(
      content: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SizedBox(
          height: 55.h,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: SizedBox(
                    width: 150,
                    height: 150,
                    child: QrImage(
                      data: url,
                      version: QrVersions.auto,
                      size: 150,
                    ),
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  '2FA KEY',
                  style: Theme
                      .of(context)
                      .textTheme
                      .headline4
                      ?.copyWith(fontSize: 12.sp),
                ),
                Text(
                  formatSeed(seed),
                  style: Theme
                      .of(context)
                      .textTheme
                      .headline4
                      ?.copyWith(fontSize: 11.sp, fontWeight: FontWeight.normal, color: fillerColor),
                ),
                SizedBox(height: 5),
                TextButton(
                  onPressed: () {
                    try {
                      launch(url);
                    } on Exception catch (e) {
                      showSnackBar('Authenticator app not found', context);
                    }
                  },
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(fillerColor),
                    overlayColor: MaterialStateProperty.all(Colors.white.withOpacity(0.6)),
                  ),
                  child: Text(
                    'Open in authenticator app',
                    style: Theme
                        .of(context)
                        .textTheme
                        .headline4
                        ?.copyWith(fontSize: 12.sp, color: Colors.white),
                  ),
                ),
                SizedBox(height: 15),
                Form(
                  key: _formKey,
                  child: TextFormField(
                    controller: _controller,
                    validator: ValidationBuilder().add((value) {
                      if (value == null || value.length != 6) return "Must be a 6 digit integer";
                      return int.tryParse(value) == null ? "Must be a 6 digit integer" : null;
                    }).build(),
                    focusNode: _focusNode,
                    style: TextStyle(fontSize: 12.sp, color: Colors.black),
                    keyboardType: TextInputType.numberWithOptions(signed: true, decimal: false),
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    decoration: InputDecoration(
                      labelText: "Enter 2FA Code",
                      labelStyle: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () async {
            showDialog(context: context, builder: (ctx) => _loadDialog);

            context.read<SettingsBloc>().add(SettingsDisableOTPEvent(shouldPop: true));
          },
          style: ButtonStyle(
              splashFactory: InkRipple.splashFactory,
              textStyle: MaterialStateProperty.all(Theme
                  .of(context)
                  .textTheme
                  .headline3
                  ?.copyWith(fontSize: 14.sp))),
          child: Text(
            'Cancel',
            style: Theme
                .of(context)
                .textTheme
                .headline3
                ?.copyWith(color: Theme
                .of(context)
                .primaryColor, fontSize: 14.sp),
          ),
        ),
        TextButton(
          onPressed: () async {
            _focusNode.unfocus();
            if (!(_formKey.currentState?.validate() ?? false)) {
              showSnackBar('Please enter the OTP generated by the authenticator app', context);
              return;
            }
            if (_controller.text != totp.now()) {
              showSnackBar('Incorrect OTP try again or press cancel to remove 2FA from account', context);
              return;
            }

            Navigator.of(context).pop();
            showSnackBar('Enabled Two-Factor authentication!', context);
          },
          style: ButtonStyle(
              splashFactory: InkRipple.splashFactory,
              textStyle: MaterialStateProperty.all(Theme
                  .of(context)
                  .textTheme
                  .headline3
                  ?.copyWith(fontSize: 14.sp))),
          child: Text(
            'Activate',
            style: Theme
                .of(context)
                .textTheme
                .headline3
                ?.copyWith(color: Theme
                .of(context)
                .primaryColor, fontSize: 14.sp),
          ),
        )
      ],
    );
  }

  String formatSeed(String seed) {
    String res = "";

    for (int i = 0; i < seed.length; i++) {
      res += seed[i];
      if (i % 4 == 0 && i != 0) res += " ";
    }

    return res;
  }
}
