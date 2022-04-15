import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sizer/sizer.dart';
import 'package:vivity/features/item/models/modification_button.dart';
import 'package:vivity/features/item/modifier/bloc/item_modifier_bloc.dart';
import 'package:vivity/features/item/modifier/item_modifier_container.dart';
import 'package:vivity/features/item/modifier/item_modifier_selector.dart';

class ItemModifier extends StatefulWidget {
  final ModificationButton modificationButton;
  final double imageRadius;
  final double colorSize;
  final double textSize;
  final double separatingHeight;

  final ItemModifierSelectorController? selectorController;

  const ItemModifier({
    Key? key,
    required this.modificationButton,
    this.imageRadius = 9,
    this.colorSize = 18,
    this.textSize = 14,
    this.separatingHeight = 10,
    this.selectorController,
  }) : super(key: key);

  @override
  State<ItemModifier> createState() => _ItemModifierState();
}

class _ItemModifierState extends State<ItemModifier> {
  late ItemModifierSelectorController _selectorController;
  double sizeScale = 9;
  double? maxWidth;

  @override
  void initState() {
    _selectorController = widget.selectorController ?? ItemModifierSelectorController();

    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  bool shouldShow = true;

  @override
  Widget build(BuildContext context) {
    double heightFactor = 30;

    Size modifierContainerSize = Size(70, 70);
    Size size = Size(modifierContainerSize.width, heightFactor.sp + modifierContainerSize.height + widget.separatingHeight);

    return SizedBox(
      width: (sizeScale + 6).h,
      height: size.height,
      child: BlocProvider(
        create: (_) => ItemModifierBloc(),
        child: Stack(
          alignment: Alignment.topCenter,
          children: [
            Positioned(
              top: 0,
              child: ItemModifierSelector(
                selectableData: widget.modificationButton.data,
                dataType: widget.modificationButton.dataType,
                sizeScale: sizeScale,
                multiSelect: widget.modificationButton.multiSelect,
                controller: _selectorController,
                heightScale: heightFactor,
                padding: EdgeInsets.only(bottom: 7, right: 4, left: 4),
              ),
            ),
            Positioned(
              bottom: 0,
              height: modifierContainerSize.height,
              width: modifierContainerSize.width,
              child: InkWell(
                onTap: _selectorController.toggle,
                child: ItemModifierContainer(
                  selectableData: widget.modificationButton.data,
                  dataType: widget.modificationButton.dataType,
                  name: widget.modificationButton.name,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
