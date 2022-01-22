import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:sizer/sizer.dart';
import 'package:vivity/features/search_filter/widget_swapper.dart';

class FilterBar extends StatelessWidget {
  final WidgetSwapperController controller;

  const FilterBar({Key? key, required this.controller}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return ClipRRect(
        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(20), bottomRight: Radius.circular(20)),
        child: Container(
          width: constraints.maxWidth,
          height: constraints.minHeight,
          color: Theme.of(context).colorScheme.primary,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                flex: 1,
                child: Material(
                  color: Theme.of(context).colorScheme.primary,
                  child: InkWell(
                    borderRadius: const BorderRadius.all(Radius.circular(50)),
                    onTap: () {
                      print("1");
                    },
                    child: Icon(Icons.search, color: Colors.white),
                  ),
                ),
              ),
              Expanded(
                flex: 5,
                child: Container(
                  child: TextField(
                    decoration: InputDecoration(
                      hintStyle: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
                      // constraints: constraints,
                      // label: Text(
                      //   "Search...",
                      // ),
                      hintText: "Search...",
                    ),
                    style: TextStyle(fontSize: 12.sp, color: Colors.white),
                    onSubmitted: (res) {
                      print('Submitted  text: $res');
                      controller.close();
                    },
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
                flex: 1,
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
      );
    });
  }
}
