import 'package:animations/animations.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sizer/sizer.dart';
import 'package:vivity/features/base_page.dart';
import 'package:vivity/features/item/classic_item.dart';
import 'package:vivity/features/item/favorites_page/bloc/favorites_bloc.dart';
import 'package:vivity/features/item/item_page/item_page.dart';
import 'package:vivity/features/item/ui_item_helper.dart';

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BasePage(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: Center(
              child: Text(
                'Favorites',
                style: Theme.of(context).textTheme.headline4?.copyWith(fontSize: 24.sp),
              ),
            ),
          ),
          SizedBox(height: 15),
          BlocBuilder<FavoritesBloc, FavoritesState>(
            builder: (ctx, state) {
              if (state is! FavoritesLoaded) {
                return CircularProgressIndicator();
              }

              Size gridSize = Size(100.w, 70.h);
              return state.favoritedItems.isNotEmpty
                  ? SizedBox.fromSize(
                      size: gridSize,
                      child: buildItemContentGrid(
                        state.favoritedItems,
                        gridSize,
                        ScrollController(),
                        itemHeightMultiplier: 0.55,
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
                      ),
                    )
                  : Center(
                      child: Text(
                        'Start by adding an item to your favorites',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.headline3?.copyWith(fontSize: 20.sp),
                      ),
                    );
            },
          ),
        ],
      ),
    );
  }
}
