import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sizer/sizer.dart';
import 'package:vivity/features/base_page.dart';
import 'package:vivity/features/checkout/ui_checkout_helper.dart';
import 'package:vivity/services/item_service.dart';
import '../../models/order.dart';
import '../item/models/item_model.dart';
import '../order/order.dart' as order_widget;

import 'bloc/user_bloc.dart';

class ProfilePage extends StatefulWidget {
  ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Future<List<ItemModel>>? ordersItemsCache;
  late bool initialized;

  @override
  void initState() {
    super.initState();
    initialized = false;
  }

  @override
  Widget build(BuildContext context) {
    if (!initialized) {
      context.read<UserBloc>().add(UpdateProfileData());
      initialized = true;
    }

    return BasePage(
      body: BlocBuilder<UserBloc, UserState>(builder: (context, state) {
        if (state is! UserLoggedInState) return const Text("Can't see this page without being logged in.\nHow are you even here?");
        Set<String> orderItemIds = {};
        for (var order in state.orderHistory) {
          for (var item in order.items) {
            orderItemIds.add(item.itemId.hexString);
          }
        }

        ordersItemsCache ??= getItemsFromStringIds(state.token, orderItemIds.toList());
        return Padding(
          padding: EdgeInsets.only(left: 10, right: 10, top: 8, bottom: 8),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Text(
                    'My Profile',
                    style: Theme.of(context).textTheme.headline4?.copyWith(fontSize: 24.sp),
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  'Addresses:',
                  textAlign: TextAlign.left,
                  style: Theme.of(context).textTheme.headline3?.copyWith(fontSize: 20.sp),
                ),
                SizedBox(
                  height: state.addresses.length > 1 ? 30.h : (state.addresses.length * 15).h,
                  child: buildShippingAddressList(state.addresses, context, canHighlight: false, token: state.token),
                ),
                SizedBox(height: 10),
                Center(child: buildAddressCreationWidget(context)),
                SizedBox(height: 30),
                Text(
                  'Orders:',
                  textAlign: TextAlign.left,
                  style: Theme.of(context).textTheme.headline3?.copyWith(fontSize: 20.sp),
                ),
                SizedBox(height: 10),
                FutureBuilder(
                  future: ordersItemsCache,
                  builder: (ctx, snapshot) {
                    if (!snapshot.hasData) {
                      return CircularProgressIndicator();
                    }

                    List<ItemModel> orderItems = snapshot.data as List<ItemModel>;
                    return state.orderHistory.isNotEmpty
                        ? Column(
                            children: List.generate(state.orderHistory.length, (index) {
                              order_widget.Order order = order_widget.Order(order: state.orderHistory[index], orderItems: orderItems);
                              return order;
                            }),
                          )
                        : Center(
                            child: Text(
                              "Sadly, you have 0 orders\n😞",
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.headline3?.copyWith(fontSize: 18.sp),
                            ),
                          );
                  },
                ),
                SizedBox(height: 20),
              ],
            ),
          ),
        );
      }),
    );
  }
}
