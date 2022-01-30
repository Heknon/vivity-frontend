import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sizer/sizer.dart';
import 'package:vivity/features/item/models/item_model.dart';
import 'package:vivity/features/item/modifier/bloc/item_modifier_bloc.dart';

import 'item_modifier_service.dart';

class ItemModifierSelectorOverlay {
  final List<Object> selectableData;
  final ModificationButtonDataType dataType;

  final EdgeInsets padding;

  final double textSize;
  final double colorSize;
  final double imageRadius;
  final double sizeScale;

  final bool allowMultiSelect;

  bool isShown = false;

  OverlayEntry? _entry;

  ItemModifierSelectorOverlay({
    required this.selectableData,
    required this.dataType,
    this.padding = const EdgeInsets.all(0),
    this.textSize = 14,
    this.colorSize = 18,
    this.imageRadius = 9,
    this.sizeScale = 9,
    this.allowMultiSelect = false,
  });

  void toggle(BuildContext context) {
    if (isShown) {
      _entry?.remove();
    } else {
      _entry = _buildOverlay(context);
      Overlay.of(context)?.insert(_entry!);
    }

    isShown = !isShown;
  }

  void dispose() {
    if (_entry != null) _entry?.dispose();
  }

  OverlayEntry _buildOverlay(BuildContext context) {
    RenderBox renderBox = context.findRenderObject() as RenderBox;
    Offset offset = renderBox.localToGlobal(Offset.zero);
    Size boxSize = renderBox.size;

    Size size = _widgetSize;

    return OverlayEntry(
      builder: (ctx) => BlocBuilder(
        bloc: BlocProvider.of<ItemModifierBloc>(context),
        builder: (ctx, ItemModifierState state) {
          return Positioned(
            width: size.width,
            height: size.height,
            left: offset.dx - size.width / 2 + boxSize.width / 2,
            top: offset.dy - size.height - padding.vertical,
            child: NotificationListener(
              onNotification: (SizeChangedLayoutNotification e) {
                size = _widgetSize;
                return true;
              },
              child: SizeChangedLayoutNotifier(
                child: buildSelector(context, size, state.chosenIndices),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget buildSelector(BuildContext context, Size size, Set<int> chosenIndices) {
    List<Widget> selectionList = buildSelectionList(
      context,
      dataType,
      selectableData,
      spacingBuilder: (ctx, idx) => SizedBox(
        width: padding.right,
      ),
      includeInkWell: false,
    );

    List<Widget> bakedSelectionList = List.empty(growable: true);
    Size size = _widgetSize;

    int index = 0;
    for (var element in selectionList) {
      if (element is SizedBox) {
        bakedSelectionList.add(element);
        continue;
      }
      final int idx = index;

      bakedSelectionList.add(Center(
        child: Material(
          color: Colors.white,
          child: Container(
            decoration: chosenIndices.contains(idx) ? BoxDecoration(
              //borderRadius: const BorderRadius.all(Radius.circular(100)),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.6),
                  blurRadius: 7,
                  spreadRadius: 2,
                  offset: Offset(0, 3), // changes position of shadow
                ),
              ],
            ) : null,
            child: InkWell(
              borderRadius: const BorderRadius.all(Radius.circular(50)),
              onTap: () {
                chosenIndices.contains(idx)
                    ? BlocProvider.of<ItemModifierBloc>(context).add(ItemModifierRemoveItemEvent(idx))
                    : BlocProvider.of<ItemModifierBloc>(context).add(ItemModifierAddItemEvent(idx));
              },
              child: element,
            ),
          ),
        ),
      ));
      index++;
    }

    return Material(
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(20))),
      color: Colors.white,
      clipBehavior: Clip.antiAlias,
      elevation: 7,
      child: Container(
        padding: EdgeInsets.only(left: padding.left, right: padding.right),
        height: size.height,
        width: size.width,
        child: Center(
          child: ListView(
            shrinkWrap: true,
            scrollDirection: Axis.horizontal,
            children: bakedSelectionList,
          ),
        ),
      ),
    );
  }

  double get selectableItemSize => dataType == ModificationButtonDataType.text
      ? textSize
      : dataType == ModificationButtonDataType.color
          ? colorSize
          : imageRadius * 2;

  Size get _widgetSize => Size(
        min(selectableItemSize * selectableData.length + padding.right * (selectableData.length - 1) + padding.horizontal * 2, (sizeScale + 13).h),
        30.sp,
      );
}
