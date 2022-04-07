import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:no_interaction_dialog/no_interaction_dialog.dart';

class LoadDialog extends StatelessWidget {
  final NoInteractionDialogController? controller;
  final Widget? child;

  const LoadDialog({this.controller, this.child});

  @override
  Widget build(BuildContext context) {
    return NoInteractionDialog(
      controller: controller,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          CircularProgressIndicator(backgroundColor: Colors.white,),
          if (child != null) child!,
        ],
      ),
    );
  }
}
