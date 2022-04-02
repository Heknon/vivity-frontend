import 'dart:io';
import 'dart:typed_data';
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
import '../../config/themes/themes_config.dart';
import 'item_page.dart';
import 'background_image.dart';
import 'package:vivity/widgets/rating.dart';

import 'models/item_model.dart';

class ClassicItem extends StatefulWidget {
  final ItemModel item;
  final Size? size;
  final bool editButton;
  final VoidCallback? onEditTap;
  final VoidCallback? onTap;
  final VoidCallback? onLongTap;

  const ClassicItem({
    Key? key,
    required this.item,
    this.size,
    this.editButton = false,
    this.onEditTap,
    this.onTap,
    this.onLongTap,
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
    if (!widget.editButton) _likeButtonController = LikeButtonController();
  }

  @override
  Widget build(BuildContext context) {
    UserState state = context.read<UserBloc>().state;
    if (state is! UserLoggedInState) return Text('You need to be logged in to see items.');

    itemImages ??= getCachedItemImages(state.token, List.of([widget.item]));

    bool initialLiked = false;
    if (!widget.editButton) {
      for (var element in state.likedItems) {
        if (element.id == widget.item.id) initialLiked = true;
      }

      _likeButtonController.setLiked(initialLiked);
    }

    return LayoutBuilder(builder: (ctx, constraints) {
      Size size = widget.size ?? Size(constraints.maxWidth, constraints.maxHeight);
      return SimpleCard(
        elevation: 7,
        onTap: widget.onTap,
        onLongTap: widget.onLongTap,
        splashFactory: InkRipple.splashFactory,
        borderRadius: const BorderRadius.all(Radius.circular(7)),
        child: Padding(
          padding: EdgeInsets.all(1),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                  height: size.height * 0.65,
                  width: size.width,
                  child: FutureBuilder<Map<String, Uint8List>?>(
                    future: readImagesBytes(itemImages),
                    builder: (context, snapshot) {
                      return buildPreviewImage(
                        snapshot.data,
                        widget.item,
                        size: size,
                        borderRadius: const BorderRadius.only(topLeft: Radius.circular(7), topRight: Radius.circular(7)),
                      );
                    }
                  )),
              Padding(
                padding: EdgeInsets.all(5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      child: Text(
                        widget.item.itemStoreFormat.title,
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
                    !widget.editButton
                        ? buildDatabaseLikeButton(
                            widget.item,
                            _likeButtonController,
                            context,
                            initialLiked,
                            color: primaryComplementaryColor,
                            backgroundColor: Colors.transparent,
                            splashColor: Colors.grey[600]!.withOpacity(0.6),
                            borderRadius: const BorderRadius.all(Radius.circular(15)),
                            padding: const EdgeInsets.all(4),
                          )
                        : IconButton(
                            padding: EdgeInsets.zero,
                            constraints: BoxConstraints(),
                            onPressed: widget.onEditTap,
                            icon: Icon(
                              Icons.edit,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}
