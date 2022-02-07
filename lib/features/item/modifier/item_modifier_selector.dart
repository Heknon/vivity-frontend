import 'dart:math';

import 'package:fade_in_widget/fade_in_widget.dart';
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
  final double heightScale;

  final bool allowMultiSelect;

  final ItemModifierSelectorController? controller;

  const ItemModifierSelector({
    Key? key,
    required this.selectableData,
    required this.dataType,
    this.padding = const EdgeInsets.all(0),
    this.itemPadding = const EdgeInsets.all(8),
    this.textSize = 14,
    this.colorSize = 18,
    this.imageRadius = 9,
    this.sizeScale = 9,
    this.allowMultiSelect = false,
    this.controller,
    this.heightScale = 30,
  }) : super(key: key);

  @override
  _ItemModifierSelectorState createState() => _ItemModifierSelectorState();
}

class _ItemModifierSelectorState extends State<ItemModifierSelector> {
  late ItemModifierSelectorController _controller;

  @override
  void initState() {
    _controller = widget.controller ?? ItemModifierSelectorController();

    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = _widgetSize;

    return AnimatedOpacity(
      opacity: _controller.isShown ? 1 : 0,
      duration: Duration(milliseconds: 300),
      child: BlocConsumer(
        bloc: BlocProvider.of<ItemModifierBloc>(context),
        listener: (ctx, ItemModifierState state) {
          _controller.updateChosenIndices(state);
        },
        builder: (ctx, ItemModifierState state) {
          return buildSelector(context, size, state.chosenIndices);
        },
      ),
    );
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

    return SizedBox(
      width: size.width,
      height: size.height,
      child: Material(
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
      ),
    );
  }

  double get selectableItemSize => widget.dataType == ModificationButtonDataType.text
      ? widget.textSize
      : widget.dataType == ModificationButtonDataType.color
          ? widget.colorSize
          : widget.imageRadius * 2;

  Size get _widgetSize => Size(
        (widget.sizeScale + 6).h,
        widget.heightScale.sp,
      );
}

class ItemModifierSelectorController extends ChangeNotifier {
  bool isShown = false;
  DateTime? lastToggle;
  Set<int> chosenIndices = {};
  Size? size;

  void toggle() {
    isShown = !isShown;
    lastToggle = DateTime.now();
    notifyListeners();
  }

  void updateChosenIndices(ItemModifierState state) {
    chosenIndices = state.chosenIndices;
    notifyListeners();
  }
}
