import 'dart:async';

import 'package:advanced_panel/panel.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:form_validator/form_validator.dart';
import 'package:no_interaction_dialog/load_dialog.dart';
import 'package:sizer/sizer.dart';
import 'package:vivity/config/themes/themes_config.dart';
import 'package:vivity/features/item/item_page.dart';
import 'package:vivity/features/item/modification_button_preview.dart';
import 'package:vivity/features/item/modifier/item_modifier.dart';
import 'package:vivity/features/item/modifier/item_modifier_container.dart';
import 'package:vivity/features/item/modifier/item_modifier_selector.dart';
import 'package:vivity/features/item/ui_item_helper.dart';
import 'package:vivity/features/user/bloc/user_bloc.dart';
import 'package:vivity/helpers/ui_helpers.dart';
import 'package:vivity/models/order.dart';
import 'package:vivity/services/item_service.dart';

import 'models/item_model.dart';
import 'modifier/item_modifier_service.dart';

class ItemEditPanel extends StatefulWidget {
  final ItemModel item;
  final PanelController panelController;

  const ItemEditPanel({
    Key? key,
    required this.item,
    required this.panelController,
  }) : super(key: key);

  @override
  State<ItemEditPanel> createState() => _ItemEditPanelState();
}

class _ItemEditPanelState extends State<ItemEditPanel> {
  late ItemModel clonedItem;
  late final TextEditingController _descriptionController;
  final LoadDialog _loadDialog = LoadDialog();

