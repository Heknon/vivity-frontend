import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sizer/sizer.dart';
import 'package:vivity/constants/app_constants.dart';
import 'package:latlong2/latlong.dart';
import 'package:vivity/features/item/item_page.dart';
import 'package:vivity/features/item/map_preview_icon.dart';
import 'package:vivity/features/item/models/item_model.dart';
import 'package:vivity/features/search_filter/filter_bar.dart';
import 'package:vivity/features/search_filter/filter_side_bar.dart';
import 'package:vivity/features/search_filter/widget_swapper.dart';
import '../../helpers/helper.dart';
import '../cart/shopping_cart.dart';
import '../item/preview_item.dart';
import '../map/map_gui.dart';
import '../map/map_widget.dart';
import 'bloc/explore_bloc.dart';
import 'slideable_item_tab.dart';
import 'package:latlong2/latlong.dart';

class Explore extends StatefulWidget {
  @override
  State<Explore> createState() => _ExploreState();
}

class _ExploreState extends State<Explore> {
  final mapGuiController = MapGuiController();
  final _widgetSwapController = WidgetSwapperController();
  late final ExploreController _controller;
  late final Set<LatLng> mapItemLocations = {};
  final Random random = Random();


  @override
  void initState() {
    super.initState();

    _controller = ExploreController();
    _controller.addListener(() {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (ctx, constraints) => BlocListener<ExploreBloc, ExploreState>(
        listener: (ctx, state) {
          if (state is! ExploreLoaded) return;
          if (listEquals(_controller.exploreItems, state.itemModels)) return;

          mapGuiController.removeWidgetsFromMap(mapItemLocations);
          mapItemLocations.clear();
          mapGuiController.addWidgetsToMap(state.itemModels.map((e) {
            Size textSize = MapPreviewIcon.getTextSize(e.price, context);
            double added1 = doubleInRange(random, 0.0001, 0.00015);
            double added2 = doubleInRange(random, 0.0001, 0.00015);
            LatLng loc = mapItemLocations.contains(e.location)
                ? LatLng(e.location.latitude + added1, e.location.longitude + added2)
                : e.location;
            MapWidget widget = buildMapWidget(
                location: loc,
                size: Size(textSize.width + 15, textSize.height + 10),
                child: MapPreviewIcon(
                  item: e,
                  exploreController: _controller,
                ));
            mapItemLocations.add(loc);
            return widget;
          }));
          _controller.updateExploreItems(List.of(state.itemModels));
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
            _controller.previewItem != null
                ? Positioned(
                    bottom: 100,
                    left: (100 - 80).w / 2,
                    child: ConstrainedBox(
                      child: GestureDetector(
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (ctx) => ItemPage(item: _controller.previewItem!))),
                        child: PreviewItem(
                          item: _controller.previewItem!,
                        ),
                      ),
                      constraints: BoxConstraints(maxWidth: 80.w, minHeight: 80, maxHeight: 100),
                    ),
                  )
                : Container(),
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
      size: size,
      child: child,
    );
  }
}

class ExploreController extends ChangeNotifier {
  late List<ItemModel> exploreItems;
  ItemModel? previewItem;

  ExploreController() {
    exploreItems = List.empty(growable: true);
  }

  void updateExploreItems(List<ItemModel> items) {
    exploreItems.clear();
    exploreItems = items;
    notifyListeners();
  }

  void updatePreviewItem(ItemModel item) {
    previewItem = item;
    notifyListeners();
  }
}
