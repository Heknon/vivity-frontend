import 'dart:io';
import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import 'package:vivity/features/user/bloc/user_bloc.dart';
import 'package:vivity/services/item_service.dart';
import 'package:vivity/widgets/simple_card.dart';
import 'item_page.dart';
import 'background_image.dart';
import 'package:vivity/widgets/rating.dart';

import 'models/item_model.dart';

class ClassicItem extends StatelessWidget {
  final ItemModel item;
  Future<Map<String, File>?>? itemImages;
  final Size? size;

  ClassicItem({
    Key? key,
    required this.item,
    this.size,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    UserState state = context.read<UserBloc>().state;
    if (state is! UserLoggedInState) return Text('You need to be logged in to see items.');

    itemImages ??= getCachedItemImages(state.token, List.of([item]));

    return LayoutBuilder(builder: (ctx, constraints) {
      Size size = this.size ?? Size(constraints.maxWidth, constraints.maxHeight);

      return SimpleCard(
        elevation: 7,
        borderRadius: const BorderRadius.all(Radius.circular(7)),
        child: Padding(
          padding: EdgeInsets.all(1),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: size.height * 0.65,
                width: size.width,
                child: FutureBuilder(
                  future: itemImages,
                  builder: (ctx, snapshot) {
                    if (!snapshot.hasData) {
                      return CircularProgressIndicator();
                    }

                    Map<String, File>? data = snapshot.data as Map<String, File>?;
                    if (data == null) return const Text('Error getting image');

                    return ClipRRect(
                      borderRadius: const BorderRadius.only(topLeft: Radius.circular(7), topRight: Radius.circular(7)),
                      child: Container(
                        color: Colors.white,
                        child: Image.file(
                          data[item.images[item.previewImageIndex]]!,
                          height: size.height * 0.65,
                        ),
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: EdgeInsets.all(5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      child: Text(
                        item.itemStoreFormat.title,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.outfit(
                          fontWeight: FontWeight.normal,
                          height: 1,
                          fontSize: 14.sp,
                        ),
                      ),
                      width: size.width * 0.7,
                    ),
                    Rating.fromReviews(item.reviews)
                  ],
                ),
              ),
              Spacer(),
              Padding(
                padding: const EdgeInsets.all(5.0),
                child: Text(
                  "\$${item.price.toStringAsFixed(2)}",
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontFamily: "Hezaedrus",
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  void _onTap(BuildContext context) {
    Navigator.push(context, MaterialPageRoute(builder: (ctx) => ItemPage(itemModel: item)));
  }
}
