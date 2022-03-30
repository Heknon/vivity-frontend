import 'package:flutter/material.dart';
import 'package:objectid/objectid/objectid.dart';
import 'package:sizer/sizer.dart';

import '../../models/business.dart';
import '../../models/order.dart';
import '../item/models/item_model.dart';

class BusinessStatisticsPage extends StatelessWidget {
  final Business business;
  Future<Map<ObjectId, ItemModel>>? itemsCache;
  Future<List<Order>>? ordersCache;

  BusinessStatisticsPage({
    Key? key,
    required this.business,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    itemsCache ??= business.getIdItemMap(updateCache: true);
    ordersCache ??= business.getOrders(updateCache: true);

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
            future: Future.wait(<Future<dynamic>>[itemsCache as dynamic, ordersCache as dynamic]),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return CircularProgressIndicator();
              }

              List<dynamic> snapshotData = snapshot.data as List<dynamic>;
              Map<ObjectId, ItemModel> idItemMap = snapshotData[0] as Map<ObjectId, ItemModel>;
              List<Order> orders = snapshotData[1] as List<Order>;
              List<ItemModel> items = idItemMap.values.toList();
              int totalViews = 0;
              int totalLikes = 0;
              int totalSales = 0;
              double orderTotal = 0;
              double shippingTotal = 0;
              double cuponTotal = 0;

              for (ItemModel item in items) {
                totalViews += item.metrics.views;
                totalLikes += item.metrics.likes;
                totalSales += item.metrics.orders;
              }

              for (Order order in orders) {
                shippingTotal += order.shippingCost;
                cuponTotal += order.cuponDiscount;
                orderTotal += order.total;
              }

              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    buildBasicStatisticRow("Views", totalViews, items.length, context),
                    SizedBox(height: 10),
                    buildBasicStatisticRow("Likes", totalLikes, items.length, context),
                    SizedBox(height: 10),
                    buildBasicStatisticRow("Orders", totalSales, items.length, context),
                    SizedBox(height: 10),
                    buildBasicStatisticRow("Shipping", shippingTotal, orders.length, context),
                    SizedBox(height: 10),
                    buildBasicStatisticRow("Cupons", cuponTotal, orders.length, context),
                    SizedBox(height: 10),
                    buildBasicStatisticRow("Total in sales", orderTotal, orders.length, context),
                  ],
                ),
              );
            }),
      ],
    );
  }

  Row buildBasicStatisticRow(String statisticName, num statistic, int amount, BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          '$statisticName: ${statistic.runtimeType != int ? statistic.toStringAsFixed(1) : statistic}',
          style: Theme.of(context).textTheme.headline3?.copyWith(fontSize: 14.sp),
        ),
        Text(
          'Average: ${(statistic / (amount == 0 ? 1 : amount)).toStringAsFixed(1)}',
          style: Theme.of(context).textTheme.headline3?.copyWith(fontSize: 14.sp),
        ),
      ],
    );
  }
}
