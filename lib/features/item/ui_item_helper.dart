import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:vivity/features/cart/bloc/cart_bloc.dart';
import 'package:vivity/features/cart/models/cart_item_model.dart';
import 'package:vivity/features/item/like_button.dart';
import 'package:vivity/features/item/models/item_model.dart';
import 'package:vivity/features/user/repo/user_repository.dart';

import '../../widgets/quantity.dart';

import 'cart_item.dart';
import 'classic_item.dart';

Widget buildPreviewImage(
  Uint8List image, {
  Size? size,
  Color imageBackgroundColor = Colors.white,
  BorderRadius borderRadius = const BorderRadius.all(Radius.circular(7)),
}) {
  return ClipRRect(
    borderRadius: borderRadius,
    child: Container(
      color: imageBackgroundColor,
      child: Image.memory(
        image,
        width: size != null ? size.width : null,
        fit: BoxFit.fill,
      ),
    ),
  );
}

Future<Map<String, Uint8List>?> readImagesBytes(Future<Map<String, File>?>? files) async {
  if (files == null) return null;
  Map<String, Uint8List> readResult = {};
  Map<String, File>? filesReady = await files;
  for (var entry in filesReady?.entries ?? {}.entries) {
    readResult[entry.key] = await entry.value.readAsBytes();
  }

  return readResult;
}

Widget buildItemCoupling(
  ItemModel modelLeft,
  ItemModel? modelRight,
  Size itemSize, {
  Set<String> likedItemIds = const {},
  bool hasEditButton = false,
  void Function(ItemModel)? onEditTap,
  void Function(ItemModel)? onTap,
  void Function(ItemModel)? onLongTap,
  Widget Function(ItemModel, ClassicItem)? builder,
}) {
  ClassicItem leftItem = ClassicItem(
    item: modelLeft,
    editButton: hasEditButton,
    onEditTap: onEditTap != null ? () => onEditTap(modelLeft) : null,
    onTap: onTap != null ? () => onTap(modelLeft) : null,
    onLongTap: onLongTap != null ? () => onLongTap(modelLeft) : null,
    initialLiked: likedItemIds.contains(modelLeft.id.hexString),
  );

  ClassicItem? rightItem = modelRight != null
      ? ClassicItem(
          item: modelRight,
          editButton: hasEditButton,
          onEditTap: onEditTap != null ? () => onEditTap(modelRight) : null,
          onTap: onTap != null ? () => onTap(modelRight) : null,
          onLongTap: onLongTap != null ? () => onLongTap(modelRight) : null,
          initialLiked: likedItemIds.contains(modelRight.id.hexString),
        )
      : null;
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
    children: [
      ConstrainedBox(
        child: builder == null ? leftItem : builder(modelLeft, leftItem),
        constraints: BoxConstraints(maxWidth: itemSize.width, maxHeight: itemSize.height),
      ),
      ConstrainedBox(
        child: builder == null
            ? rightItem ?? Container()
            : modelRight != null && rightItem != null
                ? builder(modelRight, rightItem)
                : Container(),
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
  bool hasEditButton = false,
  void Function(ItemModel)? onEditTapped,
  void Function(ItemModel)? onTap,
  void Function(ItemModel)? onLongTap,
  Widget Function(ItemModel, ClassicItem)? builder,
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
      itemSize,
      hasEditButton: hasEditButton,
      onEditTap: onEditTapped,
      onTap: onTap,
      onLongTap: onLongTap,
      builder: builder,
    ),
  );
}

Widget buildDatabaseLikeButton(
  ItemModel item,
  LikeButtonController controller,
  BuildContext context,
  bool initialLiked, {
  Color? color,
  Color? backgroundColor,
  Color? splashColor,
  double? radius,
  BorderRadius? borderRadius,
  EdgeInsets? padding,
}) {
  UserRepository userRepository = UserRepository();

  return LikeButton(
    color: color ?? Theme.of(context).primaryColor,
    controller: controller,
    // TODO: Connect to user liked items using onClick
    initialLiked: initialLiked,
    backgroundColor: backgroundColor,
    splashColor: splashColor,
    radius: radius,
    borderRadius: borderRadius,
    padding: padding,
    onClick: (liked) {
      if (liked) {
        userRepository.addLikedItem(likedItemId: item.id.hexString);
      } else {
        userRepository.removeLikedItem(likedItemId: item.id.hexString);
      }
      controller.setLiked(!liked);
    },
  );
}

Widget buildCartItemList(
  List<CartItemModel> items,
  Size size,
  BuildContext context, {
  Size? itemSize,
  bool hasQuantity = true,
  void Function(QuantityController, int)? onQuantityDelete,
  BorderRadius? itemBorderRadius,
  EdgeInsets? itemPadding,
  Widget? emptyCart,
  double elevation = 7,
  bool includeQuantityControls = true,
  bool onlyQuantity = false,
}) {
  List<CartItem> cartItems = List.generate(
    items.length,
    (i) => CartItem(
      item: items[i],
      width: itemSize?.width,
      height: itemSize?.height,
      onQuantityIncrement:
          hasQuantity && !onlyQuantity ? (quantityController) => BlocProvider.of<CartBloc>(context).add(CartIncrementItemEvent(i)) : null,
      onQuantityDecrement:
          hasQuantity && !onlyQuantity ? (quantityController) => BlocProvider.of<CartBloc>(context).add(CartDecrementItemEvent(i)) : null,
      onQuantityDelete: hasQuantity && !onlyQuantity && onQuantityDelete != null ? (qc) => onQuantityDelete(qc, i) : null,
      borderRadius: itemBorderRadius,
      elevation: elevation,
      includeQuantityControls: includeQuantityControls,
      onlyQuantity: onlyQuantity,
    ),
  );
  return SizedBox(
    width: size.width,
    height: items.length < 2
        ? size.height / 2
        : items.length < 3
            ? size.height / 1.1
            : size.height,
    child: items.isNotEmpty
        ? ListView.separated(
            padding: itemPadding?.add(EdgeInsets.only(bottom: 6)),
            itemCount: cartItems.length,
            separatorBuilder: (ctx, i) => SizedBox(height: itemPadding?.bottom),
            itemBuilder: (ctx, i) => cartItems[i],
          )
        : emptyCart,
  );
}

Widget buildTab(Widget title, Size tabSize, BoxConstraints constraints) {
  return Positioned(
    bottom: 0,
    width: tabSize.width,
    height: tabSize.height,
    child: Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            blurRadius: 8.0,
            color: Color.fromRGBO(0, 0, 0, 0.25),
          )
        ],
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Material(
            shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(15))),
            color: const Color(0xffD2D2D2),
            clipBehavior: Clip.antiAlias,
            elevation: 3,
            child: Container(
              width: tabSize.width * 0.13,
              height: tabSize.height * 0.15,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 11.0),
            child: title,
          )
        ],
      ),
    ),
  );
}
