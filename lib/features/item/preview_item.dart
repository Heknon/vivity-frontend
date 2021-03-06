import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:sizer/sizer.dart';
import 'package:vivity/constants/asset_path.dart';
import 'package:vivity/features/like/like_button.dart';
import 'package:vivity/features/like/bloc/liked_bloc.dart';
import 'package:vivity/features/item/ui_item_helper.dart';
import 'package:vivity/features/user/models/user.dart';
import 'package:vivity/features/user/repo/user_repository.dart';
import 'package:vivity/widgets/rating.dart';
import 'package:vivity/widgets/simple_card.dart';

import '../../config/themes/themes_config.dart';
import 'models/item_model.dart';

class PreviewItem extends StatefulWidget {
  final ItemModel item;
  final Size? size;
  final bool initialLiked;
  final VoidCallback? onTap;

  PreviewItem({
    Key? key,
    required this.item,
    required this.initialLiked,
    this.size,
    this.onTap,
  }) : super(key: key);

  @override
  State<PreviewItem> createState() => _PreviewItemState();
}

class _PreviewItemState extends State<PreviewItem> {
  final UserRepository _userRepository = UserRepository();
  late LikeButtonController _likeButtonController;

  @override
  void initState() {
    super.initState();
    _likeButtonController = LikeButtonController();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        double usedWidth = widget.size?.width ?? constraints.maxWidth;
        double usedHeight = widget.size?.height ?? constraints.maxHeight;

        return SizedBox(
          height: usedHeight,
          width: usedWidth,
          child: SimpleCard(
            elevation: 7,
            onTap: widget.onTap,
            borderRadius: const BorderRadius.all(Radius.circular(15)),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  height: usedHeight,
                  width: usedWidth * 0.4,
                  padding: const EdgeInsets.only(top: 5, bottom: 5, left: 8, right: 12),
                  child: buildPreviewImage(
                    widget.item.previewImage ?? noImageAvailable,
                    borderRadius: const BorderRadius.all(Radius.circular(15)),
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
                        _likeButtonController,
                        context,
                        widget.item.id.hexString,
                        context.read<LikedBloc>(),
                        color: primaryComplementaryColor,
                        backgroundColor: Colors.transparent,
                        splashColor: Colors.grey[600]!.withOpacity(0.6),
                        borderRadius: const BorderRadius.all(Radius.circular(15)),
                        padding: const EdgeInsets.all(4),
                      ),
                      Text(
                        "???${widget.item.price.toStringAsFixed(2)}",
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
      },
    );
  }
}
