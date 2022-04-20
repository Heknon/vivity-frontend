import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:vivity/features/like/like_button.dart';
import 'package:vivity/features/item/ui_item_helper.dart';
import 'package:vivity/features/search_filter/widget_swapper.dart';

class FilterSideBar extends StatelessWidget {
  final WidgetSwapperController controller;
  final List<Widget>? customBody;

  const FilterSideBar({
    Key? key,
    required this.controller,
    this.customBody,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return ClipRRect(
        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(20)),
        child: Material(
          child: Container(
            width: constraints.minWidth,
            height: constraints.maxHeight,
            color: Theme.of(context).colorScheme.primary,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: customBody ?? [
                Expanded(
                  child: Material(
                    color: Theme.of(context).colorScheme.primary,
                    child: InkWell(
                      borderRadius: const BorderRadius.all(Radius.circular(50)),
                      onTap: () {
                        controller.toggle();
                      },
                      child: Icon(Icons.search, color: Colors.white),
                    ),
                  ),
                ),
                Material(
                  color: Theme.of(context).colorScheme.primary,
                  child: InkWell(
                    borderRadius: const BorderRadius.all(Radius.circular(50)),
                    onTap: () {
                      print("2");
                    },
                    child: Icon(Icons.filter_alt_outlined, color: Colors.white),
                  ),
                ),
                Expanded(
                  child: Material(
                    color: Theme.of(context).colorScheme.primary,
                    child: InkWell(
                      borderRadius: const BorderRadius.all(Radius.circular(50)),
                      onTap: () {
                        print("3");
                      },
                      child: Icon(Icons.tune, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}
