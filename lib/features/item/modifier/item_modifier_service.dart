import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:vivity/features/item/models/item_model.dart';
import 'package:vivity/helpers/item_data_helper.dart';

List<Widget> buildSelectionList(
  BuildContext context,
  ModificationButtonDataType dataType,
  List<Object> data, {
  Widget Function(BuildContext ctx, int index)? spacingBuilder,
  double textSize = 14,
  double imageRadius = 9,
  double colorSize = 18,
  bool includeInkWell = false,
}) {
  int length = spacingBuilder == null ? data.length : data.length * 2;

  return List.generate(length, (index) {
    if (spacingBuilder != null && index % 2 == 1) {
      return spacingBuilder(context, index ~/ 2);
    }

    Object currentData = data[spacingBuilder == null ? index : index ~/ 2];
    if (dataType == ModificationButtonDataType.text) {
      return includeInkWell ? InkWell(
        child: Text(
          currentData as String,
          style: Theme.of(context).textTheme.headline4!.copyWith(fontSize: textSize.sp),
        ),
      ) : Text(
        currentData as String,
        style: Theme.of(context).textTheme.headline4!.copyWith(fontSize: textSize.sp),
      );
    } else if (dataType == ModificationButtonDataType.color) {
      return buildColoredCircle(context, null, Color(currentData as int), size: colorSize, includeInkWell: includeInkWell);
    } else {
      return buildImageCircle(null, currentData as String, radius: imageRadius, includeInkWell: includeInkWell);
    }
  });
}
