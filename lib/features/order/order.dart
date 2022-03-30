import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:vivity/features/item/models/item_model.dart';
import '../../models/order.dart' as business_model;
import '../item/ui_item_helper.dart';
import '../shipping/address.dart';

class Order extends StatelessWidget {
  final business_model.Order order;
  final List<ItemModel> orderItems;
  late final Map<String, ItemModel> _idToItemMap;

  Order({
    Key? key,
    required this.order,
    required this.orderItems,
  }) : super(key: key) {
    _idToItemMap = {};
    for (var item in orderItems) {
      _idToItemMap[item.id.hexString] = item;
    }
  }

  @override
  Widget build(BuildContext context) {
    Size gridSize = Size(100.w, 30.h);
    EdgeInsets padding = const EdgeInsets.all(8);

    return ExpandablePanel(
      header: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "${addZero(order.orderDate.day)}/${addZero(order.orderDate.month)}/${order.orderDate.year}",
                  style: Theme.of(context).textTheme.headline4?.copyWith(fontSize: 13.sp),
                ),
                Text(
                  "Order ${order.status.name}",
                  style: Theme.of(context).textTheme.headline4?.copyWith(fontSize: 13.sp),
                ),
              ],
            ),
          ],
        ),
      ),
      collapsed: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (order.address != null) Address(
            name: order.address!.name,
            province: order.address!.province,
            extraInfo: order.address!.extraInfo,
            zipCode: order.address!.zipCode,
            street: order.address!.street,
            phone: order.address!.phone,
            country: order.address!.country,
            city: order.address!.city,
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
                      "Subtotal - \$${order.subtotal.toStringAsFixed(2)}",
                      style: Theme.of(context).textTheme.headline4?.copyWith(fontSize: 12.sp),
                    ),
                    Text(
                      "Cupon - \$${order.cuponDiscount.toStringAsFixed(2)}",
                      style: Theme.of(context).textTheme.headline4?.copyWith(fontSize: 12.sp),
                    ),
                  ],
                ),
                SizedBox(height: 5),
                if (order.shippingCost > 0) Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Shipping - \$${order.shippingCost.toStringAsFixed(2)}",
                      style: Theme.of(context).textTheme.headline4?.copyWith(fontSize: 12.sp),
                    ),
                    Text(
                      "Total - \$${order.total.toStringAsFixed(2)}",
                      style: Theme.of(context).textTheme.headline4?.copyWith(fontSize: 12.sp),
                    ),
                  ],
                ),
                if (order.shippingCost ==0)Text(
                  "Total - \$${order.total.toStringAsFixed(2)}",
                  style: Theme.of(context).textTheme.headline4?.copyWith(fontSize: 12.sp),
                ),
              ],
            ),
          ),
        ],
      ),
      expanded: buildCartItemList(
        order.items.map(
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
        itemSize: Size(gridSize.width * 0.7, ((gridSize.height) - (order.items.length - 1) * padding.bottom) / 2.2),
      ),
    );
  }

  String addZero(num number) {
    return number < 10 ? '0$number' : number.toString();
  }
}
