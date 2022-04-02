import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:vivity/features/item/models/item_model.dart';
import 'package:vivity/widgets/preview_dialog.dart';

Iterable<Widget> buildImageDataType(ModificationButtonDataHost e, {double radius = 5.25}) {
  return e.selectedData.map(
    (d) => Padding(
      padding: const EdgeInsets.only(left: 3.0),
      child: buildImageCircle(e.name, d as String),
    ),
  );
}

Iterable<Widget> buildColoredDataType(BuildContext context, ModificationButtonDataHost e) {
  return e.selectedData.map(
    (d) {
      return Padding(
        padding: const EdgeInsets.only(left: 3.0),
        child: buildColoredCircle(context, e.name, Color(d as int)),
      );
    },
  );
}

Widget buildColoredCircle(
  BuildContext ctx,
  String? title,
  Color color, {
  double size = 10.5,
  bool includeInkWell = true,
  VoidCallback? onTap,
}) {
  return includeInkWell
      ? InkWell(
          onTap: onTap ??
              () => title != null
                  ? showDialog(
                      context: ctx,
                      builder: (ctx) => PreviewDialog(
                        title: title,
                        content: Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(color: color, borderRadius: BorderRadius.all(Radius.circular(8))),
                        ),
                      ),
                    )
                  : null,
          child: Container(
            width: size.sp,
            height: size.sp,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
        )
      : Container(
          width: size.sp,
          height: size.sp,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        );
}

Widget buildImageCircle(
  String? title,
  String url, {
  double radius = 5.25,
  bool includeInkWell = true,
  VoidCallback? onTap,
}) {
  return CachedNetworkImage(
    imageUrl: url,
    imageBuilder: (ctx, prov) => includeInkWell
        ? InkWell(
            onTap: onTap != null ? onTap : title != null
                ? () => showDialog(
                      context: ctx,
                      builder: (ctx) => PreviewDialog(
                        title: title,
                        content: Image(image: prov),
                      ),
                    )
                : null,
            child: CircleAvatar(
              radius: radius.sp,
              foregroundImage: prov,
            ),
          )
        : CircleAvatar(
            radius: radius.sp,
            foregroundImage: prov,
          ),
  );
}
