import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:sizer/sizer.dart';

class Feed extends StatelessWidget {
  const Feed({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Center(
        child: Text('Under development', style: Theme.of(context).textTheme.headline1?.copyWith(fontSize: 45.sp), textAlign: TextAlign.center,),
      ),
    );
  }
}
