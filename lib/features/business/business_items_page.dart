import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:form_validator/form_validator.dart';
import 'package:objectid/objectid/objectid.dart';
import 'package:sizer/sizer.dart';
import 'package:vivity/features/item/ui_item_helper.dart';
import 'package:vivity/features/user/bloc/user_bloc.dart';
import 'package:vivity/services/item_service.dart';

import '../../config/themes/themes_config.dart';
import '../../models/business.dart';
import '../item/models/item_model.dart';
import 'business_ui_helper.dart';

class BusinessItemsPage extends StatelessWidget {
  final Business business;
  Future<Map<ObjectId, ItemModel>>? itemsCache;

  BusinessItemsPage({
    Key? key,
    required this.business,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    itemsCache ??= business.getIdItemMap(updateCache: true);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8),
          child: Center(
            child: Text(
              business.name,
              style: Theme.of(context).textTheme.headline4?.copyWith(fontSize: 24.sp),
            ),
          ),
        ),
        FutureBuilder(
            future: itemsCache,
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return CircularProgressIndicator();
              }

              Map<ObjectId, ItemModel> idItemMap = snapshot.data as Map<ObjectId, ItemModel>;
              Size gridSize = Size(100.w, 60.h);
              return SizedBox.fromSize(
                size: gridSize,
                child: buildItemContentGrid(idItemMap.values.toList(), gridSize, ScrollController(),
                    itemHeightMultiplier: 0.6,
                    hasEditButton: true,
                    onEditTapped: (item) => print("edit tapped"),
                    onTap: (item) async {
                      int stock = await enterStockDialog(business.ownerToken, item, context);
                      ScaffoldMessenger.of(context).clearSnackBars();
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Stock updated to $stock')));
                    },
                    onLongTap: (item) => showDialog(context: context, builder: (ctx) => buildItemStatisticsDialog(ctx, item))),
              );
            })
      ],
    );
  }

  Widget buildItemStatisticsDialog(BuildContext context, ItemModel item) {
    return AlertDialog(
      title: Text(
        'Item statistics',
        style: Theme.of(context).textTheme.headline4?.copyWith(fontSize: 16.sp),
      ),
      content: SizedBox(
        height: 20.h,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Views: ${item.metrics.views}',
              style: Theme.of(context).textTheme.headline3?.copyWith(fontSize: 14.sp),
            ),
            SizedBox(height: 5),
            Text(
              'Likes: ${item.metrics.likes}',
              style: Theme.of(context).textTheme.headline3?.copyWith(fontSize: 14.sp),
            ),
            SizedBox(height: 5),
            Text(
              'Orders: ${item.metrics.orders}',
              style: Theme.of(context).textTheme.headline3?.copyWith(fontSize: 14.sp),
            )
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () async {
            Navigator.of(context).pop();
          },
          style: ButtonStyle(
              splashFactory: InkRipple.splashFactory,
              textStyle: MaterialStateProperty.all(Theme.of(context).textTheme.headline3?.copyWith(fontSize: 14.sp))),
          child: Text(
            'OK',
            style: Theme.of(context).textTheme.headline3?.copyWith(color: Theme.of(context).primaryColor, fontSize: 14.sp),
          ),
        )
      ],
    );
  }
}
