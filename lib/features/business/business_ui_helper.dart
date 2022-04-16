import 'dart:async';

import 'package:flutter/material.dart';
import 'package:form_validator/form_validator.dart';
import 'package:no_interaction_dialog/load_dialog.dart';
import 'package:sizer/sizer.dart';
import 'package:vivity/features/item/repo/item_repository.dart';

import '../item/models/item_model.dart';

Future<int> enterStockDialog(ItemModel itemModel, BuildContext context) async {
  Completer<int> stock = Completer();
  final TextEditingController controller = TextEditingController(text: itemModel.stock.toString());
  final GlobalKey<FormState> formKey = GlobalKey();
  final ItemRepository _itemRepository = ItemRepository();
  final LoadDialog loadDialog = LoadDialog();

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

            Navigator.of(context).pop();

            showDialog(context: context, builder: (ctx) => loadDialog);
            ItemModel item = await _itemRepository.updateItemStock(id: itemModel.id.hexString, stock: int.parse(controller.text));
            Navigator.pop(context);
            stock.complete(int.parse(controller.text));
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