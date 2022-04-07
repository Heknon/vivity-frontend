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

Future<T> getValueDialog<T>(
  String title,
  String labelText,
  BuildContext context, {
  int? minLength,
  int? maxLength,
  String? initialValue,
  bool isNumber = false,
  ValidationBuilder? validator,
  Widget Function(BuildContext, void Function(VoidCallback))? miscContent,
  Size? size,
}) async {
  Completer<T> value = Completer();
  final TextEditingController controller = TextEditingController(text: initialValue);
  final GlobalKey<FormState> formKey = GlobalKey();
  ValidationBuilder validationBuilder = validator ?? ValidationBuilder();
  if (minLength != null) validationBuilder.minLength(minLength);
  if (maxLength != null) validationBuilder.maxLength(maxLength);
  if (isNumber) validationBuilder.add((value) => num.tryParse(value ?? "f") != null ? null : "Must be an number.");

  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(
        title,
        style: Theme.of(context).textTheme.headline4?.copyWith(fontSize: 16.sp),
      ),
      content: StatefulBuilder(builder: (context, setState) {
        return Form(
          key: formKey,
          child: SizedBox(
            width: 85.w,
            child: miscContent != null
                ? SizedBox.fromSize(
                    size: size,
                    child: Column(
                      children: [
                        miscContent(ctx, setState),
                        buildResultField(controller, validationBuilder, isNumber, labelText),
                      ],
                    ),
                  )
                : buildResultField(controller, validationBuilder, isNumber, labelText),
          ),
        );
      }),
      actions: [
        TextButton(
          onPressed: () {
            value.complete(null);
            Navigator.pop(context);
          },
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

            value.complete((isNumber ? num.parse(controller.text) : controller.text) as T);
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

class ValueDialog<T> extends StatefulWidget {
  final String title;
  final String labelText;
  final Completer<T> completer;
  final int? minLength;
  final int? maxLength;
  final String? initialValue;
  final bool isNumber;
  final bool showCancel;
  final ValidationBuilder? validator;
  final Widget Function(BuildContext, void Function(VoidCallback), _ValueDialogState<T>)? miscContent;
  final Size? size;

  const ValueDialog(
    this.title,
    this.labelText,
    this.completer, {
    Key? key,
    this.minLength,
    this.maxLength,
    this.initialValue,
    this.isNumber = false,
    this.validator,
    this.miscContent,
    this.showCancel = true,
    this.size,
  }) : super(key: key);

  @override
  State<ValueDialog> createState() => _ValueDialogState<T>();
}

class _ValueDialogState<T> extends State<ValueDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey();
  late final TextEditingController _controller;
  late ValidationBuilder validator;
  late String labelText;
  late bool isNumber;

  @override
  void initState() {
    super.initState();

    _controller = TextEditingController(text: widget.initialValue);
    validator = widget.validator ?? ValidationBuilder();
    if (widget.minLength != null) validator.minLength(widget.minLength!);
    if (widget.maxLength != null) validator.maxLength(widget.maxLength!);
    if (widget.isNumber) validator.add((value) => num.tryParse(value ?? "f") != null ? null : "Must be an number.");
    labelText = widget.labelText;
    isNumber = widget.isNumber;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.title,
        style: Theme.of(context).textTheme.headline4?.copyWith(fontSize: 16.sp),
      ),
      content: Form(
        key: _formKey,
        child: SizedBox(
          width: 85.w,
          child: widget.miscContent != null
              ? SizedBox.fromSize(
                  size: widget.size,
                  child: Column(
                    children: [
                      widget.miscContent!(context, setState, this),
                      buildResultField(_controller, validator, isNumber, labelText),
                    ],
                  ),
                )
              : buildResultField(_controller, validator, isNumber, labelText),
        ),
      ),
      actions: [
        if (widget.showCancel)
          TextButton(
            onPressed: () {
              widget.completer.complete(null);
              Navigator.pop(context);
            },
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
            if (!(_formKey.currentState?.validate() ?? false)) {
              return;
            }

            widget.completer.complete((isNumber ? num.parse(_controller.text) : _controller.text) as T);
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
    );
  }
}

TextFormField buildResultField(
  TextEditingController controller,
  ValidationBuilder validationBuilder,
  bool isNumber,
  String labelText, {
  bool isDecimal = true,
}) {
  return TextFormField(
    controller: controller,
    validator: validationBuilder.build(),
    style: TextStyle(fontSize: 12.sp, color: Colors.black),
    keyboardType: isNumber ? TextInputType.numberWithOptions(signed: true, decimal: isDecimal) : TextInputType.text,
    autovalidateMode: AutovalidateMode.onUserInteraction,
    decoration: InputDecoration(
      labelText: labelText,
      labelStyle: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
    ),
  );
}