  @override
  void initState() {
    super.initState();

    _descriptionController = TextEditingController(text: widget.item.itemStoreFormat.description);
    clonedItem = widget.item.copyWith();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (ctx, constraints) {
        Size tabSize = Size(constraints.maxWidth, constraints.maxWidth * 0.2);
        Size itemViewSize = Size(tabSize.width, constraints.maxHeight * 0.63);

        return ConstrainedBox(
          child: SlidingUpPanel(
            gestureDetectOnlyPanel: true,
            controller: widget.panelController,
            panelSize: tabSize.height,
            contentSize: itemViewSize.height,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(18.0),
              topRight: Radius.circular(18.0),
            ),
            backdropEnabled: true,
            panel: buildTab(
              Text(
                clonedItem.itemStoreFormat.title,
                style: Theme.of(context).textTheme.headline4?.copyWith(color: fillerColor, fontSize: 24.sp, fontWeight: FontWeight.bold),
              ),
              tabSize,
              constraints,
            ),
            contentBuilder: (sc) => buildContent(context, itemViewSize, constraints, sc),
            //parallaxEnabled: true,
          ),
          constraints: constraints,
        );
      },
    );
  }

  Widget buildContent(BuildContext context, Size itemViewSize, BoxConstraints constraints, ScrollController sc) {
    List<String> titles = ["Title", "Price", "Subtitle", "Tags", "Brand", "Category"];
    List<String> dataStrings = [
      clonedItem.itemStoreFormat.title,
      '\$${clonedItem.price.toStringAsFixed(2)} USD',
      clonedItem.itemStoreFormat.subtitle ?? 'N/A',
      clonedItem.tags.join(', '),
      clonedItem.brand,
      clonedItem.category
    ];
    List<String> cleanData = [
      clonedItem.itemStoreFormat.title,
      clonedItem.price.toStringAsFixed(2),
      clonedItem.itemStoreFormat.subtitle ?? 'N/A',
      clonedItem.tags.join(', '),
      clonedItem.brand,
      clonedItem.category
    ];

    List<Widget> titleWidgets = List.empty(growable: true);
    List<Widget> dataWidgets = List.empty(growable: true);
    const baseSpace = 60;
    SizedBox spaceTitle = SizedBox(height: baseSpace - 14.sp);
    SizedBox spaceData = SizedBox(height: baseSpace - 18.5.sp);

    for (int i = 0; i < titles.length * 2 - 1; i++) {
      if (i.isOdd) {
        titleWidgets.add(spaceTitle);
        dataWidgets.add(spaceData);
        continue;
      }

      String title = titles[i ~/ 2];
      String data = dataStrings[i ~/ 2];
      bool isPrice = title == 'Price';
      bool isTags = title == 'Tags';
      int? minLength = isPrice ? null : 3;
      int? maxLength = isPrice
          ? null
          : isTags
              ? 100
              : 30;
      titleWidgets.add(buildTitleText(title, context));
      dataWidgets.add(buildDataText(
        data,
        title,
        context,
        minLength: minLength,
        maxLength: maxLength,
        isNumber: isPrice,
        onValueFilled: (value) => handleValueFilled(title, value),
        initialValue: cleanData[i ~/ 2],
      ));
    }

    return Positioned(
      bottom: 1,
      width: itemViewSize.width,
      height: itemViewSize.height,
      child: SizedBox(
        width: itemViewSize.width,
        height: itemViewSize.height,
        child: Scaffold(
          backgroundColor: Colors.white,
          body: Padding(
            padding: const EdgeInsets.only(left: 25, right: 8, top: 15, bottom: 10),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: titleWidgets,
                      ),
                      SizedBox(width: 19.w),
                      SizedBox(
                        width: 50.w,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: dataWidgets,
                        ),
                      )
                    ],
                  ),
                  SizedBox(height: baseSpace - 14.sp),
                  buildTitleText('Buttons', context),
                  SizedBox(height: 16),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: List.generate(3, (index) {
                      ModificationButton? button = index < clonedItem.itemStoreFormat.modificationButtons.length
                          ? clonedItem.itemStoreFormat.modificationButtons[index]
                          : null;
                      return ModificationButtonPreview(
                        modifier: button,
                        textColor: Colors.white,
                        size: (button == null ? const Size(60, 55) : const Size(80, 75)),
                        onTap: () async {
                          ModificationButton? changedButton = await getModificationButtonFromBuilder(
                            context,
                            button?.copyWith() ??
                                ModificationButton(
                                  name: "NAME",
                                  data: [],
                                  dataType: ModificationButtonDataType.text,
                                  side: ModificationButtonSide.values[index],
                                ),
                            button == null,
                          );
                          setState(() {
                            if (changedButton == null) {
                              clonedItem.itemStoreFormat.modificationButtons.removeAt(index);
                              clonedItem.itemStoreFormat.modificationButtons.sort((a, b) => a.side.index.compareTo(b.side.index));
                              return;
                            }
                            clonedItem.itemStoreFormat.modificationButtons.removeWhere((element) => element.side == changedButton.side);
                            clonedItem.itemStoreFormat.modificationButtons.add(changedButton);
                            clonedItem.itemStoreFormat.modificationButtons.sort((a, b) => a.side.index.compareTo(b.side.index));
                          });
                        },
                      );
                    }),
                  ),
                  SizedBox(height: 20),
                  Divider(thickness: 1, color: fillerColor),
                  SizedBox(height: 5),
                  Form(
                    child: TextFormField(
                      controller: _descriptionController,
                      validator: ValidationBuilder().build(),
                      style: TextStyle(fontSize: 12.sp, color: Colors.black),
                      keyboardType: TextInputType.text,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.zero,
                        border: OutlineInputBorder(borderSide: BorderSide.none),
                        labelText: 'Item description',
                        labelStyle: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: TextButton(
                      style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all(fillerColor),
                          padding: MaterialStateProperty.all(EdgeInsets.all(15)),
                          elevation: MaterialStateProperty.all(5),
                          overlayColor: MaterialStateProperty.all(Colors.white.withOpacity(0.6))),
                      onPressed: submit,
                      child: Text(
                        'Apply',
                        style: Theme.of(context).textTheme.headline4?.copyWith(fontSize: 16.sp, color: Colors.white),
                      ),
                    ),
                  ),
                  SizedBox(height: 100.w * 0.2),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void submit() async {
    UserState state = context.read<UserBloc>().state;
    if (state is! BusinessUserLoggedInState) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Ahhhh!!! How are you here??')));
      return;
    }

    showDialog(context: context, builder: (ctx) => _loadDialog);
    ItemModel updatedItem = await updateItem(
      state.accessToken,
      widget.item.id.hexString,
      tags: clonedItem.tags.map((e) => e.trim()).toList(),
      title: clonedItem.itemStoreFormat.title.trim(),
      subtitle: clonedItem.itemStoreFormat.subtitle?.trim(),
      category: clonedItem.category.trim(),
      price: clonedItem.price,
      description: _descriptionController.text.trim(),
      brand: clonedItem.brand,
      stock: clonedItem.stock,
      modificationButtons: clonedItem.itemStoreFormat.modificationButtons,
    );
    context.read<UserBloc>().add(BusinessUserFrontendUpdateItem(item: updatedItem));
    Navigator.pop(context);
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (ctx) => ItemPage(item: updatedItem)));
    widget.panelController.close();
  }

  Widget buildTitleText(String title, BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.subtitle1?.copyWith(fontSize: 14.sp),
    );
  }

  Widget buildDataText<T>(
    String data,
    String title,
    BuildContext context, {
    int? minLength,
    int? maxLength,
    String? initialValue,
    void Function(T)? onValueFilled,
    bool isNumber = false,
  }) {
    Text text = Text(
      data,
      overflow: TextOverflow.ellipsis,
      maxLines: 1,
      style: Theme.of(context).textTheme.headline4?.copyWith(fontSize: 16.5.sp, fontWeight: FontWeight.normal),
    );

    return TextButton(
      style: ButtonStyle(
        padding: MaterialStateProperty.all(EdgeInsets.zero),
        visualDensity: VisualDensity.compact,
        fixedSize: MaterialStateProperty.all(getTextSize(text)),
        alignment: Alignment.topLeft,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      onPressed: () async {
        T result = await getValueDialog<T>(
          title,
          title,
          context,
          minLength: minLength,
          maxLength: maxLength,
          initialValue: initialValue,
          isNumber: isNumber,
        );
        if (onValueFilled != null) onValueFilled(result);
      },
      child: text,
    );
  }

  Future<ModificationButton?> getModificationButtonFromBuilder(
    BuildContext context,
    ModificationButton changedButton,
    bool newButton,
  ) async {
    Completer<ModificationButton?> completer = Completer();
    ModificationButton modifiedButton = changedButton.copyWith();

    showDialog(
        context: context,
        builder: (ctx) {
          return ItemModifierEditorDialog(
            button: modifiedButton,
            onComplete: (btn) {
              completer.complete(btn);
            },
            isNewButton: newButton,
          );
        });

    return completer.future;
  }

  void handleValueFilled<T>(String title, T value) {
    if (value == null) return;
    switch (title) {
      case "Title":
        setState(() {
          clonedItem = clonedItem.copyWith(itemStoreFormat: clonedItem.itemStoreFormat.copyWith(title: (value as String).trim()));
        });
        break;
      case "Price":
        setState(() {
          clonedItem = clonedItem.copyWith(price: (value as num).toDouble());
        });
        break;
      case "Subtitle":
        setState(() {
          clonedItem = clonedItem.copyWith(itemStoreFormat: clonedItem.itemStoreFormat.copyWith(subtitle: (value as String).trim()));
        });
        break;
      case "Tags":
        setState(() {
          clonedItem = clonedItem.copyWith(tags: (value as String).split(',').map((e) => e.trim()).toList());
        });
        break;
      case "Brand":
        setState(() {
          clonedItem = clonedItem.copyWith(brand: (value as String).trim());
        });
        break;
      case "Category":
        setState(() {
          clonedItem = clonedItem.copyWith(category: (value as String).trim());
        });
        break;
    }
  }
}

