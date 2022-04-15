import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sizer/sizer.dart';
import 'package:vivity/constants/app_constants.dart';
import 'package:latlong2/latlong.dart';
import 'package:vivity/features/cart/shopping_cart.dart';
import 'package:vivity/features/home/bloc/home_bloc.dart';
import 'package:vivity/features/item/map_preview_icon.dart';
import 'package:vivity/features/item/models/item_model.dart';
import 'package:vivity/features/item/preview_item.dart';
import 'package:vivity/features/map/map_gui.dart';
import 'package:vivity/features/map/map_widget.dart';
import 'package:vivity/features/search_filter/filter_bar.dart';
import 'package:vivity/features/search_filter/filter_side_bar.dart';
import 'package:vivity/features/search_filter/widget_swapper.dart';
import 'package:vivity/helpers/helper.dart';
import 'package:vivity/models/navigation_models.dart';
import 'bloc/explore_bloc.dart';
import 'slideable_item_tab.dart';

class Explore extends StatefulWidget {
  const Explore();

  @override
  State<Explore> createState() => _ExploreState();
}

class _ExploreState extends State<Explore> {
  final WidgetSwapperController _widgetSwapController = WidgetSwapperController();
  late final ExploreBloc _bloc;
  late final HomeBloc _homeBloc;

  final Random random = Random();
  ItemModel? _selectedData;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _bloc = context.read<ExploreBloc>();
    _homeBloc = context.read<HomeBloc>();
  }

  @override
  Widget build(BuildContext context) {
    Set<LatLng> usedLocations = {};

    return BlocBuilder<HomeBloc, HomeState>(
      buildWhen: (prev, curr) => prev is! HomeLoaded || (curr is HomeLoaded && listEquals(prev.user.likedItems, curr.user.likedItems)),
      builder: (context, state) {
        Set<String> likedItemIds = state is HomeLoaded ? state.user.likedItems.map((e) => e.id.hexString).toSet() : {};

        return LayoutBuilder(
          builder: (ctx, constraints) => BlocListener<ExploreBloc, ExploreState>(
            listener: (ctx, state) => usedLocations.clear(),
            child: Stack(
              children: [
                MapGui(
                  mapBoxToken: mapBoxToken,
                  controller: _bloc.mapController,
                  transformDataToWidget: (data) {
                    Size textSize = MapPreviewIcon.getTextSize(data.price, context);
                    double added1 = getRandomSign(random) * doubleInRange(random, 0.00001, 0.00015);
                    double added2 = getRandomSign(random) * doubleInRange(random, 0.00001, 0.00015);
                    LatLng loc = usedLocations.contains(data.location)
                        ? LatLng(data.location.latitude + added1, data.location.longitude + added2)
                        : data.location;

                    return buildMapWidget(
                      location: loc,
                      size: Size(textSize.width + 15, textSize.height + 10),
                      child: MapPreviewIcon(
                        item: data,
                        onTap: (tappedItem) => setState(() {
                          _selectedData = tappedItem;
                        }),
                      ),
                    );
                  },
                ),
                if (_selectedData != null)
                  Positioned(
                    bottom: 100,
                    left: (100 - 80).w / 2,
                    child: ConstrainedBox(
                      child: GestureDetector(
                        onTap: () => Navigator.pushReplacementNamed(context, '/item', arguments: ItemPageNavigation(item: _selectedData!)),
                        child: PreviewItem(
                          item: _selectedData!,
                          initialLiked: likedItemIds.contains(_selectedData?.id.hexString),
                        ),
                      ),
                      constraints: BoxConstraints(maxWidth: 80.w, minHeight: 80, maxHeight: 100),
                    ),
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
                    child: SlideableItemTab(
                      likedItemIds: likedItemIds,
                    ),
                    constraints: constraints,
                  ),
                ),
              ],
            ),
          ),
        );
      },
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
