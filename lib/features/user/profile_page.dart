import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:no_interaction_dialog/load_dialog.dart';
import 'package:sizer/sizer.dart';
import 'package:vivity/features/address/models/address.dart';
import 'package:vivity/features/base_page.dart';
import 'package:vivity/features/checkout/ui_checkout_helper.dart';
import 'package:vivity/features/user/profile_bloc/profile_bloc.dart';
import '../business/models/order.dart';
import '../item/models/item_model.dart';
import '../order/order.dart' as order_widget;

class ProfilePage extends StatefulWidget {
  ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late final ProfileBloc _bloc;
  bool _loadDialogOpen = false;
  LoadDialog _loadDialog = LoadDialog();

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _bloc = context.read<ProfileBloc>();
  }

  @override
  Widget build(BuildContext context) {
    return BasePage(
      body: Padding(
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
              BlocConsumer<ProfileBloc, ProfileState>(
                listener: (ctx, state) {
                  if (_loadDialogOpen) {
                    Navigator.pop(context);
                    _loadDialogOpen = false;
                  }
                },
                builder: (ctx, state) {
                  if (state is ProfileUnloaded) return Center(child: CircularProgressIndicator());

                  ProfileLoaded profileState = state as ProfileLoaded;
                  List<Address> addresses = profileState.addresses;
                  List<ItemModel> orderItems = profileState.orderItems;
                  List<Order> orders = profileState.orders;

                  return Column(
                    children: [
                      SizedBox(height: 10),
                      Text(
                        'Addresses:',
                        textAlign: TextAlign.left,
                        style: Theme.of(context).textTheme.headline3?.copyWith(fontSize: 20.sp),
                      ),
                      SizedBox(
                        child: buildShippingAddressList(
                          addresses,
                          context,
                          canHighlight: false,
                          canDelete: true,
                          onDeleteTap: (index) {
                            showDialog(context: context, builder: (ctx) => _loadDialog);
                            _loadDialogOpen = true;
                            _bloc.add(ProfileDeleteAddressEvent(index));
                          },
                        ),
                        height: addresses.length > 1 ? 30.h : (addresses.length * 17).h,
                      ),
                      SizedBox(height: 10),
                      Center(
                        child: buildAddressCreationWidget(
                          context: context,
                          onSubmit: (address) {
                            Navigator.pop(context);
                            showDialog(context: context, builder: (ctx) => _loadDialog);
                            _loadDialogOpen = true;
                            _bloc.add(ProfileAddAddressEvent(address));
                          },
                        ),
                      ),
                      SizedBox(height: 30),
                      Text(
                        'Orders:',
                        textAlign: TextAlign.left,
                        style: Theme.of(context).textTheme.headline3?.copyWith(fontSize: 20.sp),
                      ),
                      SizedBox(height: 10),
                      orders.isNotEmpty
                          ? Column(
                              children: List.generate(orders.length * 2 - 1, (index) {
                                if (index % 2 == 1) return Divider();
                                index ~/= 2;
                                order_widget.Order order = order_widget.Order(order: orders[index], orderItems: orderItems);
                                return order;
                              }),
                            )
                          : Center(
                              child: Text(
                                "Sadly, you have 0 orders\n????",
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.headline3?.copyWith(fontSize: 18.sp),
                              ),
                            ),
                      SizedBox(height: 20),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
