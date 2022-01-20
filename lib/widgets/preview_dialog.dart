import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class PreviewDialog extends StatelessWidget {
  final String title;
  final Widget content;

  const PreviewDialog({Key? key, required this.title, required this.content}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        title,
        style: TextStyle(
          fontFamily: "Hezaedrus",
          fontSize: 12.sp,
          fontWeight: FontWeight.w500,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
      content: content,
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            "OK",
            style: TextStyle(
              fontFamily: "Hezaedrus",
              fontSize: 10.sp,
              fontWeight: FontWeight.w500,
              color: Theme.of(context).colorScheme.primaryVariant,
            ),
          ),
        )
      ],
    );
  }
}