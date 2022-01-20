import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:vivity/constants/app_constants.dart';
import 'package:vivity/features/item/widgets/fancy_item.dart';

class CartView extends StatelessWidget {
  final ScrollController? scrollController;

  CartView({Key? key, this.scrollController}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (ctx, constraints) {
        print(constraints.maxWidth);
        double itemsToFitInList = 3;
        double listPadding = 15;
        double itemsPadding = 25;
        double paddingOffset = listPadding + (itemsToFitInList - 2) * itemsPadding;
        Size listSize = Size(constraints.maxWidth * 0.8, constraints.maxHeight * 0.8);
        Size itemSize = Size(listSize.width * 0.1, (listSize.height) / itemsToFitInList);

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
            color: Theme.of(context).dialogBackgroundColor,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.only(top: listPadding),
                  height: listSize.height,
                  width: listSize.width,
                  child: ListView.builder(
                    itemCount: 5,
                    controller: scrollController,
                    itemBuilder: (ctx, i) => Padding(
                      padding: i != 0 ? EdgeInsets.only(top: itemsPadding) : const EdgeInsets.only(),
                      child: FancyItem(
                        itemModel: itemModelDemo,
                        width: itemSize.width,
                        height: itemSize.height,
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }
}
