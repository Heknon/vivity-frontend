import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:form_validator/form_validator.dart';
import 'package:objectid/objectid/objectid.dart';
import 'package:sizer/sizer.dart';
import 'package:vivity/features/item/item_page.dart';
import 'package:vivity/features/item/ui_item_helper.dart';
import 'package:vivity/features/user/bloc/user_bloc.dart';
import 'package:vivity/helpers/ui_helpers.dart';
import 'package:vivity/services/item_service.dart';

import '../../config/themes/themes_config.dart';
import 'models/business.dart';
import '../item/models/item_model.dart';
import 'business_ui_helper.dart';

class BusinessItemsPage extends StatefulWidget {
  BusinessItemsPage({
    Key? key,
  }) : super(key: key);

  @override
  State<BusinessItemsPage> createState() => _BusinessItemsPageState();
}

class _BusinessItemsPageState extends State<BusinessItemsPage> {
  Future<Map<ObjectId, ItemModel>>? itemsCache;

  @override
  Widget build(BuildContext context) {
    UserState userStateInitial = context.read<UserBloc>().state;
    if (userStateInitial is! BusinessUserLoggedInState) return Text('Get outta here 😶😶😶');
    Text businessNameText = Text(
      userStateInitial.business.name,
      style: Theme.of(context).textTheme.headline4?.copyWith(fontSize: 24.sp),
    );

    itemsCache ??= userStateInitial.business.getIdItemMap(updateCache: true);

    return defaultGradientBackground(
      child: BlocListener<UserBloc, UserState>(
        listenWhen: (prevState, currState) {
          if (currState is! BusinessUserLoggedInState) return false;
          if (prevState is! BusinessUserLoggedInState) return true;

          return prevState.business.items != currState.business.items;
        },
        listener: (ctx, state) {
          setState(() {
            itemsCache = null;
          });
        },
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8),
              child: Center(
                child: businessNameText,
              ),
            ),
            FutureBuilder(
              future: itemsCache,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return CircularProgressIndicator();
                }

                Map<ObjectId, ItemModel> idItemMap = snapshot.data as Map<ObjectId, ItemModel>;
                Size gridSize = Size(100.w, 100.h - Scaffold.of(context).appBarMaxHeight! - getTextSize(businessNameText).height - 16);
                return SizedBox.fromSize(
                  size: gridSize,
                  child: buildItemContentGrid(idItemMap.values.toList(), gridSize, ScrollController(),
                      itemHeightMultiplier: 0.5,
                      hasEditButton: true,
                      onEditTapped: (item) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (ctx) => ItemPage(
                              item: item,
                              editorOpened: true,
                              registerView: false,
                            ),
                          ),
                        );
                      },
                      onTap: (item) async {
                        int stock = await enterStockDialog(userStateInitial.business.ownerToken!, item, context);
                        ScaffoldMessenger.of(context).clearSnackBars();
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Stock updated to $stock')));
                        setState(() {
                          idItemMap[item.id] = item.copyWith(stock: stock);
                        });
                      },
                      onLongTap: (item) => showDialog(context: context, builder: (ctx) => buildItemStatisticsDialog(ctx, item))),
                );
              },
            ),
          ],
        ),
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
