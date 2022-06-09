import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sizer/sizer.dart';
import 'package:vivity/features/business/bloc/business_bloc.dart';
import 'package:vivity/features/business/models/business.dart';
import 'package:vivity/features/order/service/order_service.dart';
import 'package:vivity/helpers/ui_helpers.dart';

import 'models/order.dart';
import '../item/models/item_model.dart';
import '../order/order.dart' as order_widget;

class BusinessOrdersPage extends StatelessWidget {
  final OrderService _orderService = OrderService();

  final Business business;
  final List<Order> orders;
  final List<ItemModel> orderItems;
  final BusinessBloc businessBloc;

  BusinessOrdersPage({
    Key? key,
    required this.business,
    required this.orders,
    required this.orderItems,
    required this.businessBloc,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Map<String, ItemModel> idToItem = {};
    for (ItemModel item in orderItems) {
      idToItem[item.id.hexString] = item;
    }

    return defaultGradientBackground(
      child: Column(
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
          SizedBox(height: 20),
          orders.isNotEmpty
              ? SingleChildScrollView(
                child: Column(
                    children: List.generate(orders.length, (i) {
                      final int index = i;
                      order_widget.Order order = order_widget.Order(
                        order: orders[i],
                        orderItems: orderItems,
                        dropdownStatus: true,
                        onDropdownChange: (item, status) async {
                          if (status == null) {
                            showSnackBar('An error occurred and status cannot be updated', context);
                            return;
                          }

                          AsyncSnapshot<Order> snapshot =
                              await _orderService.updateOrderStatus(status: status, orderId: orders[i].orderId.hexString, index: index);

                          if (snapshot.hasError || !snapshot.hasData) {
                            showSnackBar('An error occurred and status cannot be updated', context);
                          } else {
                            Order order = snapshot.data!;
                            businessBloc.add(BusinessChangeOrderEvent(order));
                            showSnackBar('Updated order status to ${status.getName()}', context);
                          }

                          return;
                        },
                      );
                      return order;
                    }),
                  ),
              )
              : Text(
                  "Sadly, no one has made any orders\n😞",
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headline3?.copyWith(fontSize: 18.sp),
                ),
        ],
      ),
    );
  }
}
