import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:form_validator/form_validator.dart';
import 'package:no_interaction_dialog/load_dialog.dart';
import 'package:sizer/sizer.dart';
import 'package:vivity/features/item/repo/item_repository.dart';
import 'package:vivity/helpers/ui_helpers.dart';

import 'models/item_model.dart';

class ItemCreationDialog extends StatelessWidget {
  final ItemRepository _itemRepository = ItemRepository();

  final TextEditingController _controllerTitle = TextEditingController();
  final TextEditingController _controllerSubtitle = TextEditingController();
  final TextEditingController _controllerPrice = TextEditingController();
  final TextEditingController _controllerBrand = TextEditingController();
  final TextEditingController _controllerCategory = TextEditingController();
  final TextEditingController _controllerTags = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey();
  final LoadDialog _loadDialog = LoadDialog();

  final void Function(ItemModel)? onCreateItem;

  ItemCreationDialog({
    Key? key,
    this.onCreateItem,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        'Item Creator',
        style: Theme.of(context).textTheme.headline4?.copyWith(fontSize: 16.sp),
      ),
      content: Form(
        key: _formKey,
        child: SizedBox(
          width: 85.w,
          height: 50.h,
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  controller: _controllerTitle,
                  validator: ValidationBuilder().minLength(3).maxLength(25).build(),
                  style: TextStyle(fontSize: 12.sp, color: Colors.black),
                  keyboardType: TextInputType.text,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  decoration: InputDecoration(
                    labelText: 'Title',
                    labelStyle: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
                  ),
                ),
                SizedBox(height: 10),
                TextFormField(
                  controller: _controllerSubtitle,
                  validator: ValidationBuilder().minLength(3).maxLength(25).build(),
                  style: TextStyle(fontSize: 12.sp, color: Colors.black),
                  keyboardType: TextInputType.text,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  decoration: InputDecoration(
                    labelText: 'Subtitle',
                    labelStyle: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
                  ),
                ),
                SizedBox(height: 10),
                TextFormField(
                  controller: _controllerPrice,
                  validator: ValidationBuilder().add((value) => double.tryParse(value ?? "f") != null ? null : "Must be an decimal number.").build(),
                  style: TextStyle(fontSize: 12.sp, color: Colors.black),
                  keyboardType: const TextInputType.numberWithOptions(signed: true, decimal: true),
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  decoration: InputDecoration(
                    labelText: 'Price',
                    labelStyle: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
                  ),
                ),
                SizedBox(height: 10),
                TextFormField(
                  controller: _controllerBrand,
                  validator: ValidationBuilder().minLength(3).maxLength(30).build(),
                  style: TextStyle(fontSize: 12.sp, color: Colors.black),
                  keyboardType: TextInputType.text,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  decoration: InputDecoration(
                    labelText: 'Brand',
                    hintText: 'Associated brand name',
                    labelStyle: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
                  ),
                ),
                SizedBox(height: 10),
                TextFormField(
                  controller: _controllerCategory,
                  validator: ValidationBuilder().minLength(3).maxLength(30).build(),
                  style: TextStyle(fontSize: 12.sp, color: Colors.black),
                  keyboardType: TextInputType.text,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  decoration: InputDecoration(
                    labelText: 'Search category',
                    labelStyle: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
                  ),
                ),
                SizedBox(height: 10),
                TextFormField(
                  controller: _controllerTags,
                  validator: ValidationBuilder().minLength(3).maxLength(100).build(),
                  style: TextStyle(fontSize: 12.sp, color: Colors.black),
                  keyboardType: TextInputType.text,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  decoration: InputDecoration(
                    labelText: 'Tags',
                    hintText: "Food, Tasty, Colorful",
                    labelStyle: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
                  ),
                ),
              ],
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
            if (!(_formKey.currentState?.validate() ?? false)) {
              ScaffoldMessenger.of(context).clearSnackBars();
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Please enter all fields correctly.')));
              return;
            }

            showDialog(context: context, builder: (ctx) => _loadDialog);
            ItemModel createdItem = await _itemRepository.createItemModel(
              title: _controllerTitle.text,
              price: double.parse(_controllerPrice.text),
              subtitle: _controllerSubtitle.text,
              brand: _controllerBrand.text,
              category: _controllerCategory.text,
              tags: _controllerTags.text.split(",").map((e) => e.trim()).toList(),
            );
            Navigator.pop(context);
            showSnackBar('Created item ${createdItem.itemStoreFormat.title}.', context);
            Navigator.of(context).pop();
            if (onCreateItem != null) onCreateItem!(createdItem);
          },
          style: ButtonStyle(
              splashFactory: InkRipple.splashFactory,
              textStyle: MaterialStateProperty.all(Theme.of(context).textTheme.headline3?.copyWith(fontSize: 14.sp))),
          child: Text(
            'CREATE',
            style: Theme.of(context).textTheme.headline3?.copyWith(color: Theme.of(context).primaryColor, fontSize: 14.sp),
          ),
        )
      ],
    );
  }
}
