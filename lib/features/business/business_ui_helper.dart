import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:form_validator/form_validator.dart';
import 'package:sizer/sizer.dart';

import '../../services/item_service.dart';
import '../item/models/item_model.dart';
import '../user/bloc/user_bloc.dart';

Future<int> enterStockDialog(String userToken, ItemModel itemModel, BuildContext context) async {
  Completer<int> stock = Completer();
  final TextEditingController controller = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey();

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
                .add((value) => int.tryParse(value ?? "f") != null ? null : "Must be an integer.")
                .add((value) => int.parse(value ?? '0') >= 10000 ? "Must be below 10000" : null)
                .add((value) => int.parse(value ?? '0') < 0 ? "Must be above 0" : null)
                .build(),
            style: TextStyle(fontSize: 12.sp, color: Colors.black),
            keyboardType: const TextInputType.numberWithOptions(signed: true, decimal: false),
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

            ItemModel item = await updateItemStock(userToken, itemModel.id.hexString, int.parse(controller.text));
            context.read<UserBloc>().add(BusinessUserFrontendUpdateItem(item));
            stock.complete(int.parse(controller.text));
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

  return stock.future;
}