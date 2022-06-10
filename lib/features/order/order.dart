import 'dart:async';

import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:vivity/features/address/address.dart';
import 'package:vivity/features/business/models/order_item.dart';
import 'package:vivity/features/cart/models/cart_item_model.dart';
import 'package:vivity/features/item/models/item_model.dart';
import '../business/models/order.dart' as business_model;
import '../item/ui_item_helper.dart';

class Order extends StatefulWidget {
  final business_model.Order order;
  final List<ItemModel> orderItems;
  final bool dropdownStatus;
  final Future<void> Function(OrderItem, business_model.OrderStatus?)? onDropdownChange;

  const Order({
    Key? key,
    required this.order,
    required this.orderItems,
    this.dropdownStatus = false,
    this.onDropdownChange,
  }) : super(key: key);

  @override
  State<Order> createState() => _OrderState();
}

class _OrderState extends State<Order> {
  Map<OrderItem, business_model.OrderStatus> dropdownValue = {};

  late final Map<String, ItemModel> _idToItemMap;

  @override
  void initState() {
    super.initState();

    _idToItemMap = {};
    for (var item in widget.orderItems) {
      _idToItemMap[item.id.hexString] = item;
    }

    for (var item in widget.order.items) {
      dropdownValue[item] = item.status;
    }
  }

  @override
  Widget build(BuildContext context) {
    Size gridSize = Size(100.w, 30.h);
    EdgeInsets padding = const EdgeInsets.all(8);
    List<business_model.OrderStatus> statusValues = business_model.OrderStatus.values;
    List<CartItemModel> orderItemsList = List.empty(growable: true);

    for (OrderItem orderItem in widget.order.items) {
      ItemModel? item = orderItem.itemId != null ? _idToItemMap[orderItem.itemId?.hexString] : null;
      if (item != null)
        orderItemsList.add(CartItemModel(
          modifiersChosen: orderItem.selectedModifiers,
          quantity: orderItem.amount,
          item: item,
        ));
    }

    return ExpandablePanel(
      header: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "${addZero(widget.order.orderDate.day)}/${addZero(widget.order.orderDate.month)}/${widget.order.orderDate.year}",
                  style: Theme.of(context).textTheme.headline4?.copyWith(fontSize: 13.sp),
                ),
              ],
            ),
          ],
        ),
      ),
      collapsed: buildCollapsedBody(context, statusValues),
      expanded: Column(
        children: [
          buildCollapsedBody(context, statusValues),
          SizedBox(
            width: 90.w,
            child: Divider(),
          ),
          buildCartItemList(
            orderItemsList,
            Size(gridSize.width, 60.h),
            context,
            hasQuantity: false,
            itemBorderRadius: BorderRadius.all(Radius.circular(8)),
            itemPadding: const EdgeInsets.all(8),
            elevation: 2,
            includeQuantityControls: false,
            onlyQuantity: true,
            itemSize: Size(gridSize.width * 0.7, ((gridSize.height) - (widget.order.items.length - 1) * padding.bottom) / 2.2),
            builder: (ctx, item, i) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: !widget.dropdownStatus
                      ? Text(
                          "Status: ${dropdownValue[widget.order.items[i]]?.getName() ?? "N/A"}",
                          style: Theme.of(context).textTheme.headline4?.copyWith(fontSize: 13.sp),
                        )
                      : buildDropdown(widget.order.items[i], statusValues, context),
                ),
                item,
              ],
            ),
          ),
        ],
      ),
    );
  }

  Column buildCollapsedBody(BuildContext context, List<business_model.OrderStatus> statusValues) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.order.address != null)
          Address(
            name: widget.order.address!.name,
            province: widget.order.address!.province,
            extraInfo: widget.order.address!.extraInfo,
            zipCode: widget.order.address!.zipCode,
            street: widget.order.address!.street,
            phone: widget.order.address!.phone,
            country: widget.order.address!.country,
            city: widget.order.address!.city,
            canDelete: false,
          ),
        Padding(
          padding: const EdgeInsets.only(left: 10, top: 5, right: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Subtotal - \$${widget.order.subtotal.toStringAsFixed(2)}",
                    style: Theme.of(context).textTheme.headline4?.copyWith(fontSize: 12.sp),
                  ),
                  Text(
                    "Cupon - \$${widget.order.cuponDiscount.toStringAsFixed(2)}",
                    style: Theme.of(context).textTheme.headline4?.copyWith(fontSize: 12.sp),
                  ),
                ],
              ),
              SizedBox(height: 5),
              if (widget.order.shippingCost > 0)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Shipping - \$${widget.order.shippingCost.toStringAsFixed(2)}",
                      style: Theme.of(context).textTheme.headline4?.copyWith(fontSize: 12.sp),
                    ),
                    Text(
                      "Total - \$${widget.order.total.toStringAsFixed(2)}",
                      style: Theme.of(context).textTheme.headline4?.copyWith(fontSize: 12.sp),
                    ),
                  ],
                ),
              if (widget.order.shippingCost == 0)
                Text(
                  "Total - \$${widget.order.total.toStringAsFixed(2)}",
                  style: Theme.of(context).textTheme.headline4?.copyWith(fontSize: 12.sp),
                ),
            ],
          ),
        ),
      ],
    );
  }

  DropdownButton<business_model.OrderStatus> buildDropdown(OrderItem item, List<business_model.OrderStatus> statusValues, BuildContext context) {
    return DropdownButton<business_model.OrderStatus>(
      value: dropdownValue[item] ?? item.status, //dropdownValue,
      items: List.generate(
        statusValues.length,
        (index) => DropdownMenuItem(
          value: statusValues[index],
          child: Text(
            statusValues[index].getName(),
            style: Theme.of(context).textTheme.headline4?.copyWith(fontSize: 12.sp),
          ),
        ),
      ),
      selectedItemBuilder: (ctx) => List.generate(
        statusValues.length,
        (index) => Text(
          "Status: ${statusValues[index].getName()}",
          style: Theme.of(context).textTheme.headline4?.copyWith(fontSize: 13.sp),
        ),
      ),
      onChanged: (status) async {
        if (widget.onDropdownChange != null) await widget.onDropdownChange!(item, status);
        setState(() {
          dropdownValue[item] = status ?? item.status;
        });
      },
    );
  }

  String addZero(num number) {
    return number < 10 ? '0$number' : number.toString();
  }
}
