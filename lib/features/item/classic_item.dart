import 'dart:io';
import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import 'package:vivity/features/item/like_button.dart';
import 'package:vivity/features/item/ui_item_helper.dart';
import 'package:vivity/features/user/bloc/user_bloc.dart';
import 'package:vivity/services/item_service.dart';
import 'package:vivity/widgets/simple_card.dart';
import 'item_page.dart';
import 'background_image.dart';
import 'package:vivity/widgets/rating.dart';

import 'models/item_model.dart';

class ClassicItem extends StatefulWidget {
  final ItemModel item;
  final Size? size;

  ClassicItem({
    Key? key,
    required this.item,
    this.size,
  }) : super(key: key);

  @override
  State<ClassicItem> createState() => _ClassicItemState();
}

class _ClassicItemState extends State<ClassicItem> {
  late LikeButtonController _likeButtonController;
  Future<Map<String, File>?>? itemImages;

  @override
  void initState() {
    super.initState();
    _likeButtonController = LikeButtonController();
  }

  @override
  Widget build(BuildContext context) {
    UserState state = context.read<UserBloc>().state;
    if (state is! UserLoggedInState) return Text('You need to be logged in to see items.');

    itemImages ??= getCachedItemImages(state.token, List.of([widget.item]));

    bool initialLiked = false;
    for (var element in state.likedItems) {
      if (element.id == widget.item.id) initialLiked = true;
    }

    _likeButtonController.setLiked(initialLiked);

    return LayoutBuilder(builder: (ctx, constraints) {
      Size size = widget.size ?? Size(constraints.maxWidth, constraints.maxHeight);
      return GestureDetector(
        onTap: () => _onTap(context),
        child: SimpleCard(
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
                    child: buildPreviewImage(
                      itemImages,
                      widget.item,
                      size: size,
                      borderRadius: const BorderRadius.only(topLeft: Radius.circular(7), topRight: Radius.circular(7)),
                    )),
                Padding(
                  padding: EdgeInsets.all(5),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        child: Text(
                          "idsjfiosndofinisonfidsnfdsnfiosndfidsifndsiogisgnsiogiosngnogisndigsd",
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
                      Rating.fromReviews(widget.item.reviews)
                    ],
                  ),
                ),
                Spacer(),
                Padding(
                  padding: const EdgeInsets.only(left: 5, bottom: 2, right: 5),
                  child: Row(
                    children: [
                      Text(
                        "\$${widget.item.price.toStringAsFixed(2)}",
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontFamily: "Hezaedrus",
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Spacer(),
                      buildDatabaseLikeButton(widget.item.id, _likeButtonController, context, initialLiked),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  void _onTap(BuildContext context) {
    Navigator.push(context, MaterialPageRoute(builder: (ctx) => ItemPage(item: widget.item)));
  }
}
