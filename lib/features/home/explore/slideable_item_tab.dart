import 'package:advanced_panel/panel.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:sizer/sizer.dart';
import 'package:vivity/constants/app_constants.dart';
import '../../item/classic_item/classic_item.dart';

import 'package:google_fonts/google_fonts.dart';
import 'package:vivity/features/item/models/item_model.dart';

class SlideableItemTab extends StatelessWidget {
  const SlideableItemTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (ctx, constraints) {
        Size tabSize = Size(constraints.maxWidth, constraints.maxWidth * 0.2);
        Size itemViewSize = Size(tabSize.width, constraints.maxHeight * 0.9 - tabSize.height);

        return SlidingUpPanel(
          panelSize: tabSize.height,
          contentSize: itemViewSize.height + tabSize.height,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(18.0),
            topRight: Radius.circular(18.0),
          ),
          backdropEnabled: true,
          panel: buildTab(tabSize, constraints),
          contentBuilder: (sc) => buildContent(itemViewSize, constraints, sc),
          //parallaxEnabled: true,
        );

        // return SliderPanel(
        //   startPosition: SliderPosition.bottom,
        //   duration: const Duration(milliseconds: 500),
        //   draggableWidget: buildDraggableTab(tabSize, constraints, context),
        //   followerWidget: buildItemView(tabSize, constraints),
        // );
      },
    );
  }

  Widget buildContent(Size itemViewSize, BoxConstraints constraints, ScrollController sc) {
    Size itemSize = Size(itemViewSize.width * 0.45, itemViewSize.height * 0.6);

    return Positioned(
      bottom: 1,
      width: itemViewSize.width,
      child: Container(
        color: Colors.white,
        child: ListView.builder(
          controller: sc,
          itemCount: 5,
          itemExtent: itemSize.height + 10,
          itemBuilder: (ctx, i) => buildItemCoupling(itemModelDemo, itemModelDemo2, itemSize),
        ),
      ),
    );
  }

  Widget buildItemCoupling(ItemModel modelLeft, ItemModel modelRight, Size itemSize) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ConstrainedBox(
          child: ClassicItem(itemModel: modelLeft),
          constraints: BoxConstraints(maxWidth: itemSize.width, maxHeight: itemSize.height),
        ),
        ConstrainedBox(
          child: ClassicItem(itemModel: modelRight),
          constraints: BoxConstraints(maxWidth: itemSize.width, maxHeight: itemSize.height),
        ),
      ],
    );
  }

  Widget buildTab(Size tabSize, BoxConstraints constraints) {
    return Positioned(
      bottom: 0,
      width: tabSize.width,
      height: tabSize.height,
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              blurRadius: 8.0,
              color: Color.fromRGBO(0, 0, 0, 0.25),
            )
          ],
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Material(
              shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(15))),
              color: const Color(0xffD2D2D2),
              clipBehavior: Clip.antiAlias,
              elevation: 3,
              child: Container(
                width: tabSize.width * 0.13,
                height: tabSize.height * 0.15,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 11.0),
              child: Text(
                "Nearby items",
                style: TextStyle(fontFamily: "Futura", fontSize: 14.sp),
              ),
            )
          ],
        ),
      ),
    );
  }
}
