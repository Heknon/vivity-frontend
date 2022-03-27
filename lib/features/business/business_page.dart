import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:vivity/features/base_page.dart';

class BusinessPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BasePage(
      body: Column(
        children: [
          Text(
            'Create business',
            style: Theme.of(context).textTheme.headline3?.copyWith(color: Colors.white, fontSize: 16.sp),
          )
        ],
      ),
    );
  }
}
