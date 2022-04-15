import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:vivity/features/item/models/item_model.dart';
import 'package:vivity/features/item/models/modification_button_data_type.dart';
import 'package:vivity/helpers/item_data_helper.dart';

const double modifierTextSize = 14;
const double modifierImageRadius = 9;
const double modifierColorSize = 18;
const Map<ModificationButtonDataType, double> sizeTypeMap = {
  ModificationButtonDataType.color: modifierColorSize,
  ModificationButtonDataType.image: modifierImageRadius,
  ModificationButtonDataType.text: modifierTextSize,
};

List<Widget> buildSelectionList(
  BuildContext context,
  ModificationButtonDataType dataType,
  List<Object> data, {
  Widget Function(BuildContext ctx, int index)? spacingBuilder,
  Widget Function(BuildContext ctx, Widget wrapped, int index)? wrapperBuilder,
  double textSize = modifierTextSize,
  double imageRadius = modifierImageRadius,
  double colorSize = modifierColorSize,
  bool includeInkWell = false,
}) {
  Map<ModificationButtonDataType, double> sizeTypeMap = getTypeSizeMap(textSize: textSize, imageRadius: imageRadius, colorSize: colorSize);
  int length = spacingBuilder == null ? data.length : data.length * 2;

  return List.generate(length, (index) {
    if (spacingBuilder != null && index % 2 == 1) {
      return spacingBuilder(context, index ~/ 2);
    }

    Object currentData = data[spacingBuilder == null ? index : index ~/ 2];
    Widget res = getDataWidget(currentData, dataType, sizeTypeMap[dataType]!, context);

    return wrapperBuilder != null ? wrapperBuilder(context, res, spacingBuilder == null ? index : index ~/ 2) : res;
  });
}

Map<ModificationButtonDataType, double> getTypeSizeMap({
  double textSize = 14,
  double imageRadius = 9,
  double colorSize = 18,
}) {
  return {
    ModificationButtonDataType.color: colorSize,
    ModificationButtonDataType.image: imageRadius,
    ModificationButtonDataType.text: textSize,
  };
}

Widget getDataWidget(
  Object data,
  ModificationButtonDataType dataType,
  double size,
  BuildContext context, {
  bool includeInkWell = false,
  VoidCallback? onTap,
  Color? textColor,
}) {
  Widget result;

  if (dataType == ModificationButtonDataType.text) {
    result = includeInkWell
        ? InkWell(
            child: Text(
              data as String,
              style: Theme.of(context).textTheme.headline4!.copyWith(fontSize: size.sp, color: textColor),
            ),
          )
        : Text(
            data as String,
            style: Theme.of(context).textTheme.headline4!.copyWith(fontSize: size.sp, color: textColor),
          );
  } else if (dataType == ModificationButtonDataType.color) {
    result = buildColoredCircle(context, null, Color(data as int), size: size, includeInkWell: includeInkWell, onTap: onTap);
  } else {
    result = buildImageCircle(null, data as String, radius: size, includeInkWell: includeInkWell, onTap: onTap);
  }

  return result;
}