class PanelEditableModifier extends StatefulWidget {
  final ModificationButton? button;
  final int index;
  final void Function(ModificationButton?)? onChange;

  const PanelEditableModifier({
    Key? key,
    this.button,
    required this.index,
    this.onChange,
  }) : super(key: key);

  @override
  _PanelEditableModifierState createState() => _PanelEditableModifierState();
}

class _PanelEditableModifierState extends State<PanelEditableModifier> {
  late ModificationButton? button;

  @override
  void initState() {
    super.initState();
    button = widget.button;
  }

  @override
  Widget build(BuildContext context) {
    return ModificationButtonPreview(
      modifier: button,
      textColor: Colors.white,
      size: (button == null ? const Size(60, 55) : const Size(80, 75)),
      onTap: () async {
        ModificationButton? changedButton = await getModificationButtonFromBuilder(
          context,
          button ??
              ModificationButton(
                name: "NAME",
                data: [],
                dataType: ModificationButtonDataType.text,
                side: ModificationButtonSide.values[widget.index],
              ),
          button == null,
        );
        if (widget.onChange != null) widget.onChange!(changedButton);
        setState(() {});
      },
    );
  }

  Future<ModificationButton?> getModificationButtonFromBuilder(
    BuildContext context,
    ModificationButton changedButton,
    bool newButton,
  ) async {
    Completer<ModificationButton?> completer = Completer();
    ModificationButton modifiedButton = changedButton.copyWith();

    showDialog(
        context: context,
        builder: (ctx) {
          return ItemModifierEditorDialog(
            button: modifiedButton,
            onComplete: (btn) {
              completer.complete(btn);
            },
            isNewButton: newButton,
          );
        });

    return completer.future;
  }
}

class ItemModifierEditorDialog extends StatefulWidget {
  final bool isNewButton;
  final ModificationButton button;
  final void Function(ModificationButton?)? onComplete;

  const ItemModifierEditorDialog({
    Key? key,
    required this.button,
    this.isNewButton = false,
    this.onComplete,
  }) : super(key: key);

  @override
  _ItemModifierEditorDialogState createState() => _ItemModifierEditorDialogState();
}

class _ItemModifierEditorDialogState extends State<ItemModifierEditorDialog> {
  late ModificationButton _modifiedButton;
  late ModificationButtonDataType originalDataType;

