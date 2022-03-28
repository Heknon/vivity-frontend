import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sizer/sizer.dart';
import 'package:vivity/features/explore/explore.dart';
import 'package:vivity/features/item/item_page.dart';
import 'package:vivity/features/item/like_button.dart';
import 'package:vivity/widgets/rating.dart';
import 'package:vivity/widgets/simple_card.dart';

import '../user/bloc/user_bloc.dart';
import 'models/item_model.dart';

class PreviewItem extends StatefulWidget {
  final Size? size;
  final ItemModel item;

  PreviewItem({Key? key, this.size, required this.item}) : super(key: key);

  @override
  State<PreviewItem> createState() => _PreviewItemState();
}

class _PreviewItemState extends State<PreviewItem> {
  late final LikeButtonController likeController;

  @override
  void initState() {
    super.initState();
    likeController = LikeButtonController();
  }

  @override
  Widget build(BuildContext context) {
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
                padding: const EdgeInsets.only(top: 5, bottom: 5, left: 8, right: 12),
                child: buildPreviewImage(),
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
                    BlocListener<UserBloc, UserState>(
                      listener: (ctx, state) {
                        if (state is! UserLoggedInState) return;
                        for (var element in state.likedItems) {
                          if (element.id == widget.item.id) return likeController.setLiked(true);
                        }

                        likeController.setLiked(false);
                      },
                      child: LikeButton(
                        color: Theme.of(context).primaryColor,
                        controller: likeController, // TODO: Connect to user liked items using onClick
                        initialLiked: initialLiked,
                        onClick: (liked) {
                          if (liked) {
                            context.read<UserBloc>().add(UserAddFavoriteEvent(widget.item.id));
                          } else {
                            context.read<UserBloc>().add(UserRemoveFavoriteEvent(widget.item.id));
                          }
                          likeController.setLiked(!liked);
                        },
                      ),
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

  ClipRRect buildPreviewImage() {
    return ClipRRect(
      borderRadius: const BorderRadius.all(Radius.circular(15)),
      clipBehavior: Clip.antiAlias,
      child: CachedNetworkImage(
        imageUrl: widget.item.images[widget.item.previewImageIndex],
      ),
    );
  }
}
