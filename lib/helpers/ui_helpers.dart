import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:form_validator/form_validator.dart';
import 'package:sizer/sizer.dart';

Future<RenderBox> getRenderBox(GlobalKey key) async {
  Completer<RenderBox> completer = Completer();

  WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
    final GlobalKey currKey = key;
    final RenderBox box = currKey.currentContext?.findRenderObject() as RenderBox;
    completer.complete(box);
  });

  return completer.future;
}

Widget gradientBackground({required Widget child, required List<Color> colors, required List<double> stops}) {
  return Container(
    height: 100.h - kToolbarHeight,
    decoration: BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: colors,
        stops: stops,
      ),
    ),
    child: child,
  );
}

Widget defaultGradientBackground({required Widget child}) {
  return gradientBackground(child: child, colors: [Color(0xffF3F1F2), Color(0xffEAEAEC)], stops: [0, 1]);
}

Size getTextSize(Text text) {
  final TextPainter textPainter =
      TextPainter(text: TextSpan(text: text.data, style: text.style), maxLines: 1, textDirection: text.textDirection ?? TextDirection.ltr)
        ..layout(minWidth: 0, maxWidth: double.infinity);
  return textPainter.size;
}

Future<T> getValueDialog<T>(String title, BuildContext context) async {
  Completer<T> value = Completer();
  final TextEditingController controller = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey();
  bool isNum = T is num;

  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(
        'Edit stock',
        style: Theme.of(context).textTheme.headline4?.copyWith(fontSize: 16.sp),
      ),
      content: Form(
        key: formKey,
        child: SizedBox(
          width: 85.w,
          child: TextFormField(
            controller: controller,
            validator: ValidationBuilder()
                .add((value) => !isNum
                    ? null
                    : int.tryParse(value ?? "f") != null
                        ? null
                        : "Must be an integer.")
                .build(),
            style: TextStyle(fontSize: 12.sp, color: Colors.black),
            keyboardType: isNum ? TextInputType.numberWithOptions(signed: true, decimal: T is double) : TextInputType.text,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            decoration: InputDecoration(
              labelText: 'Stock',
              labelStyle: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          style: ButtonStyle(
              splashFactory: InkRipple.splashFactory,
              textStyle: MaterialStateProperty.all(Theme.of(context).textTheme.headline3?.copyWith(fontSize: 14.sp))),
          child: Text(
            'CANCEL',
            style: Theme.of(context).textTheme.headline3?.copyWith(color: Colors.grey[600]!.withOpacity(0.7), fontSize: 14.sp),
          ),
        ),
        TextButton(
          onPressed: () async {
            if (!(formKey.currentState?.validate() ?? false)) {
              return;
            }

            Navigator.of(context).pop();
          },
          style: ButtonStyle(
              splashFactory: InkRipple.splashFactory,
              textStyle: MaterialStateProperty.all(Theme.of(context).textTheme.headline3?.copyWith(fontSize: 14.sp))),
          child: Text(
            'OK',
            style: Theme.of(context).textTheme.headline3?.copyWith(color: Theme.of(context).primaryColor, fontSize: 14.sp),
          ),
        ),
      ],
    ),
  );

  return value.future;
}
