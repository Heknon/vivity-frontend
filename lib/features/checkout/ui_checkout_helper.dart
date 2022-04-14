import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:vivity/features/address/add_address.dart';
import 'package:vivity/features/address/address.dart' as address_widget;
import 'package:vivity/features/address/models/address.dart';

Widget buildShippingAddressList(
  List<Address> addresses,
  BuildContext context, {
  int? highlightIndex,
  Set<int>? expandedIndices,
  bool canHighlight = true,
  void Function(int)? onTap,
  void Function(int)? onDeleteTap,
  Color highlightedColor = Colors.white,
  Color unselectedColor = Colors.white70,
  Widget Function(BuildContext, Address)? expandedBuilder,
  void Function(int, bool)? onExpandTap,
}) {
  return expandedBuilder != null && expandedIndices != null
      ? ExpansionPanelList(
          expansionCallback: onExpandTap,
          children: List.generate(addresses.length, (index) {
            Address curr = addresses[index];
            address_widget.Address widget = buildAddress(curr, token, context, canHighlight: canHighlight, index: index, onDeleteTap: onDeleteTap);

            return ExpansionPanel(
              headerBuilder: (ctx, isOpen) => widget,
              body: expandedBuilder(context, curr),
              isExpanded: expandedIndices.contains(index),
              canTapOnHeader: false,
            );
          }),
        )
      : ListView.builder(
          itemCount: addresses.length,
          itemBuilder: (ctx, i) {
            Address curr = addresses[i];
            address_widget.Address widget = buildAddress(curr, token, context, canHighlight: canHighlight, index: i, onDeleteTap: onDeleteTap);

            return widget;
          },
        );
}

address_widget.Address buildAddress(
  Address address,
  BuildContext context, {
  required bool canHighlight,
  required int index,
  int? highlightIndex,
  Color highlightedColor = Colors.white,
  Color unselectedColor = Colors.white70,
  bool canDelete = true,
  void Function(int)? onTap,
  void Function(int)? onDeleteTap,
}) {
  return address_widget.Address(
    name: address.name,
    country: address.country,
    city: address.city,
    street: address.street,
    extraInfo: address.extraInfo,
    province: address.province,
    zipCode: address.zipCode,
    phone: address.phone,
    color: !canHighlight
        ? highlightedColor
        : highlightIndex == index
            ? unselectedColor
            : highlightedColor,
    onTap: onTap != null ? () => onTap(index) : null,
    onDeleteTap: () => onDeleteTap != null ? onDeleteTap(index) : null,
  );
}

Widget buildAddressCreationWidget({
  required BuildContext context,
  void Function(Address)? onSubmit,
}) {
  return GestureDetector(
    onTap: () => showDialog(
        context: context,
        builder: (ctx) => AddAddress(
              onSubmit: onSubmit,
            )),
    child: Container(
      width: 250,
      height: 120,
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).colorScheme.secondaryVariant, width: 1.5),
        borderRadius: const BorderRadius.all(Radius.circular(7)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.add,
            size: 50.sp,
          ),
          Text(
            'Add New Address',
            style: Theme.of(context).textTheme.headline4!.copyWith(fontSize: 12.sp, fontWeight: FontWeight.normal, color: Colors.black),
          )
        ],
      ),
    ),
  );
}

TextButton buildPaymentButton(BuildContext context, {required VoidCallback onPressed}) {
  return TextButton(
    style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all(
          Theme.of(context).colorScheme.secondaryVariant,
        ),
        overlayColor: MaterialStateProperty.all(Colors.grey),
        fixedSize: MaterialStateProperty.all(Size(90.w, 15.sp * 3))),
    child: Text(
      'Proceed To Payment',
      style: Theme.of(context).textTheme.headline4!.copyWith(fontSize: 20.sp, fontWeight: FontWeight.normal, color: Colors.white),
    ),
    onPressed: onPressed,
  );
}

PreferredSize buildTitle(BuildContext context, String title) {
  return PreferredSize(
    preferredSize: const Size(double.infinity, kToolbarHeight),
    child: Align(
      alignment: Alignment.topCenter,
      child: Container(
        color: Theme.of(context).colorScheme.primary,
        padding: EdgeInsets.only(bottom: 8),
        child: Text(
          title,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.headline4?.copyWith(color: Colors.white, fontSize: 24.sp),
        ),
      ),
    ),
  );
}
