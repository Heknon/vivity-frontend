import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:vivity/config/themes/themes_config.dart';
import 'package:vivity/features/item/models/modification_button.dart';
import 'package:vivity/features/item/models/modification_button_data_type.dart';
import 'package:vivity/features/item/modifier/item_modifier_service.dart';
import 'package:vivity/widgets/simple_card.dart';

import 'modifier/item_modifier_selector.dart';

class ModificationButtonPreview extends StatelessWidget {
  final ModificationButton? modifier;
  final VoidCallback? onTap;
  final Size? size;
  final Color? backgroundColor;
  final Color? textColor;
  final double textSize;

  const ModificationButtonPreview({
    Key? key,
    this.modifier,
    this.onTap,
    this.size,
    this.backgroundColor,
    this.textSize = 15,
    this.textColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool hasData = modifier?.data.isNotEmpty ?? false ? modifier?.data[0] != null : false;
    ModificationButtonDataType dataType = hasData ? modifier?.dataType ?? ModificationButtonDataType.text : ModificationButtonDataType.text;

    return SizedBox.fromSize(
      size: size,
      child: SimpleCard(
        backgroundColor: backgroundColor ?? fillerColor,
        elevation: 7,
        borderRadius: const BorderRadius.all(Radius.circular(7)),
        onTap: onTap,
        child: modifier != null
            ? Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  getDataWidget(
                    hasData
                        ? dataType == ModificationButtonDataType.color
                            ? int.tryParse(modifier?.data[0].toString() ?? '0') ?? 0
                            : modifier?.data[0].toString() ?? "?"
                        : '?',
                    dataType,
                    sizeTypeMap[dataType]!,
                    context,
                    textColor: textColor,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(
                      modifier!.name,
                      overflow: TextOverflow.clip,
                      maxLines: 1,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headline4!.copyWith(
                            fontSize: textSize.sp,
                            color: textColor,
                          ),
                    ),
                  )
                ],
              )
            : Icon(
                Icons.add,
                color: Colors.white,
                size: 24.sp,
              ),
      ),
    );
  }
}

class ModificationButtonSelectorPreview extends StatelessWidget {
  final ModificationButton button;
  final VoidCallback? onAddPress;
  final void Function(int)? onDataPress;

  const ModificationButtonSelectorPreview({
    Key? key,
    required this.button,
    this.onAddPress,
    this.onDataPress,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<Widget> selectionList = buildSelectionList(
      context,
      button.dataType,
      button.dataType == ModificationButtonDataType.color
          ? button.data.map((e) => int.tryParse(e.toString()) ?? 0).toList()
          : button.data.map((e) => e.toString()).toList(),
      wrapperBuilder: (ctx, child, idx) => Padding(
        padding: const EdgeInsets.all(8),
        child: Material(
          color: Colors.white,
          child: InkWell(
            borderRadius: const BorderRadius.all(Radius.circular(50)),
            onTap: () => onDataPress != null ? onDataPress!(idx) : null,
            child: child,
          ),
        ),
      ),
    );
    selectionList.add(Padding(
      padding: const EdgeInsets.all(8),
      child: Material(
        color: Colors.white,
        child: InkWell(
          child: Icon(
            Icons.add,
            color: primaryComplementaryColor,
          ),
          onTap: onAddPress,
        ),
      ),
    ));

    return SizedBox(
      width: _widgetSize.width,
      height: _widgetSize.height,
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

  Size get _widgetSize => Size(
        (modifierSelectorSizeScale + 6).h,
        modifierSelectorHeightScale.sp,
      );
}
