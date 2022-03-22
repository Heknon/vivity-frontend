import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vivity/constants/app_constants.dart';
import 'package:latlong2/latlong.dart';
import 'package:vivity/features/item/map_preview_icon.dart';
import 'package:vivity/features/item/models/item_model.dart';
import 'package:vivity/features/search_filter/filter_bar.dart';
import 'package:vivity/features/search_filter/filter_side_bar.dart';
import 'package:vivity/features/search_filter/widget_swapper.dart';
import '../cart/shopping_cart.dart';
import '../map/map_gui.dart';
import '../map/map_widget.dart';
import 'bloc/explore_bloc.dart';
import 'slideable_item_tab.dart';

class Explore extends StatefulWidget {
  @override
  State<Explore> createState() => _ExploreState();
}

class _ExploreState extends State<Explore> {
  final mapGuiController = MapGuiController();
  final _widgetSwapController = WidgetSwapperController();
  final List<ItemModel> exploreItemModels = List.empty(growable: true);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (ctx, constraints) => BlocListener<ExploreBloc, ExploreState>(
        listener: (ctx, state) {
          // print(state);
          if (state is! ExploreLoaded) return;
          if (listEquals(exploreItemModels, state.itemModels)) return;

          mapGuiController.removeWidgetsFromMap(exploreItemModels.map((e) => e.location).toSet());
          exploreItemModels.clear();
          exploreItemModels.addAll(state.itemModels);
          mapGuiController.addWidgetsToMap(exploreItemModels.map((e) => buildMapWidget(location: e.location, child: MapPreviewIcon(item: e))));
        },
        child: Stack(
          children: [
            MapGui(
              mapBoxToken: mapBoxToken,
              controller: mapGuiController,
            ),
            Positioned(
              top: 0,
              right: 0,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minWidth: 50,
                  maxWidth: MediaQuery.of(context).size.width,
                  minHeight: 50,
                  maxHeight: 120,
                ),
                child: WidgetSwapper(
                  filterViewController: _widgetSwapController,
                  bar: FilterBar(
                    controller: _widgetSwapController,
                  ),
                  sideBar: FilterSideBar(
                    controller: _widgetSwapController,
                  ),
                ),
              ),
            ),
            Positioned(
              child: ConstrainedBox(
                child: ShoppingCart(),
                constraints: constraints,
              ),
            ),
            Positioned(
              child: ConstrainedBox(
                child: const SlideableItemTab(),
                constraints: constraints,
              ),
            ),
          ],
        ),
      ),
    );
  }

  MapWidget buildMapWidget({
    required LatLng location,
    required Widget child,
    Size size = const Size(50, 25),
  }) {
    return MapWidget(
      location: location,
      size: const Size(75, 25),
      child: child,
    );
  }
}
