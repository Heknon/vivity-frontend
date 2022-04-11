import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:sizer/sizer.dart';

import '../config/themes/themes_config.dart';
import '../helpers/ui_helpers.dart';
import 'base_page.dart';

class ErrorPage extends StatelessWidget {
  final String? message;

  const ErrorPage({
    Key? key,
    this.message,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BasePage(
      body: defaultGradientBackground(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 10),
            Center(
              child: SvgPicture.asset(
                "assets/icons/abstract_logo.svg",
                color: primaryComplementaryColor,
                height: 110,
              ),
            ),
            SizedBox(height: 25),
            Center(
              child: Text(
                'ERROR',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headline4?.copyWith(fontSize: 24.sp),
              ),
            ),
            SizedBox(height: 20),
            if (message != null)
              Center(
                child: Text(
                  message!,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headline4?.copyWith(fontSize: 20.sp),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
