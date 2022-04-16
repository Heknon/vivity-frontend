import 'dart:math';

import 'package:flutter/material.dart';
import 'package:vivity/features/admin/business_approver.dart';
import 'package:vivity/features/business/models/business.dart';
import 'package:vivity/helpers/ui_helpers.dart';

class AdminUnapprovedList extends StatelessWidget {
  final List<Business> businesses;
  final void Function(Business, String)? approvePressed;
  final void Function(Business, String)? declinePressed;

  const AdminUnapprovedList({
    Key? key,
    required this.businesses,
    this.approvePressed,
    this.declinePressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        max(0, businesses.length * 2 - 1),
            (i) {
          if (i.isOdd) return Divider();
          Business business = businesses[i ~/ 2];
          return BusinessApprover(
            business: business,
            approvePressed: (note) async {
              if (approvePressed != null) approvePressed!(business, note);
            },
            declinePressed: (note) async {
              if (declinePressed != null) declinePressed!(business, note);
            },
          );
        },
      ),
    );
  }
}
