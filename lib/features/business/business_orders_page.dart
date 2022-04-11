import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sizer/sizer.dart';
import 'package:vivity/helpers/ui_helpers.dart';
import 'package:vivity/services/business_service.dart';

import 'models/business.dart';
import 'models/order.dart';
import '../item/models/item_model.dart';
import '../order/order.dart' as order_widget;
import '../user/bloc/user_bloc.dart';

class BusinessOrdersPage extends StatefulWidget {
  BusinessOrdersPage({
    Key? key,
  }) : super(key: key);

  @override
  State<BusinessOrdersPage> createState() => _BusinessOrdersPageState();
}

class _BusinessOrdersPageState extends State<BusinessOrdersPage> {
  Future<List<Order>>? ordersCache;

  Future<List<ItemModel>>? ordersItemsCache;

  @override
  Widget build(BuildContext context) {
    UserState userStateInitial = context.read<UserBloc>().state;
    if (userStateInitial is! BusinessUserLoggedInState) return Text('Get outta here 😶😶😶');

    ordersCache ??= userStateInitial.business.getOrders(updateCache: true);
    ordersItemsCache ??= userStateInitial.business.getCachedOrderItems();

    return defaultGradientBackground(
      child: BlocListener<UserBloc, UserState>(
        listenWhen: (prevState, state) {
          if (state is BusinessUserLoggedInState && prevState is! BusinessUserLoggedInState) return true;
          if (state is! BusinessUserLoggedInState || prevState is! BusinessUserLoggedInState) return false;

          if (state.business != prevState.business) {
            return true;
          }

          return false;
        },
        listener: (ctx, state) {
          setState(() {
            ordersItemsCache = null;
            ordersCache = null;
          });
        },
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8),
              child: Center(
                child: Text(
                  userStateInitial.business.name,
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
                                dropdownStatus: true,
                                onDropdownChange: (status) async {
                                  if (status == null) {
                                    ScaffoldMessenger.of(context).clearSnackBars();
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(const SnackBar(content: Text('An error occurred and status cannot be updated')));
                                    return;
                                  }

                                  Order updatedOrder =
                                      await updateOrderStatus(userStateInitial.business.ownerToken!, status, orders[i].orderId.hexString);
                                  ScaffoldMessenger.of(context).clearSnackBars();
                                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Updated order status to ${status.getName()}')));
                                  context.read<UserBloc>().add(BusinessUserFrontendUpdateOrder(updatedOrder));
                                  return;
                                },
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
          ],
        ),
      ),
    );
  }
}
