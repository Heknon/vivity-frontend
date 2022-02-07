import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import 'package:vivity/bloc/cart_bloc/cart_bloc.dart';
import '../cart/shopping_cart.dart';
import 'package:vivity/features/home/explore/explore.dart';
import 'package:vivity/features/item/models/item_model.dart';
import 'package:vivity/features/item/modifier/item_modifier_selector.dart';
import 'package:vivity/features/search_filter/filter_bar.dart';
import 'package:vivity/features/search_filter/filter_side_bar.dart';
import 'package:vivity/features/search_filter/widget_swapper.dart';
import 'package:vivity/widgets/appbar/appbar.dart';
import 'package:vivity/widgets/carousel.dart';
import 'package:vivity/widgets/quantity.dart';
import 'package:vivity/widgets/rating.dart';
import 'package:vivity/widgets/simple_card.dart';

import 'modifier/item_modifier.dart';

class ItemPage extends StatefulWidget {
  final ItemModel itemModel;

  const ItemPage({
    Key? key,
    required this.itemModel,
  }) : super(key: key);

  @override
  State<ItemPage> createState() => _ItemPageState();
}

class _ItemPageState extends State<ItemPage> {
  late List<ItemModifierSelectorController> _selectorControllers;
  late QuantityController _quantityController;

  @override
  void initState() {
    _selectorControllers = List.generate(
      widget.itemModel.itemStoreFormat.modificationButtons.length,
      (index) => ItemModifierSelectorController(),
    );

    for (var controller in _selectorControllers) {
      controller.addListener(() {
        setState(() {});
        if (controller.lastToggle != null && controller.isShown) {
          for (var element in _selectorControllers) {
            if (identical(controller, element)) continue;
            if (!element.isShown || element.lastToggle == null) continue;

            if (controller.lastToggle!.isAfter(element.lastToggle!)) {
              element.toggle();
            }
          }
        }
      });
    }

    _quantityController = QuantityController();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: VivityAppBar(
        bottom: buildTitle(context),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) => Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xffF3F1F2), Color(0xffEAEAEC)],
              stops: [0, 1],
            ),
          ),
          child: Stack(
            children: [
              Positioned.fill(
                child: Column(
                  children: [
                    SizedBox(
                      height: constraints.maxHeight * 0.66,
                      width: 100.w,
                      child: Stack(
                        alignment: Alignment.topCenter,
                        children: [
                          Carousel(
                            imageUrls: widget.itemModel.images,
                            bottomRightRadius: 30,
                            bottomLeftRadius: 30,
                            initialPage: widget.itemModel.previewImageIndex,
                            imageSize: Size(constraints.maxWidth * 0.7, constraints.maxHeight * 0.5),
                          ),
                          Positioned(
                            bottom: 0,
                            child: buildModificationButtons(),
                          ),
                        ],
                      ),
                    ),
                    Spacer(),
                    buildDetailsTab(constraints, context)
                  ],
                ),
              ),
              Positioned(
                child: ConstrainedBox(
                  child: ShoppingCart(),
                  constraints: constraints,
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
                    filterViewController: widgetSwapController,
                    bar: FilterBar(
                      controller: widgetSwapController,
                    ),
                    sideBar: FilterSideBar(
                      controller: widgetSwapController,
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  ClipRRect buildDetailsTab(BoxConstraints constraints, BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)),
      child: Container(
        height: constraints.maxHeight * 0.32,
        color: Theme.of(context).colorScheme.primary,
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  flex: 4,
                  child: Padding(
                    padding: EdgeInsets.only(top: 36, left: 15),
                    child: buildDetailsTabTitle(context),
                  ),
                ),
                Expanded(
                  child: buildRatingView(context),
                )
              ],
            ),
            Spacer(),
            Padding(
              padding: EdgeInsets.only(left: 15, right: 15, bottom: 10),
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Text(
                      '\$${widget.itemModel.price.toStringAsFixed(2)}',
                      style: Theme.of(context).textTheme.headline4!.copyWith(fontSize: 16.sp, color: Colors.white),
                    ),
                  ),
                  Expanded(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: constraints.maxWidth * 0.25, maxHeight: constraints.maxWidth * 0.25 / 3),
                      child: Quantity(
                        initialCount: 1,
                        color: Colors.white,
                        controller: _quantityController,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 5.w,
                  ),
                  Expanded(
                    child: buildCartButton(context),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Material buildCartButton(BuildContext context) {
    return Material(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(30))),
      color: Colors.white,
      child: InkWell(
        onTap: () {
          bool shouldAdd = true;
          for (ItemModifierSelectorController controller in _selectorControllers) {
            if (controller.chosenIndices.isEmpty) {
              shouldAdd = false;
              break;
            }
          }

          if (!shouldAdd) {
            ScaffoldMessenger.of(context).clearSnackBars();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Please set all modifiers in order to add to cart."),
              ),
            );
          }

          BlocProvider.of<CartBloc>(context).add(
            CartAddItemEvent(
              CartItemModel.fromItemModel(
                model: widget.itemModel,
                quantity: _quantityController.quantity,
                dataChosen: generateChosenData(),
              ),
            ),
          );
        },
        child: Ink(
          child: Container(
            height: 7.h,
            decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(30))),
            child: Center(
              child: Text(
                'Cart',
                style: Theme.of(context).textTheme.headline4!.copyWith(fontSize: 14.sp),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Column buildRatingView(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Rating(rating: calculateRating()),
        Text(
          '(${widget.itemModel.reviews.length} reviews)',
          style: Theme.of(context).textTheme.subtitle1?.copyWith(fontSize: 8.sp),
        )
      ],
    );
  }

  Column buildDetailsTabTitle(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.itemModel.itemStoreFormat.title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.headline4?.copyWith(color: Colors.white, fontSize: 16.sp),
        ),
        SizedBox(
          height: 4,
        ),
        Text(
          "${widget.itemModel.businessName}'s shop",
          style: Theme.of(context).textTheme.subtitle1?.copyWith(fontSize: 10.sp),
        ),
      ],
    );
  }

  Row buildModificationButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(
        widget.itemModel.itemStoreFormat.modificationButtons.length,
        (index) {
          ModificationButton button = widget.itemModel.itemStoreFormat.modificationButtons[index];
          return ItemModifier(
            modificationButton: button,
            selectorController: _selectorControllers[index],
          );
        },
      ),
    );
  }

  PreferredSize buildTitle(BuildContext context) {
    return PreferredSize(
      preferredSize: const Size(double.infinity, kToolbarHeight),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Container(
          color: Theme.of(context).colorScheme.primary,
          padding: EdgeInsets.only(left: 12, bottom: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 75.w,
                child: Text(
                  widget.itemModel.itemStoreFormat.title,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.headline4?.copyWith(color: Colors.white, fontSize: 11.sp),
                ),
              ),
              SizedBox(
                width: 50.w,
                child: Text(
                  "${widget.itemModel.businessName}'s shop",
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.subtitle1?.copyWith(fontSize: 8.sp),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Map<int, Iterable<int>> generateChosenData() {
    Map<int, Iterable<int>> result = {};
    int index = 0;

    for (ItemModifierSelectorController controller in _selectorControllers) {
      result[index] = controller.chosenIndices;
      index++;
    }

    return result;
  }

  double calculateRating() {
    double sumRatings = 0;

    widget.itemModel.reviews.forEach((element) {
      sumRatings += element.rating;
    });

    return sumRatings / widget.itemModel.reviews.length;
  }
}
