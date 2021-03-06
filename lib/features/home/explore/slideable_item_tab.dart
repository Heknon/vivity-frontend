import 'package:advanced_panel/panel.dart';
import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sizer/sizer.dart';
import 'package:vivity/config/themes/themes_config.dart';
import 'package:vivity/features/home/explore/bloc/explore_bloc.dart';
import 'package:vivity/features/item/classic_item.dart';
import 'package:vivity/features/item/item_page/item_page.dart';
import 'package:vivity/features/item/ui_item_helper.dart';

class SlideableItemTab extends StatelessWidget {
  const SlideableItemTab({
    Key? key,
  }) : super(key: key);

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
          panel: buildTab(
            Text("Nearby items", style: TextStyle(fontFamily: "Futura", fontSize: 14.sp)),
            tabSize,
            constraints,
          ),
          contentBuilder: (sc) => buildContent(itemViewSize, constraints, sc),
          //parallaxEnabled: true,
        );
      },
    );
  }

  Widget buildContent(Size itemViewSize, BoxConstraints constraints, ScrollController sc) {
    return Positioned(
      bottom: 1,
      width: itemViewSize.width,
      child: Container(
        color: Colors.white,
        child: BlocBuilder<ExploreBloc, ExploreState>(
          builder: (context, state) {
            if (state is! ExploreSearched || state.itemsFound.isEmpty)
              return Center(
                child: Text(
                  'No items in the area',
                  style: Theme.of(context).textTheme.headline4?.copyWith(fontSize: 16.sp, color: primaryColor),
                ),
              );

            return buildItemContentGrid(
              state.itemsFound,
              itemViewSize,
              sc,
              itemHeightMultiplier: 0.6,
              onTap: null,
              builder: (item, widget) {
                Widget itemPageWidget = ItemPage(item: item);

                return OpenContainer(
                  tappable: false,
                  closedElevation: 7,
                  transitionType: ContainerTransitionType.fade,
                  transitionDuration: Duration(milliseconds: 1000),
                  closedBuilder: (ctx, VoidCallback openContainer) => ClassicItem(
                    item: item,
                    key: widget.key,
                    editButton: widget.editButton,
                    onEditTap: widget.onEditTap,
                    onTap: openContainer,
                  ),
                  openBuilder: (ctx, _) => itemPageWidget,
                );
              },
            );
          },
        ),
      ),
    );
  }
}
