import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:progress_bar/progress_bar.dart';
import 'package:sizer/sizer.dart';

class CheckoutProgress extends StatelessWidget {
  final int step;
  final ProgressBarController? controller;

  const CheckoutProgress({Key? key, required this.step, this.controller}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ProgressBar(
      controller: controller,
      activeColor: const Color(0xffBA2435),
      inactiveColor: const Color(0xffE7C6CA),
      initialStep: step,
      labelsActive: [
        Text(
          'Confirm',
          style: Theme.of(context).textTheme.headline3?.copyWith(color: Colors.black, fontSize: 12.sp),
        ),
        Text(
          'Shipping',
          style: Theme.of(context).textTheme.headline3?.copyWith(color: Colors.black, fontSize: 12.sp),
        ),
        Text(
          'Payment',
          style: Theme.of(context).textTheme.headline3?.copyWith(color: Colors.black, fontSize: 12.sp),
        ),
      ],
      labelsInactive: [
        Text(
          'Confirm',
          style: Theme.of(context).textTheme.headline3?.copyWith(color: Colors.grey, fontSize: 11.sp),
        ),
        Text(
          'Shipping',
          style: Theme.of(context).textTheme.headline3?.copyWith(color: Colors.grey, fontSize: 11.sp),
        ),
        Text(
          'Payment',
          style: Theme.of(context).textTheme.headline3?.copyWith(color: Colors.grey, fontSize: 11.sp),
        ),
      ],
    );
  }
}
