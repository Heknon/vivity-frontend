import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import 'background_image.dart';
import 'package:vivity/widgets/rating.dart';

import '../models/item_model.dart';

class ClassicItem extends StatelessWidget {
  final ItemModel itemModel;

  const ClassicItem({Key? key, required this.itemModel}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (ctx, constraints) => GestureDetector(
        onTap: _onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ConstrainedBox(
              constraints: constraints,
              child: BackgroundImage(
                imageUrl: itemModel.images[itemModel.previewImageIndex],
                backgroundColor: const Color(0xfff8f1f1),
              ),
            ),
            buildItemDataView(),
            buildItemCostText(),
            Rating.fromReviews(itemModel.reviews),
          ],
        ),
      ),
    );
  }

  Text buildItemCostText() {
    return Text(
      "\$${itemModel.price.toStringAsFixed(2)}",
      style: TextStyle(
        fontSize: 12.sp,
        fontFamily: "Hezaedrus",
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Row buildItemDataView() {
    return Row(
      children: [
        Text(
          itemModel.itemStoreFormat.title,
          style: GoogleFonts.outfit(fontWeight: FontWeight.normal, fontSize: 13.sp),
        ),
        const Spacer(),
        Text(
          itemModel.businessName,
          style: TextStyle(
            fontFamily: "Hezaedrus",
            fontSize: 10.sp,
            color: Colors.grey[600],
          ),
        )
      ],
    );
  }

  void _onTap() {
    print("open item!");
  }
}
