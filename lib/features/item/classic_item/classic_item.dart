import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import '../item_page.dart';
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
        onTap: () => _onTap(context),
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
            Container(
              padding: EdgeInsets.only(top: 5),
              height: 12.sp * 2 + 5,
              child: Text(
                itemModel.itemStoreFormat.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.outfit(
                  fontWeight: FontWeight.normal,
                  height: 1,
                  fontSize: 12.sp,
                ),
              ),
            ),
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 5.0),
                  child: Text(
                    "\$${itemModel.price.toStringAsFixed(2)}",
                    style: TextStyle(
                      fontSize: 10.sp,
                      fontFamily: "Hezaedrus",
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Spacer(),
                Rating.fromReviews(itemModel.reviews)
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _onTap(BuildContext context) {
    Navigator.push(context, MaterialPageRoute(builder: (ctx) => ItemPage(itemModel: itemModel)));
  }
}
