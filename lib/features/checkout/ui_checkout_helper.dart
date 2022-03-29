import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sizer/sizer.dart';
import 'package:vivity/features/shipping/address_service.dart';

import '../shipping/add_address.dart';
import '../shipping/address.dart' as address_widget;
import '../user/bloc/user_bloc.dart';
import '../user/models/address.dart';

Widget buildShippingAddressList(List<Address> addresses, BuildContext context, {
  required String token,
  int? highlightIndex,
  bool canHighlight = true,
  void Function(int)? onTap,
  Color highlightedColor = Colors.white,
  Color unselectedColor = Colors.white70,
}) {
  return ListView.builder(
    itemCount: addresses.length,
    itemBuilder: (ctx, i) {
      Address curr = addresses[i];
      address_widget.Address widget = address_widget.Address(
          name: curr.name,
          country: curr.country,
          city: curr.city,
          street: curr.street,
          extraInfo: curr.extraInfo,
          province: curr.province,
          zipCode: curr.zipCode,
          phone: curr.phone,
          color: !canHighlight
              ? highlightedColor
              : highlightIndex == i
              ? unselectedColor
              : highlightedColor,
          onTap: onTap != null ? () => onTap(i) : null,
          onDeleteTap: () async {
            List<Address> newAddresses = await removeAddress(token, i);
            context.read<UserBloc>().add(UserUpdateAddressesEvent(newAddresses));
          }
      );

      return widget;
    },
  );
}

Widget buildAddressCreationWidget(BuildContext context) {
  return GestureDetector(
    onTap: () => showDialog(context: context, builder: (ctx) => AddAddress()),
    child: Container(
      width: 250,
      height: 120,
      decoration: BoxDecoration(
        border: Border.all(color: Theme
            .of(context)
            .colorScheme
            .secondaryVariant, width: 1.5),
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
            style: Theme
                .of(context)
                .textTheme
                .headline4!
                .copyWith(fontSize: 12.sp, fontWeight: FontWeight.normal, color: Colors.black),
          )
        ],
      ),
    ),
  );
}
