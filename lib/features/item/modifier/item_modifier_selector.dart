import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sizer/sizer.dart';
import 'package:vivity/features/item/models/item_model.dart';
import 'package:vivity/features/item/modifier/bloc/item_modifier_bloc.dart';

import 'item_modifier_service.dart';

class ItemModifierSelector extends StatefulWidget {
  final List<Object> selectableData;
  final ModificationButtonDataType dataType;

  final EdgeInsets padding;
  final EdgeInsets itemPadding;

  final double textSize;
  final double colorSize;
  final double imageRadius;
  final double sizeScale;

  final bool allowMultiSelect;

  final ItemModifierSelectorController? controller;

  const ItemModifierSelector({
    Key? key,
    required this.selectableData,
    required this.dataType,
    this.padding = const EdgeInsets.only(bottom: 8),
    this.itemPadding = const EdgeInsets.all(8),
    this.textSize = 14,
    this.colorSize = 18,
    this.imageRadius = 9,
    this.sizeScale = 9,
    this.allowMultiSelect = false,
    this.controller,
  }) : super(key: key);

  @override
  _ItemModifierSelectorState createState() => _ItemModifierSelectorState();
}

class _ItemModifierSelectorState extends State<ItemModifierSelector> {
  late ItemModifierSelectorController _controller;

  @override
  void initState() {
    _controller = widget.controller ?? ItemModifierSelectorController();
    _controller.addListener(() {
      setState(() {});
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size size = _widgetSize;

    return _controller.isShown
        ? Padding(
            padding: widget.padding,
            child: BlocBuilder(
              bloc: BlocProvider.of<ItemModifierBloc>(context),
              builder: (ctx, ItemModifierState state) {
                return NotificationListener(
                  onNotification: (SizeChangedLayoutNotification event) {
                    size = _widgetSize;
                    return true;
                  },
                  child: SizeChangedLayoutNotifier(
                    child: buildSelector(context, size, state.chosenIndices),
                  ),
                );
              },
            ),
          )
        : const SizedBox();
  }

  Widget buildSelector(BuildContext context, Size size, Set<int> chosenIndices) {
    List<Widget> selectionList = buildSelectionList(
      context,
      widget.dataType,
      widget.selectableData,
      wrapperBuilder: (ctx, child, idx) => Padding(
        padding: widget.itemPadding,
        child: Material(
          color: Colors.white,
          child: Container(
            decoration: chosenIndices.contains(idx)
                ? BoxDecoration(
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
                  )
                : null,
            child: InkWell(
              borderRadius: const BorderRadius.all(Radius.circular(50)),
              onTap: () {
                chosenIndices.contains(idx)
                    ? BlocProvider.of<ItemModifierBloc>(context).add(ItemModifierRemoveItemEvent(idx))
                    : BlocProvider.of<ItemModifierBloc>(context).add(ItemModifierAddItemEvent(idx));
              },
              child: child,
            ),
          ),
        ),
      ),
    );

    return Material(
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(20))),
      color: Colors.white,
      clipBehavior: Clip.antiAlias,
      elevation: 7,
      child: Center(
        child: ListView(
          shrinkWrap: true,
          scrollDirection: Axis.horizontal,
          children: selectionList,
        ),
      ),
    );
  }

  double get selectableItemSize => widget.dataType == ModificationButtonDataType.text
      ? widget.textSize
      : widget.dataType == ModificationButtonDataType.color
          ? widget.colorSize
          : widget.imageRadius * 2;

  Size get _widgetSize => Size(
        min(10, (widget.sizeScale + 13).h),
        30.sp,
      );
}

class ItemModifierSelectorController extends ChangeNotifier {
  bool isShown = false;

  void toggle() {
    isShown = !isShown;
    notifyListeners();
  }
}
