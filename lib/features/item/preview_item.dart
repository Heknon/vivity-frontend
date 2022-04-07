import 'dart:io';
import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sizer/sizer.dart';
import 'package:vivity/features/explore/explore.dart';
import 'package:vivity/features/item/item_page.dart';
import 'package:vivity/features/item/like_button.dart';
import 'package:vivity/features/item/ui_item_helper.dart';
import 'package:vivity/widgets/rating.dart';
import 'package:vivity/widgets/simple_card.dart';

import '../../config/themes/themes_config.dart';
import '../../services/item_service.dart';
import '../user/bloc/user_bloc.dart';
import 'models/item_model.dart';

class PreviewItem extends StatefulWidget {
  final Size? size;
  final ItemModel item;
  Future<Map<String, File>?>? itemImages;

  PreviewItem({Key? key, this.size, required this.item, this.itemImages}) : super(key: key);

  @override
  State<PreviewItem> createState() => _PreviewItemState();
}

class _PreviewItemState extends State<PreviewItem> {
  late LikeButtonController likeController;

  @override
  void initState() {
    super.initState();
    likeController = LikeButtonController();
  }

  @override
  Widget build(BuildContext context) {
    UserState state = context.read<UserBloc>().state;
    if (state is! UserLoggedInState) return Text('You need to be logged in to see items.');

    widget.itemImages ??= getCachedItemImages(state.accessToken, List.of([widget.item]));

    return LayoutBuilder(builder: (context, constraints) {
      double usedWidth = widget.size?.width ?? constraints.maxWidth;
      double usedHeight = widget.size?.height ?? constraints.maxHeight;
      UserState userState = context.read<UserBloc>().state;
      bool initialLiked = false;

      if (userState is! UserLoggedInState) return Text('You need to be logged in.');

      for (var element in userState.likedItems) {
        if (element.id == widget.item.id) initialLiked = true;
      }

      likeController.setLiked(initialLiked);
      return SizedBox(
        height: usedHeight,
        width: usedWidth,
        child: SimpleCard(
          elevation: 7,
          borderRadius: const BorderRadius.all(Radius.circular(15)),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                height: usedHeight,
                width: usedWidth * 0.4,
                padding: const EdgeInsets.only(top: 5, bottom: 5, left: 8, right: 12),
                child: FutureBuilder<Map<String, Uint8List>?>(
                  future: readImagesBytes(widget.itemImages),
                  builder: (context, snapshot) {
                    return buildPreviewImage(snapshot.data, widget.item, borderRadius: const BorderRadius.all(Radius.circular(15)));
                  }
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.only(top: 6, bottom: 6),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.item.itemStoreFormat.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.headline4!.copyWith(fontSize: 14.sp),
                      ),
                      SizedBox(height: 2),
                      Spacer(),
                      Rating.fromReviews(
                        widget.item.reviews,
                        fontSize: 10,
                      ),
                    ],
                  ),
                ),
              ),
              Spacer(),
              Padding(
                padding: const EdgeInsets.only(right: 5, top: 5, bottom: 5),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    buildDatabaseLikeButton(
                      widget.item,
                      likeController,
                      context,
                      initialLiked,
                      color: primaryComplementaryColor,
                      backgroundColor: Colors.transparent,
                      splashColor: Colors.white.withOpacity(0.6),
                      borderRadius: const BorderRadius.all(Radius.circular(15)),
                      padding: const EdgeInsets.all(4),
                    ),
                    Text(
                      "₪${widget.item.price.toStringAsFixed(2)}",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.headline4!.copyWith(fontSize: 14.sp),
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
