import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:vivity/constants/regex.dart';

import '../../config/themes/themes_config.dart';

class PasswordField extends StatefulWidget {
  final TextEditingController? controller;
  final bool showTips;
  final void Function(String?)? onSaved;

  const PasswordField({
    Key? key,
    this.controller,
    this.showTips = true,
    this.onSaved,
  }) : super(key: key);

  @override
  PasswordFieldState createState() => PasswordFieldState();
}

class PasswordFieldState extends State<PasswordField> {
  late final TextEditingController _controller;
  bool _visible = false;

  bool _passesUpperLower = false;
  bool _passesNumber = false;
  bool _passesSpecialChar = false;
  bool _passesLength = false;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: _controller,
          obscuringCharacter: '*',
          obscureText: !_visible,
          style: TextStyle(fontSize: 12.sp, color: Colors.black),
          validator: validate,
          onSaved: widget.onSaved,
          decoration: InputDecoration(
            labelText: "Password",
            labelStyle: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
            suffixIcon: IconButton(
              icon: Icon(
                _visible ? Icons.visibility : Icons.visibility_off,
                color: fillerColor,
              ),
              onPressed: () {
                setState(() {
                  _visible = !_visible;
                });
              },
            ),
          ),
          onChanged: (String? s) {
            if (s == null) return;
            setState(() {
              _passesUpperLower = upperAndLowerCaseRegex.hasMatch(_controller.text);
              _passesSpecialChar = specialCharactersRegex.hasMatch(_controller.text);
              _passesNumber = numbersRegex.hasMatch(_controller.text);
              _passesLength = s.length >= 8;
            });
          },
        ),
        Divider(
          thickness: 0,
          color: Colors.transparent,
        ),
        if (widget.showTips) ...[
          buildConditionText('include both lower and upper case characters.', _passesUpperLower),
          SizedBox(height: 2),
          buildConditionText('include at least one symbol', _passesSpecialChar),
          SizedBox(height: 2),
          buildConditionText('include at least one number', _passesNumber),
          SizedBox(height: 2),
          buildConditionText('be between 8 and 100 characters long', _passesLength)
        ],
      ],
    );
  }

  RichText buildConditionText(String text, bool success) {
    Color color = success ? Colors.green : Colors.red;
    return RichText(
      text: TextSpan(
        children: [
          WidgetSpan(
            child: Icon(
              success ? Icons.check : Icons.clear,
              color: color,
              size: 14.sp,
            ),
          ),
          TextSpan(
            text: text,
            style: Theme.of(context).textTheme.subtitle2?.copyWith(
                  fontSize: 10.sp,
                  color: color,
                ),
          )
        ],
      ),
    );
  }

  String? validate(String? text) {
    return securePasswordRegex.hasMatch(text ?? 'f') ? null : "Must be a secure password";
  }
}
