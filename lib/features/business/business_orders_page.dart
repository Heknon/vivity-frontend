import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../models/business.dart';
import '../../models/order.dart';
import '../item/models/item_model.dart';
import '../order/order.dart' as order_widget;

class BusinessOrdersPage extends StatelessWidget {
  final Business business;
  Future<List<Order>>? ordersCache;
  Future<List<ItemModel>>? ordersItemsCache;

  BusinessOrdersPage({
    Key? key,
    required this.business,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    ordersCache ??= business.getOrders(updateCache: true);
    ordersItemsCache ??= business.getCachedOrderItems();

    return Column(children: [
      Padding(
        padding: const EdgeInsets.all(8),
        child: Center(
          child: Text(
            business.name,
            style: Theme.of(context).textTheme.headline4?.copyWith(fontSize: 24.sp),
          ),
        ),
      ),
      SizedBox(height: 20),
      FutureBuilder(
        future: Future.wait(<Future<dynamic>>[ordersCache as dynamic, ordersItemsCache as dynamic]),
        builder: (ctx, snapshot) {
          if (!snapshot.hasData) {
            return CircularProgressIndicator();
          }

          List<dynamic> snapshotData = snapshot.data as List<dynamic>;
          List<Order> orders = snapshotData[0] as List<Order>;
          List<ItemModel> orderItems = snapshotData[1] as List<ItemModel>;
          Map<String, ItemModel> idToItem = {};
          for (ItemModel item in orderItems) {
            idToItem[item.id.hexString] = item;
          }

          return orders.isNotEmpty
              ? SingleChildScrollView(
                  child: SizedBox(
                    height: 60.h,
                    child: ListView.builder(
                      itemCount: orders.length,
                      itemBuilder: (ctx, i) {
                        order_widget.Order order = order_widget.Order(
                          order: orders[i],
                          orderItems: orderItems,
                        );
                        return order;
                      },
                    ),
                  ),
                )
              : Text(
                  "Sadly, no one has made any orders\n😞",
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headline3?.copyWith(fontSize: 18.sp),
                );
        },
      ),
    ]);
  }
}
