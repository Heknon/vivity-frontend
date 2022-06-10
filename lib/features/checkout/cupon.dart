import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:sizer/sizer.dart';

class Cupon extends StatelessWidget {
  final TextEditingController? cuponTextController;
  final VoidCallback? onApplyClicked;
  final FocusNode? focusNode;

  const Cupon({Key? key, this.cuponTextController, this.onApplyClicked, this.focusNode,}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return SizedBox(
        width: constraints.maxWidth,
        height: 10.sp * 3.5,
        child: TextField(
          controller: cuponTextController,
          focusNode: focusNode,
          style: TextStyle(fontSize: 12.sp, color: Colors.black),
          decoration: InputDecoration(
            contentPadding: EdgeInsets.all(10),
            hintText: "Cupon Code",
            hintStyle: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
            suffixIcon: SizedBox(
              width: constraints.maxWidth * 0.4,
              height: 10.sp * 3.5,
              child: Ink(
                child: TextButton(
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Theme.of(context).colorScheme.secondaryVariant),
                    splashFactory: InkSplash.splashFactory,
                    overlayColor: MaterialStateProperty.all(Colors.grey),
                  ),
                  onPressed: () {
                    if (onApplyClicked != null) onApplyClicked!();
                  },
                  child: Padding(
                    padding: EdgeInsets.only(left: 5),
                    child: Row(
                      children: [
                        Text(
                          'Apply Cupon',
                          style: Theme.of(context).textTheme.subtitle2?.copyWith(fontSize: 10.sp, color: Colors.white, fontWeight: FontWeight.normal),
                        ),
                        const Padding(
                          padding: const EdgeInsets.only(left: 4.0),
                          child: Icon(
                            Icons.arrow_forward,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Theme.of(context).colorScheme.secondaryVariant),
              borderRadius: const BorderRadius.all(Radius.circular(8)),
            ),
            border: OutlineInputBorder(
              borderSide: BorderSide(color: Theme.of(context).colorScheme.secondaryVariant),
              borderRadius: const BorderRadius.all(Radius.circular(8)),
            ),
          ),
        ),
      );
    });
  }
}
