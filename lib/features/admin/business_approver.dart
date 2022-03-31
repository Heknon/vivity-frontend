import 'dart:typed_data';

import 'package:expandable/expandable.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:form_validator/form_validator.dart';
import 'package:sizer/sizer.dart';
import 'package:vivity/models/business.dart';
import 'package:vivity/services/assets_service.dart';

import '../../config/themes/themes_config.dart';

class BusinessApprover extends StatelessWidget {
  final Business business;
  final Uint8List ownerIdImageBytes;
  final void Function(String)? approvePressed;
  final void Function(String)? declinePressed;
  final TextEditingController _controller = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey();

  BusinessApprover({
    Key? key,
    required this.business,
    required this.ownerIdImageBytes,
    this.approvePressed,
    this.declinePressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    TextStyle? buttonTextStyle = Theme.of(context).textTheme.headline4?.copyWith(fontSize: 18.sp);
    Widget image = ClipRRect(
      borderRadius: BorderRadius.all(Radius.circular(8)),
      child: Image.memory(ownerIdImageBytes),
    );

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ExpandablePanel(
        header: Text('Name - ${business.name}', style: Theme.of(context).textTheme.headline3?.copyWith(fontSize: 18.sp)),
        collapsed: buildCollapsedBody(context),
        expanded: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildCollapsedBody(context),
              SizedBox(height: 10),
              Center(
                child: SizedBox(
                  child: image,
                  height: 30.h,
                ),
              ),
              SizedBox(height: 10),
              Center(
                child: SizedBox(
                  width: 90.w,
                  child: TextFormField(
                    controller: _controller,
                    validator: ValidationBuilder().minLength(1).maxLength(100).build(),
                    style: TextStyle(fontSize: 12.sp, color: Colors.black),
                    keyboardType: TextInputType.multiline,
                    minLines: 1,
                    maxLines: 2,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    decoration: InputDecoration(
                      labelText: 'Note to owner',
                      labelStyle: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    style: ButtonStyle(
                      elevation: MaterialStateProperty.all(5),
                      backgroundColor: MaterialStateProperty.all(primaryComplementaryColor),
                    ),
                    onPressed: () {
                      if (!(_formKey.currentState?.validate() ?? false)) {
                        ScaffoldMessenger.of(context).clearSnackBars();
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Please enter a note such as "Please change X!"')));
                        return;
                      }

                      if (declinePressed != null) declinePressed!(_controller.text);
                    },
                    child: Text(
                      'DECLINE',
                      style: buttonTextStyle,
                    ),
                  ),
                  TextButton(
                    style: ButtonStyle(
                      elevation: MaterialStateProperty.all(5),
                      backgroundColor: MaterialStateProperty.all(Colors.green),
                    ),
                    onPressed: () {
                      if (!(_formKey.currentState?.validate() ?? false)) {
                        ScaffoldMessenger.of(context).clearSnackBars();
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Please enter a note such as "Approved!"')));
                        return;
                      }

                      if (approvePressed != null) approvePressed!(_controller.text);
                    },
                    child: Text(
                      'APPROVE',
                      style: buttonTextStyle,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Column buildCollapsedBody(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('National business ID - ${business.nationalBusinessId}', style: Theme.of(context).textTheme.headline3?.copyWith(fontSize: 16.sp)),
        SizedBox(height: 5),
        Text('Contact - ', style: Theme.of(context).textTheme.headline3?.copyWith(fontSize: 16.sp)),
        SizedBox(height: 2),
        Text('\t\t\tPhone - ${business.contact.phone}', style: Theme.of(context).textTheme.headline3?.copyWith(fontSize: 14.sp)),
        Text('\t\t\tEmail - ${business.contact.email}', style: Theme.of(context).textTheme.headline3?.copyWith(fontSize: 14.sp)),
        if (business.contact.facebook?.isNotEmpty ?? false)
          Text('\t\t\tFacebook - ${business.contact.facebook}', style: Theme.of(context).textTheme.headline3?.copyWith(fontSize: 14.sp)),
        if (business.contact.facebook?.isNotEmpty ?? false)
          Text('\t\t\tInstagram - ${business.contact.instagram}', style: Theme.of(context).textTheme.headline3?.copyWith(fontSize: 14.sp)),
        if (business.contact.facebook?.isNotEmpty ?? false)
          Text('\t\t\tTwitter - ${business.contact.twitter}', style: Theme.of(context).textTheme.headline3?.copyWith(fontSize: 14.sp)),
      ],
    );
  }
}
