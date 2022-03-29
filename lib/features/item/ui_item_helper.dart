import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:objectid/objectid/objectid.dart';
import 'package:vivity/features/item/like_button.dart';
import 'package:vivity/features/item/models/item_model.dart';

import '../user/bloc/user_bloc.dart';
import 'classic_item.dart';

Widget buildPreviewImage(
  Future<Map<String, File>?>? itemImages,
  ItemModel item, {
  Size? size,
  Color imageBackgroundColor = Colors.white,
  BorderRadius borderRadius = const BorderRadius.all(Radius.circular(7)),
}) {
  return FutureBuilder(
    future: itemImages,
    builder: (ctx, snapshot) {
      if (!snapshot.hasData) {
        return size != null
            ? SizedBox(
                height: size.height * 0.5,
                width: size.width * 0.7,
                child: const CircularProgressIndicator(),
              )
            : const CircularProgressIndicator();
      }

      Map<String, File>? data = snapshot.data as Map<String, File>?;
      if (data == null) return const Text('Error getting image');

      File? file = data[item.images[item.previewImageIndex]];
      if (file == null) {
        return size != null
            ? SizedBox(
                height: size.height * 0.5,
                width: size.width * 0.7,
                child: const CircularProgressIndicator(),
              )
            : const CircularProgressIndicator();
      }

      return ClipRRect(
        borderRadius: borderRadius,
        child: Container(
          color: imageBackgroundColor,
          child: Image.file(
            file,
            height: size != null ? size.height * 0.65 : null,
          ),
        ),
      );
    },
  );
}

Widget buildItemCoupling(ItemModel modelLeft, ItemModel? modelRight, Size itemSize) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
    children: [
      ConstrainedBox(
        child: ClassicItem(item: modelLeft),
        constraints: BoxConstraints(maxWidth: itemSize.width, maxHeight: itemSize.height),
      ),
      ConstrainedBox(
        child: modelRight != null ? ClassicItem(item: modelRight) : Container(),
        constraints: BoxConstraints(maxWidth: itemSize.width, maxHeight: itemSize.height),
      ),
    ],
  );
}

Widget buildItemContentGrid(
  List<ItemModel> items,
  Size itemViewSize,
  ScrollController sc, {
  double itemHeightMultiplier = 0.6,
}) {
  Size itemSize = Size(itemViewSize.width * 0.45, itemViewSize.height * itemHeightMultiplier);
  int itemCount = (items.length / 2.0).ceil();
  bool hasLastPlusOne = items.length % 2 == 0;

  return ListView.builder(
    controller: sc,
    itemCount: itemCount,
    itemExtent: itemSize.height + 10,
    itemBuilder: (ctx, i) => buildItemCoupling(
        items[2 * i],
        itemCount - 1 != i
            ? items[2 * i + 1]
            : hasLastPlusOne
                ? items[2 * i + 1]
                : null,
        itemSize),
  );
}

Widget buildDatabaseLikeButton(ItemModel item, LikeButtonController controller, BuildContext context, bool initialLiked) {
  return BlocListener<UserBloc, UserState>(
    listener: (ctx, state) {
      if (state is! UserLoggedInState) return;
      for (var element in state.likedItems) {
        if (element.id == item.id) return controller.setLiked(true);
      }

      controller.setLiked(false);
    },
    child: LikeButton(
      color: Theme.of(context).primaryColor,
      controller: controller, // TODO: Connect to user liked items using onClick
      initialLiked: initialLiked,
      onClick: (liked) {
        if (liked) {
          context.read<UserBloc>().add(UserAddFavoriteEvent(item));
        } else {
          context.read<UserBloc>().add(UserRemoveFavoriteEvent(item.id));
        }
        controller.setLiked(!liked);
      },
    ),
  );
}
