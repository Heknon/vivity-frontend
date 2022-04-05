import 'dart:io';
import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sizer/sizer.dart';
import 'package:vivity/features/item/models/item_model.dart';
import 'package:vivity/features/item/ui_item_helper.dart';
import 'package:vivity/widgets/quantity.dart';
import 'package:vivity/widgets/simple_card.dart';

import '../../services/item_service.dart';
import '../user/bloc/user_bloc.dart';
import 'item_data_section.dart';

class CartItem extends StatelessWidget {
  final CartItemModel item;
  final double? width;
  final double? height;
  final void Function(QuantityController, int?)? onQuantityIncrement;
  final void Function(QuantityController, int?)? onQuantityDecrement;
  final void Function(QuantityController, int?)? onQuantityDelete;
  final QuantityController? quantityController;
  final int? id;
  final double elevation;
  final bool includeQuantityControls;
  final bool onlyQuantity;
  final BorderRadius? borderRadius;
  Future<Map<String, Uint8List>?>? itemImages;
  Map<String, Uint8List>? itemImagesLoaded;

  CartItem({
    Key? key,
    required this.item,
    this.width,
    this.height,
    this.onQuantityIncrement,
    this.onQuantityDecrement,
    this.onQuantityDelete,
    this.quantityController,
    this.id,
    this.borderRadius,
    this.elevation = 7,
    this.includeQuantityControls = true,
    this.onlyQuantity = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    UserState state = context.read<UserBloc>().state;
    if (state is! UserLoggedInState) return Text('You need to be logged in to see items.');

    if (item.item != null) itemImages ??= readImagesBytes(getCachedItemImages(state.token, List.of([item.item!])));

    return LayoutBuilder(
      builder: (ctx, constraints) {
        double usedWidth = width ?? constraints.maxWidth;
        double usedHeight = height ?? constraints.maxHeight;

        return SizedBox(
          width: usedWidth,
          height: usedHeight,
          child: SimpleCard(
            elevation: elevation,
            borderRadius: borderRadius,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  height: usedHeight,
                  padding: const EdgeInsets.only(top: 5, bottom: 5, left: 8, right: 12),
                  child: FutureBuilder<Map<String, Uint8List>?>(
                      future: itemImages,
                      initialData: itemImagesLoaded,
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return CircularProgressIndicator();
                        }

                        itemImagesLoaded = snapshot.data;

                        return buildPreviewImage(snapshot.data, item.item!, borderRadius: const BorderRadius.all(Radius.circular(50)));
                      }),
                ),
                Expanded(
                  flex: 2,
                  child: ItemDataSection(
                    itemModel: item,
                    contextWidth: usedWidth,
                    contextHeight: usedHeight,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        '\$${item.price.toStringAsFixed(2)}',
                        style: Theme.of(context).textTheme.headline4!.copyWith(fontSize: 13.sp),
                      ),
                      const Spacer(),
                      if (includeQuantityControls || onlyQuantity)
                        ConstrainedBox(
                          constraints: BoxConstraints(maxWidth: constraints.maxWidth * 0.25, maxHeight: constraints.maxWidth * 0.25 / 3),
                          child: Quantity(
                            initialCount: item.quantity,
                            color: Theme.of(context).primaryColor,
                            onDecrement: onQuantityDecrement,
                            onIncrement: onQuantityIncrement,
                            deletable: true,
                            onDelete: onQuantityDelete,
                            controller: quantityController,
                            onlyQuantity: onlyQuantity,
                            id: id,
                          ),
                        )
                    ],
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }
}
