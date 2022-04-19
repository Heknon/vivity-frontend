import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:vivity/features/business/bloc/business_bloc.dart';
import 'package:vivity/features/business/models/business.dart';
import 'package:vivity/features/item/item_page/item_page.dart';
import 'package:vivity/features/item/ui_item_helper.dart';
import 'package:vivity/helpers/ui_helpers.dart';
import 'package:vivity/models/navigation_models.dart';

import '../item/models/item_model.dart';
import 'business_ui_helper.dart';

class BusinessItemPage extends StatelessWidget {
  final Business business;
  final List<ItemModel> items;
  final BusinessBloc businessBloc;

  const BusinessItemPage({
    Key? key,
    required this.business,
    required this.items,
    required this.businessBloc,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Text businessNameText = Text(
      business.name,
      style: Theme.of(context).textTheme.headline4?.copyWith(fontSize: 24.sp),
    );
    Size gridSize = Size(100.w, 100.h - Scaffold.of(context).appBarMaxHeight! - getTextSize(businessNameText).height - 16);

    return defaultGradientBackground(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: Center(
              child: businessNameText,
            ),
          ),
          SizedBox.fromSize(
            size: gridSize,
            child: buildItemContentGrid(items, gridSize, ScrollController(),
                itemHeightMultiplier: 0.5,
                hasEditButton: true,
                onEditTapped: (item) {
                  Navigator.pushNamed(context, '/item', arguments: ItemPageNavigation(item: item, shouldOpenEditor: true, isView: false));
                },
                onTap: (item) async {
                  int stock = await enterStockDialog(item, context);
                  businessBloc.add(BusinessUpdateStockEvent(item.id.hexString, stock));
                  showSnackBar('Stock updated to $stock', context);
                },
                onLongTap: (item) => showDialog(context: context, builder: (ctx) => buildItemStatisticsDialog(ctx, item))),
          ),
        ],
      ),
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
