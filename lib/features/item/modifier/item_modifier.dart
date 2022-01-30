import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sizer/sizer.dart';
import 'package:vivity/features/item/models/item_model.dart';
import 'package:vivity/features/item/modifier/bloc/item_modifier_bloc.dart';
import 'package:vivity/features/item/modifier/item_modifier_container.dart';
import 'package:vivity/features/item/modifier/item_modifier_selector_overlay.dart';
import 'package:vivity/helpers/item_data_helper.dart';

import 'item_modifier_service.dart';

class ItemModifier extends StatefulWidget {
  final ModificationButton modificationButton;
  final double imageRadius;
  final double colorSize;
  final double textSize;
  final double selectableItemPadding;
  final double overlaySpacing;

  const ItemModifier({
    Key? key,
    required this.modificationButton,
    this.imageRadius = 9,
    this.colorSize = 18,
    this.textSize = 14,
    this.selectableItemPadding = 8,
    this.overlaySpacing = 10,
  }) : super(key: key);

  @override
  State<ItemModifier> createState() => _ItemModifierState();
}

class _ItemModifierState extends State<ItemModifier> {
  late ItemModifierSelectorOverlay _modifierSelectorOverlay;
  double sizeScale = 9;

  @override
  void initState() {
    super.initState();
    _modifierSelectorOverlay = ItemModifierSelectorOverlay(
        selectableData: widget.modificationButton.data,
        dataType: widget.modificationButton.dataType,
        sizeScale: sizeScale,
        padding: EdgeInsets.only(bottom: 7, right: 4, left: 4));
  }

  @override
  void dispose() {
    _modifierSelectorOverlay.dispose();

    super.dispose();
  }

  bool shouldShow = true;

  @override
  Widget build(BuildContext context) {
    double screenScalePercent = 7.5;

    Size barSize = Size(140, (screenScalePercent - 2).h);
    Size modifierContainerSize = Size(screenScalePercent.h, screenScalePercent.h);
    Size size = Size(barSize.width + modifierContainerSize.width, barSize.height + modifierContainerSize.height);

    return SizedBox(
      width: size.width,
      height: size.height,
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (shouldShow) Positioned(
            top: 0,
            height: barSize.height,
            width: barSize.width,
            child: Container(
              color: Colors.red,
            ),
          ),
          Positioned(
            bottom: 0,
            height: modifierContainerSize.height,
            width: modifierContainerSize.width,
            child: Container(
              color: Colors.blue,
            ),
          ),
        ],
      ),
    );

    return BlocProvider(
      create: (_) => ItemModifierBloc(),
      child: Builder(builder: (ctx) {
        return InkWell(
          onTap: () => _modifierSelectorOverlay.toggle(ctx),
          child: ItemModifierContainer(
            selectableData: widget.modificationButton.data,
            dataType: widget.modificationButton.dataType,
            name: widget.modificationButton.name,
          ),
        );
      }),
    );
  }
}
