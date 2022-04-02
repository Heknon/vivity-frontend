import 'dart:io';

import 'package:advanced_panel/panel.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import 'package:vivity/config/themes/themes_config.dart';
import 'package:vivity/features/explore/slideable_item_tab.dart';
import 'package:vivity/features/item/item_edit_panel.dart';
import 'package:vivity/features/item/ui_item_helper.dart';
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

import 'like_button.dart';
import 'modifier/item_modifier.dart';

class ItemPage extends StatefulWidget {
  final ItemModel item;
  final bool editorOpened;

  const ItemPage({
    Key? key,
    required this.item,
    this.editorOpened = false,
  }) : super(key: key);

  @override
  State<ItemPage> createState() => _ItemPageState();
}

class _ItemPageState extends State<ItemPage> {
  late List<ItemModifierSelectorController> _selectorControllers;
  late QuantityController _quantityController;
  late LikeButtonController _likeController;
  late WidgetSwapperController _widgetSwapController;
  late PanelController _panelController;
  bool openedEditorPreviously = false;
  late final Future<Map<String, File>?>? itemImages;

  @override
  void initState() {
    super.initState();

    _likeController = LikeButtonController();
    _panelController = PanelController();
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
    UserState state = context.read<UserBloc>().state;
    if (state is! UserLoggedInState) return Text("How are you here 🕵️‍♂️‍");

    bool initialLiked = false;

    for (var element in state.likedItems) {
      if (element.id == widget.item.id) initialLiked = true;
    }

    _likeController.setLiked(initialLiked);

    if (widget.editorOpened) {
      WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
      if (!openedEditorPreviously) {
        _panelController.open();
        setState(() {
          openedEditorPreviously = true;
        });
      }
    });
    }

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
                                  onImageTap: state.businessId == widget.item.businessId
                                      ? (index) async {
                                          bool isLast = index == images.length;
                                          if (isLast) {
                                            File? file = await filePickRoutine();
                                            if (file == null) return;

                                            ItemModel item = await swapImageOfItem(state.token, widget.item.id.hexString, file, widget.item.images.length);
                                            context.read<UserBloc>().add(BusinessUserFrontendUpdateItem(item));
                                            Navigator.pushReplacement(context, MaterialPageRoute(builder: (ctx) => ItemPage(item: item)));
                                            return;
                                          }
                                          showDialog(
                                            context: context,
                                            builder: (ctx) => AlertDialog(
                                              title: Text(
                                                'Modify image',
                                                style: Theme.of(context).textTheme.headline3?.copyWith(fontSize: 16.sp),
                                              ),
                                              actions: [
                                                TextButton(
                                                  onPressed: () async {
                                                    ItemModel item = await removeImageFromItem(state.token, widget.item.id.hexString, index);
                                                    Navigator.pop(context);
                                                    context.read<UserBloc>().add(BusinessUserFrontendUpdateItem(item));
                                                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (ctx) => ItemPage(item: item)));
                                                  },
                                                  style: ButtonStyle(
                                                      splashFactory: InkRipple.splashFactory,
                                                      textStyle: MaterialStateProperty.all(
                                                          Theme.of(context).textTheme.headline3?.copyWith(fontSize: 14.sp))),
                                                  child: Text(
                                                    'DELETE',
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .headline3
                                                        ?.copyWith(color: primaryComplementaryColor, fontSize: 14.sp),
                                                  ),
                                                ),
                                                TextButton(
                                                  onPressed: () async {
                                                    File? file = await filePickRoutine();
                                                    if (file == null) return;
                                                    Navigator.of(context).pop();
                                                    ItemModel item = await swapImageOfItem(state.token, widget.item.id.hexString, file, index);
                                                    context.read<UserBloc>().add(BusinessUserFrontendUpdateItem(item));
                                                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (ctx) => ItemPage(item: item)));
                                                  },
                                                  style: ButtonStyle(
                                                      splashFactory: InkRipple.splashFactory,
                                                      textStyle: MaterialStateProperty.all(
                                                          Theme.of(context).textTheme.headline3?.copyWith(fontSize: 14.sp))),
                                                  child: Text(
                                                    'CHANGE',
                                                    style: Theme.of(context).textTheme.headline3?.copyWith(fontSize: 14.sp),
                                                  ),
                                                ),
                                                TextButton(
                                                  onPressed: () => Navigator.pop(context),
                                                  style: ButtonStyle(
                                                      splashFactory: InkRipple.splashFactory,
                                                      textStyle: MaterialStateProperty.all(
                                                          Theme.of(context).textTheme.headline3?.copyWith(fontSize: 14.sp))),
                                                  child: Text(
                                                    'CANCEL',
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .headline3
                                                        ?.copyWith(color: Colors.grey[600]!.withOpacity(0.7), fontSize: 14.sp),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          );
                                        }
                                      : null,
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
                    buildDetailsTab(constraints, context),
                  ],
                ),
              ),
              // Positioned(
              //   bottom: 0,
              //   child: ConstrainedBox(
              //     child: ,
              //     constraints: BoxConstraints(
              //       minHeight: 10,
              //       maxHeight: 70
              //     ),
              //   ),
              // ),
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
                    minHeight: 90,
                    maxHeight: 90,
                  ),
                  child: FilterSideBar(
                    controller: _widgetSwapController,
                    customBody: [
                      buildDatabaseLikeButton(
                        widget.item,
                        _likeController,
                        context,
                        initialLiked,
                        color: primaryComplementaryColor,
                        backgroundColor: Theme.of(context).primaryColor,
                        splashColor: Colors.white.withOpacity(0.6),
                        borderRadius: const BorderRadius.all(Radius.circular(15)),
                        padding: const EdgeInsets.all(4),
                      ),
                      if (state.businessId == widget.item.businessId)
                        Material(
                          color: Theme.of(context).primaryColor,
                          child: IconButton(
                            splashColor: Colors.white.withOpacity(0.6),
                            splashRadius: 20,
                            visualDensity: VisualDensity.compact,
                            onPressed: () {
                              print("pressed edit");
                              _panelController.open();
                            },
                            icon: const Icon(
                              Icons.edit,
                              color: Colors.white,
                            ),
                          ),
                        )
                    ],
                  ),
                ),
              ),
              // ItemEditPanel(
              //   item: widget.item,
              //   panelController: _panelController,
              // ),
              Positioned(
                bottom: -100.w * 0.2,
                child: ConstrainedBox(
                  child: ItemEditPanel(item: widget.item, panelController: _panelController),
                  constraints: BoxConstraints(
                    minWidth: 100.w,
                    maxHeight: 100.h,
                    maxWidth: 100.w,
                    minHeight: 100.h
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
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
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

    return sumRatings / (widget.item.reviews.isEmpty ? 1 : widget.item.reviews.length);
  }

  Future<File?> filePickRoutine() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      return File(result.files.single.path!);
    } else {
      // User canceled the picker
    }
  }
}
