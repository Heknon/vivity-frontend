import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import 'package:vivity/features/user/bloc/user_bloc.dart';
import 'package:vivity/helpers/ui_helpers.dart';
import 'package:vivity/services/item_service.dart';
import '../base_page.dart';
import '../cart/cart_bloc/cart_bloc.dart';
import '../cart/shopping_cart.dart';
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
  final ItemModel item;

  const ItemPage({
    Key? key,
    required this.item,
  }) : super(key: key);

  @override
  State<ItemPage> createState() => _ItemPageState();
}

class _ItemPageState extends State<ItemPage> {
  late List<ItemModifierSelectorController> _selectorControllers;
  late QuantityController _quantityController;
  late WidgetSwapperController _widgetSwapController;
  late final Future<Map<String, File>?>? itemImages;

  @override
  void initState() {
    super.initState();

    itemImages = getCachedItemImages((context.read<UserBloc>().state as UserLoggedInState).token, List.of([widget.item]));

    _selectorControllers = List.generate(
      widget.item.itemStoreFormat.modificationButtons.length,
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
    _widgetSwapController = WidgetSwapperController();
  }

  @override
  Widget build(BuildContext context) {
    return BasePage(
      appBar: VivityAppBar(
        bottom: buildTitle(context),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) => defaultGradientBackground(
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
                          FutureBuilder(
                              future: itemImages,
                              builder: (context, snapshot) {
                                Size size = Size(constraints.maxWidth * 0.7, constraints.maxHeight * 0.5);
                                if (!snapshot.hasData) {
                                  return buildImagesLoadingIndicator(size);
                                }

                                Map<String, File>? data = snapshot.data as Map<String, File>?;
                                if (data == null) {
                                  return buildImagesLoadingIndicator(size);
                                }

                                List<File> images = data.entries.map((e) => e.value).toList();
                                return Carousel(
                                  images: images,
                                  bottomRightRadius: 30,
                                  bottomLeftRadius: 30,
                                  initialPage: widget.item.previewImageIndex,
                                  imageSize: Size(constraints.maxWidth * 0.7, constraints.maxHeight * 0.5),
                                );
                              }),
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
                    filterViewController: _widgetSwapController,
                    bar: FilterBar(
                      controller: _widgetSwapController,
                    ),
                    sideBar: FilterSideBar(
                      controller: _widgetSwapController,
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

  Container buildImagesLoadingIndicator(Size size) {
    return Container(
      width: size.width,
      height: size.height,
      decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30))),
      child: SizedBox(
        width: size.width * 0.8,
        height: size.height * 0.8,
        child: const CircularProgressIndicator(),
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
                      '\$${widget.item.price.toStringAsFixed(2)}',
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
            return;
          }

          BlocProvider.of<CartBloc>(context).add(
            CartAddItemEvent(
              CartItemModel.fromItemModel(
                model: widget.item,
                quantity: _quantityController.quantity,
                dataChosen: generateChosenData(),
              ),
            ),
          );
        },
        child: Ink(
          decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(30))),
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
          '(${widget.item.reviews.length} reviews)',
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
          widget.item.itemStoreFormat.title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.headline4?.copyWith(color: Colors.white, fontSize: 16.sp),
        ),
        SizedBox(
          height: 4,
        ),
        Text(
          "${widget.item.businessName}'s shop",
          style: Theme.of(context).textTheme.subtitle1?.copyWith(fontSize: 10.sp),
        ),
      ],
    );
  }

  Row buildModificationButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(
        widget.item.itemStoreFormat.modificationButtons.length,
        (index) {
          ModificationButton button = widget.item.itemStoreFormat.modificationButtons[index];
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
                  widget.item.itemStoreFormat.title,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.headline4?.copyWith(color: Colors.white, fontSize: 11.sp),
                ),
              ),
              SizedBox(
                width: 50.w,
                child: Text(
                  "${widget.item.businessName}'s shop",
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

    widget.item.reviews.forEach((element) {
      sumRatings += element.rating;
    });

    return sumRatings / widget.item.reviews.length;
  }
}
