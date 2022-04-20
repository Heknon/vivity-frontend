import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import 'package:vivity/constants/asset_path.dart';
import 'package:vivity/features/like/like_button.dart';
import 'package:vivity/features/like/bloc/liked_bloc.dart';
import 'package:vivity/features/item/ui_item_helper.dart';
import 'package:vivity/features/user/models/user.dart';
import 'package:vivity/features/user/repo/user_repository.dart';
import 'package:vivity/widgets/simple_card.dart';
import '../../config/themes/themes_config.dart';
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
  final UserRepository _userRepository = UserRepository();
  late LikeButtonController _likeButtonController;

  @override
  void initState() {
    super.initState();
    if (!widget.editButton) _likeButtonController = LikeButtonController();
  }

  @override
  Widget build(BuildContext context) {
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
                child: buildPreviewImage(
                  widget.item.previewImage ?? noImageAvailable,
                  size: size,
                  borderRadius: const BorderRadius.only(topLeft: Radius.circular(7), topRight: Radius.circular(7)),
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
                                widget.item.id.hexString,
                                context.read<LikedBloc>(),
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
