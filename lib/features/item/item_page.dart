import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import 'package:vivity/features/home/explore/explore.dart';
import 'package:vivity/features/item/models/item_model.dart';
import 'package:vivity/features/search_filter/filter_bar.dart';
import 'package:vivity/features/search_filter/filter_side_bar.dart';
import 'package:vivity/features/search_filter/widget_swapper.dart';
import 'package:vivity/widgets/appbar/appbar.dart';
import 'package:vivity/widgets/carousel.dart';
import 'package:vivity/widgets/cart/shopping_cart.dart';
import 'package:vivity/widgets/quantity.dart';
import 'package:vivity/widgets/rating.dart';
import 'package:vivity/widgets/simple_card.dart';

import 'modifier/item_modifier.dart';

class ItemPage extends StatelessWidget {
  final ItemModel itemModel;

  /// Scaling is applied to size. Sizes are a percentage of the screen.
  final Size imageSize;

  const ItemPage({
    Key? key,
    required this.itemModel,
    this.imageSize = const Size(70, 50),
  }) : super(key: key);

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
                      height: 50.h,
                      width: 100.w,
                      child: Stack(
                        alignment: Alignment.topCenter,
                        children: [
                          Carousel(
                            imageUrls: itemModel.images,
                            bottomRightRadius: 30,
                            bottomLeftRadius: 30,
                            initialPage: itemModel.previewImageIndex,
                            imageSize: Size(65, 40),
                          ),
                          Positioned(
                            height: 13.h,
                            top: 35.h,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: List.generate(
                                  itemModel.itemStoreFormat.modificationButtons
                                      .length, (index) {
                                ModificationButton button = itemModel
                                    .itemStoreFormat.modificationButtons[index];
                                return ItemModifier(modificationButton: button);
                              }),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Spacer(),
                    ClipRRect(
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(30),
                          topRight: Radius.circular(30)),
                      child: Container(
                        height: 25.h,
                        color: Theme.of(context).colorScheme.primary,
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  flex: 4,
                                  child: Padding(
                                    padding: EdgeInsets.only(top: 36, left: 15),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          itemModel.itemStoreFormat.title,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: Theme.of(context)
                                              .textTheme
                                              .headline4
                                              ?.copyWith(
                                                  color: Colors.white,
                                                  fontSize: 16.sp),
                                        ),
                                        SizedBox(
                                          height: 4,
                                        ),
                                        Text(
                                          "${itemModel.businessName}'s shop",
                                          style: Theme.of(context)
                                              .textTheme
                                              .subtitle1
                                              ?.copyWith(fontSize: 10.sp),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Rating(rating: calculateRating()),
                                      Text(
                                        '(${itemModel.reviews.length} reviews)',
                                        style: Theme.of(context)
                                            .textTheme
                                            .subtitle1
                                            ?.copyWith(fontSize: 8.sp),
                                      )
                                    ],
                                  ),
                                )
                              ],
                            ),
                            Spacer(),
                            Padding(
                              padding: EdgeInsets.only(
                                  left: 15, right: 15, bottom: 10),
                              child: Row(
                                children: [
                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                      '\$${itemModel.price.toStringAsFixed(2)}',
                                      style: Theme.of(context)
                                          .textTheme
                                          .headline4!
                                          .copyWith(
                                              fontSize: 16.sp,
                                              color: Colors.white),
                                    ),
                                  ),
                                  Expanded(
                                    child: ConstrainedBox(
                                      constraints: BoxConstraints(
                                          maxWidth: constraints.maxWidth * 0.25,
                                          maxHeight:
                                              constraints.maxWidth * 0.25 / 3),
                                      child: Quantity(
                                        initialCount: 1,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 5.w,
                                  ),
                                  Expanded(
                                    child: Material(
                                      shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(30))),
                                      color: Colors.white,
                                      child: InkWell(
                                        child: Ink(
                                          child: Container(
                                            height: 7.h,
                                            decoration: BoxDecoration(
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(30))),
                                            child: Center(
                                              child: Text(
                                                'Cart',
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .headline4!
                                                    .copyWith(fontSize: 14.sp),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
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
                  itemModel.itemStoreFormat.title,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context)
                      .textTheme
                      .headline4
                      ?.copyWith(color: Colors.white, fontSize: 11.sp),
                ),
              ),
              SizedBox(
                width: 50.w,
                child: Text(
                  "${itemModel.businessName}'s shop",
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context)
                      .textTheme
                      .subtitle1
                      ?.copyWith(fontSize: 8.sp),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  double calculateRating() {
    double sumRatings = 0;

    itemModel.reviews.forEach((element) {
      sumRatings += element.rating;
    });

    return sumRatings / itemModel.reviews.length;
  }
}