  @override
  void initState() {
    super.initState();

    _modifiedButton = widget.button.copyWith();
    originalDataType = _modifiedButton.dataType;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ModificationButtonSelectorPreview(
            button: _modifiedButton,
            onDataPress: (index) async {
              setState(() {
                _modifiedButton.data.removeAt(index);
              });
            },
            onAddPress: () async {
              Completer<Object?> completer = Completer();
              var dialog = ValueDialog(
                "Enter modifier data",
                _modifiedButton.dataType.toTitle(),
                completer,
                isNumber: _modifiedButton.dataType == ModificationButtonDataType.color,
                size: Size(70.w, 20.h),
                miscContentBefore: (ctx, _setState, state) {
                  return Align(
                    alignment: Alignment.topLeft,
                    child: Row(
                      children: [
                        Text('Data type:  ', style: Theme.of(context).textTheme.headline4?.copyWith(fontSize: 14.sp, fontWeight: FontWeight.normal)),
                        DropdownButton<ModificationButtonDataType>(
                          style: Theme.of(context).textTheme.subtitle1?.copyWith(fontSize: 12.sp),
                          value: _modifiedButton.dataType,
                          items: ModificationButtonDataType.values
                              .map(
                                (e) => DropdownMenuItem<ModificationButtonDataType>(
                                  value: e,
                                  child: Text(e.toTitle()),
                                ),
                              )
                              .toList(),
                          onChanged: (val) {
                            if (val == null) return;
                            if (val != originalDataType) {
                              ScaffoldMessenger.of(ctx).clearSnackBars();
                              ScaffoldMessenger.of(ctx)
                                  .showSnackBar(SnackBar(content: Text('WARNING: Changing the data type will remove all modifier data.')));
                            }
                            setState(() {
                              _modifiedButton = _modifiedButton.copyWith(dataType: val);
                            });
                            _setState(() {
                              state.labelText = _modifiedButton.dataType.toTitle();
                              state.validator = _modifiedButton.dataType == ModificationButtonDataType.color
                                  ? ValidationBuilder().add((value) => int.tryParse(value ?? "f") != null ? null : "Must be an integer.")
                                  : _modifiedButton.dataType == ModificationButtonDataType.text
                                      ? ValidationBuilder().minLength(1).maxLength(7)
                                      : ValidationBuilder().minLength(5);
                              state.isNumber = _modifiedButton.dataType == ModificationButtonDataType.color;
                            });
                          },
                        ),
                      ],
                    ),
                  );
                },
              );

              showDialog(context: context, builder: (ctx) => dialog);
              Object? val = await completer.future;
              if (val == null) {
                return;
              }

              if (originalDataType != _modifiedButton.dataType) {
                _modifiedButton.data.clear();
              }

              _modifiedButton.data.add(val);
              originalDataType = _modifiedButton.dataType;
              setState(() {});
              //Navigator.pop(context);
            },
          ),
          SizedBox(height: 10),
          ModificationButtonPreview(
            modifier: _modifiedButton,
            backgroundColor: Colors.white,
            size: Size(80, 75),
            onTap: () async {
              Completer<String?> completer = Completer();
              var dialog = ValueDialog(
                'Change modifier name',
                'Name',
                completer,
                minLength: 1,
                maxLength: 6,
              );

              showDialog(context: context, builder: (ctx) => dialog);
              String? newName = await completer.future;
              if (newName == null) return;
              setState(() {
                _modifiedButton = _modifiedButton.copyWith(name: newName.trim());
              });
            },
          ),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(width: 5),
              buildButton('Delete', primaryComplementaryColor, onTap: () {
                if (widget.onComplete != null) widget.onComplete!(null);
                Navigator.of(context).pop();
              }),
              buildButton('Change', fillerColor, onTap: () {
                if (widget.onComplete != null) widget.onComplete!(_modifiedButton);
                Navigator.of(context).pop();
              }),
            ],
          ),
          SizedBox(height: 10),
          buildButton('Cancel', fillerColor, onTap: () {
            Navigator.of(context).pop();
          }),
        ],
      ),
    );
  }

  Widget buildButton(
    String text,
    Color color, {
    VoidCallback? onTap,
  }) {
    return TextButton(
      style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all(color),
          padding: MaterialStateProperty.all(EdgeInsets.all(15)),
          elevation: MaterialStateProperty.all(5),
          overlayColor: MaterialStateProperty.all(Colors.white.withOpacity(0.6))),
      onPressed: onTap,
      child: Text(
        text,
        style: Theme.of(context).textTheme.headline4?.copyWith(fontSize: 16.sp, color: Colors.white),
      ),
    );
  }
}
