import 'dart:async';

import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:vivity/features/item/models/item_model.dart';
import '../../models/order.dart' as business_model;
import '../item/ui_item_helper.dart';
import '../shipping/address.dart';

class Order extends StatefulWidget {
  final business_model.Order order;
  final List<ItemModel> orderItems;
  final bool dropdownStatus;
  final Future<void> Function(business_model.OrderStatus?)? onDropdownChange;

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
  late business_model.OrderStatus dropdownValue;

  late final Map<String, ItemModel> _idToItemMap;

  @override
  void initState() {
    super.initState();

    dropdownValue = widget.order.status;
    _idToItemMap = {};
    for (var item in widget.orderItems) {
      _idToItemMap[item.id.hexString] = item;
    }
  }

  @override
  Widget build(BuildContext context) {
    Size gridSize = Size(100.w, 30.h);
    EdgeInsets padding = const EdgeInsets.all(8);
    List<business_model.OrderStatus> statusValues = business_model.OrderStatus.values;

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
            widget.order.items.map(
              (e) {
                ItemModel item = _idToItemMap[e.itemId.hexString]!;
                return CartItemModel(
                  previewImage: item.images[item.previewImageIndex],
                  title: item.itemStoreFormat.title,
                  modifiersChosen: e.selectedModifiers,
                  quantity: e.amount,
                  price: e.price,
                  item: item,
                );
              },
            ).toList(),
            gridSize,
            context,
            hasQuantity: false,
            itemBorderRadius: BorderRadius.all(Radius.circular(8)),
            itemPadding: const EdgeInsets.all(8),
            elevation: 2,
            includeQuantityControls: false,
            onlyQuantity: true,
            itemSize: Size(gridSize.width * 0.7, ((gridSize.height) - (widget.order.items.length - 1) * padding.bottom) / 2.2),
          ),
        ],
      ),
    );
  }

  Column buildCollapsedBody(BuildContext context, List<business_model.OrderStatus> statusValues) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(8),
          child: !widget.dropdownStatus
              ? Text(
                  "Status: ${widget.order.status.getName()}",
                  style: Theme.of(context).textTheme.headline4?.copyWith(fontSize: 13.sp),
                )
              : buildDropdown(statusValues, context),
        ),
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

  DropdownButton<business_model.OrderStatus> buildDropdown(List<business_model.OrderStatus> statusValues, BuildContext context) {
    return DropdownButton<business_model.OrderStatus>(
      value: dropdownValue,
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
        if (widget.onDropdownChange != null) await widget.onDropdownChange!(status);
        setState(() {
          dropdownValue = status ?? widget.order.status;
        });
      },
    );
  }

  String addZero(num number) {
    return number < 10 ? '0$number' : number.toString();
  }
}