import 'package:advanced_panel/panel.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sizer/sizer.dart';
import 'package:vivity/constants/app_constants.dart';

import 'package:google_fonts/google_fonts.dart';
import 'package:vivity/features/explore/bloc/explore_bloc.dart';
import 'package:vivity/features/item/models/item_model.dart';

import '../item/classic_item.dart';

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
      },
    );
  }

  Widget buildContent(Size itemViewSize, BoxConstraints constraints, ScrollController sc) {
    Size itemSize = Size(itemViewSize.width * 0.45, itemViewSize.height * 0.6);
    // 0, 1, 2, 3
    [0, 1, 2, 3, 4, 5, 6, 7, 8];
    // 0 - 0, 1
    // 1 - 2, 3
    // 2 - 4, 5
    // 3 - 6, 7
    // 4 - 8, 9

    return Positioned(
      bottom: 1,
      width: itemViewSize.width,
      child: Container(
        color: Colors.white,
        child: BlocBuilder<ExploreBloc, ExploreState>(builder: (context, state_) {
          if (state_ is ExploreUnloaded) return const CircularProgressIndicator();
          ExploreLoaded state = state_ as ExploreLoaded;
          int itemCount = (state.itemModels.length / 2.0).ceil();
          bool hasLastPlusOne = state.itemModels.length % 2 == 0;

          return ListView.builder(
            controller: sc,
            itemCount: itemCount,
            itemExtent: itemSize.height + 10,
            itemBuilder: (ctx, i) => buildItemCoupling(
                state.itemModels[2 * i],
                itemCount - 1 != i
                    ? state.itemModels[2 * i + 1]
                    : hasLastPlusOne
                        ? state.itemModels[2 * i + 1]
                        : null,
                itemSize),
          );
        }),
      ),
    );
  }

  Widget buildItemCoupling(ItemModel modelLeft, ItemModel? modelRight, Size itemSize) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ConstrainedBox(
          child: ClassicItem(itemModel: modelLeft),
          constraints: BoxConstraints(maxWidth: itemSize.width, maxHeight: itemSize.height),
        ),
        ConstrainedBox(
          child: modelRight != null ? ClassicItem(itemModel: modelRight) : Container(),
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
