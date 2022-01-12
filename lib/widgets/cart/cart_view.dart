import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class CartView extends StatelessWidget {
  const CartView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (ctx, constraints) {
        print(constraints);
        return Material(
          elevation: 7,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(15),
              bottomLeft: Radius.circular(15),
            ),
          ),
          clipBehavior: Clip.antiAlias,
          child: Container(
            constraints: constraints,
            color: Colors.white,
            child: Stack(
              children: [],
            ),
          ),
        );
      },
    );
  }
}
