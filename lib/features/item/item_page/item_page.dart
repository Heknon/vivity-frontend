import 'dart:async';
import 'dart:io';

import 'package:advanced_panel/panel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:no_interaction_dialog/load_dialog.dart';
import 'package:sizer/sizer.dart';
import 'package:vivity/config/themes/themes_config.dart';
import 'package:vivity/features/cart/bloc/cart_bloc.dart';
import 'package:vivity/features/cart/models/cart_item_model.dart';
import 'package:vivity/features/cart/models/modification_button_data_host.dart';
import 'package:vivity/features/cart/repo/cart_repository.dart';
import 'package:vivity/features/item/item_edit_panel.dart';
import 'package:vivity/features/like/bloc/liked_bloc.dart';
import 'package:vivity/features/item/models/modification_button.dart';
import 'package:vivity/features/item/repo/item_repository.dart';
import 'package:vivity/features/item/ui_item_helper.dart';
import 'package:vivity/features/user/models/business_user.dart';
import 'package:vivity/features/user/models/user.dart';
import 'package:vivity/features/user/repo/user_repository.dart';
import 'package:vivity/helpers/ui_helpers.dart';
import '../../base_page.dart';
import '../../cart/shopping_cart.dart';
import 'package:vivity/features/item/models/item_model.dart';
import 'package:vivity/features/item/modifier/item_modifier_selector.dart';
import 'package:vivity/features/search_filter/filter_side_bar.dart';
import 'package:vivity/features/search_filter/widget_swapper.dart';
import 'package:vivity/widgets/appbar/appbar.dart';
import 'package:vivity/widgets/carousel.dart';
import 'package:vivity/widgets/quantity.dart';
import 'package:vivity/widgets/rating.dart';

import '../../like/like_button.dart';
import '../modifier/item_modifier.dart';

class ItemPage extends StatefulWidget {
  final ItemModel item;
  final bool editorOpened;
  final bool registerView;

  const ItemPage({
    Key? key,
    required this.item,
    this.editorOpened = false,
    this.registerView = true,
  }) : super(key: key);

  @override
  State<ItemPage> createState() => _ItemPageState();
}

class _ItemPageState extends State<ItemPage> {
  late final ItemRepository _itemRepository = ItemRepository();
  late final UserRepository _userRepository = UserRepository();
  late CartBloc _cartBloc;

  late List<ItemModifierSelectorController> _selectorControllers;
  late QuantityController _quantityController;
  late LikeButtonController _likeController;

  late WidgetSwapperController _widgetSwapController;

  late PanelController _panelController;

  final LoadDialog _loadDialog = LoadDialog();

  bool openedEditorPreviously = false;
  bool _loadDialogOpen = false;

  late Future<ItemModel> displayedItemFuture;
  late ItemModel displayedItem;
  late bool ownsItem;
  bool finishedInit = false;

  @override
  void initState() {
    super.initState();

    _likeController = LikeButtonController();
    _panelController = PanelController();

    Completer<ItemModel> displayedItemCompleter = Completer();
    displayedItemFuture = displayedItemCompleter.future;
    _itemRepository.getItemFromId(itemId: widget.item.id.hexString, update: true, fetchImagesOnUpdate: true).then((value) async {
      User user = await _userRepository.getUser();
      WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
        setState(() {
          displayedItemCompleter.complete(value ?? displayedItem);
          displayedItem = value ?? widget.item;
          ownsItem = user is BusinessUser && user.businessId == displayedItem.businessId;

          _selectorControllers = List.generate(
            displayedItem.itemStoreFormat.modificationButtons.length,
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

          finishedInit = true;
        });
      });
    });

    if (widget.registerView) _itemRepository.addView(id: widget.item.id.hexString);
    _quantityController = QuantityController();
    _widgetSwapController = WidgetSwapperController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _cartBloc = context.read<CartBloc>();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.editorOpened && !openedEditorPreviously && finishedInit) {
      WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
        _panelController.open();
      });
      openedEditorPreviously = true;
    }

    return BasePage(
      appBar: VivityAppBar(
        bottom: buildTitle(context),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) => defaultGradientBackground(
          child: FutureBuilder<ItemModel>(
            future: displayedItemFuture,
            builder: (context, snapshot) {
              if (snapshot.hasError || !snapshot.hasData)
                return Center(
                  child: CircularProgressIndicator(),
                );

              return Stack(
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
                                images: displayedItem.images,
                                bottomRightRadius: 30,
                                bottomLeftRadius: 30,
                                showAddImage: ownsItem,
                                initialPage: displayedItem.previewImageIndex,
                                imageSize: Size(constraints.maxWidth * 0.7, constraints.maxHeight * 0.5),
                                onImageTap: ownsItem
                                    ? (index) async {
                                        await handleImageTap(index, displayedItem.images.length);
                                      }
                                    : null,
                              ),
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
                        minHeight: ownsItem ? 90 : 55,
                        maxHeight: ownsItem ? 90 : 55,
                      ),
                      child: FilterSideBar(
                        controller: _widgetSwapController,
                        customBody: [
                          buildDatabaseLikeButton(
                            displayedItem,
                            _likeController,
                            context,
                            displayedItem.id.hexString,
                            context.read<LikedBloc>(),
                            color: primaryComplementaryColor,
                            backgroundColor: Theme.of(context).primaryColor,
                            splashColor: Colors.white.withOpacity(0.6),
                            borderRadius: const BorderRadius.all(Radius.circular(15)),
                            padding: const EdgeInsets.all(4),
                          ),
                          if (ownsItem)
                            Material(
                              color: Theme.of(context).primaryColor,
                              child: IconButton(
                                splashColor: Colors.white.withOpacity(0.6),
                                splashRadius: 20,
                                visualDensity: VisualDensity.compact,
                                onPressed: () {
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
                  if (ownsItem)
                    Positioned(
                      bottom: -100.w * 0.2,
                      child: ConstrainedBox(
                        child: ItemEditPanel(item: displayedItem, panelController: _panelController),
                        constraints: BoxConstraints(minWidth: 100.w, maxHeight: 100.h, maxWidth: 100.w, minHeight: 100.h),
                      ),
                    ),
                ],
              );
            },
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
                      '\$${displayedItem.price.toStringAsFixed(2)}',
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
                        max: displayedItem.stock,
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
        overlayColor: MaterialStateProperty.all(Colors.white.withOpacity(0.6)),
        onTap: () async {
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

          showDialog(context: context, builder: (ctx) => _loadDialog);
          _loadDialogOpen = true;
          _cartBloc.add(CartAddItemEvent(CartItemModel(
            quantity: _quantityController.quantity,
            modifiersChosen: generateChosenData(),
            item: displayedItem,
          )));
          await _cartBloc.stream.first;

          if (_loadDialogOpen) {
            Navigator.pop(context);
            _loadDialogOpen = false;
          }
        },
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
    );
  }

  Column buildRatingView(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Rating(
          rating: calculateRating(),
          color: Colors.white,
        ),
        Text(
          '(${displayedItem.reviews.length} reviews)',
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
          displayedItem.itemStoreFormat.title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.headline4?.copyWith(color: Colors.white, fontSize: 16.sp),
        ),
        SizedBox(
          height: 4,
        ),
        Text(
          "${displayedItem.businessName}'s shop",
          style: Theme.of(context).textTheme.subtitle1?.copyWith(fontSize: 10.sp),
        ),
      ],
    );
  }

  Row buildModificationButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(
        displayedItem.itemStoreFormat.modificationButtons.length,
        (index) {
          ModificationButton button = displayedItem.itemStoreFormat.modificationButtons[index];
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

  List<ModificationButtonDataHost> generateChosenData() {
    List<ModificationButtonDataHost> dataHosts = List.empty(growable: true);
    ItemModel item = displayedItem;

    for (int i = 0; i < _selectorControllers.length; i++) {
      ItemModifierSelectorController controller = _selectorControllers[i];
      ModificationButton modButton = item.itemStoreFormat.modificationButtons[i];
      List<Object> data = List.empty(growable: true);
      for (int index in controller.chosenIndices) {
        data.add(modButton.data[index]);
      }

      dataHosts.add(ModificationButtonDataHost(name: modButton.name, dataType: modButton.dataType, selectedData: data));
    }

    return dataHosts;
  }

  double calculateRating() {
    double sumRatings = 0;

    displayedItem.reviews.forEach((element) {
      sumRatings += element.rating;
    });

    return sumRatings / (displayedItem.reviews.isEmpty ? 1 : displayedItem.reviews.length);
  }

  Future<File?> filePickRoutine() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      return File(result.files.single.path!);
    } else {
      // User canceled the picker
    }
  }

  Future<void> handleImageTap(int index, int imagesLength) async {
    bool isLast = index == imagesLength;
    if (isLast) {
      File? file = await filePickRoutine();
      if (file == null) return;

      showDialog(context: context, builder: (ctx) => _loadDialog);
      _loadDialogOpen = true;
      ItemModel item = await _itemRepository.updateItemImage(
        image: file,
        index: index,
        id: displayedItem.id.hexString,
      );


      if (_loadDialogOpen) {
        Navigator.pop(context);
        _loadDialogOpen = false;
      }

      WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
        setState(() {
          displayedItemFuture = Future.value(item);
          displayedItem = item;
          print(displayedItem.images.length);
        });
      });
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
              Navigator.pop(context);
              showDialog(context: context, builder: (ctx) => _loadDialog);
              _loadDialogOpen = true;
              ItemModel item = await _itemRepository.deleteItemImage(
                index: index,
                id: displayedItem.id.hexString,
              );

              if (_loadDialogOpen) {
                Navigator.pop(context);
                _loadDialogOpen = false;
              }

              WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
                setState(() {
                  displayedItemFuture = Future.value(item);
                  displayedItem = item;
                });
              });
            },
            style: ButtonStyle(
                splashFactory: InkRipple.splashFactory,
                textStyle: MaterialStateProperty.all(Theme.of(context).textTheme.headline3?.copyWith(fontSize: 14.sp))),
            child: Text(
              'DELETE',
              style: Theme.of(context).textTheme.headline3?.copyWith(color: primaryComplementaryColor, fontSize: 14.sp),
            ),
          ),
          TextButton(
            onPressed: () async {
              File? file = await filePickRoutine();
              if (file == null) return;
              Navigator.of(context).pop();
              showDialog(context: context, builder: (ctx) => _loadDialog);
              _loadDialogOpen = true;
              ItemModel item = await _itemRepository.updateItemImage(
                image: file,
                index: index,
                id: displayedItem.id.hexString,
              );


              if (_loadDialogOpen) {
                Navigator.pop(context);
                _loadDialogOpen = false;
              }

              WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
                setState(() {
                  displayedItemFuture = Future.value(item);
                  displayedItem = item;
                });
              });
            },
            style: ButtonStyle(
                splashFactory: InkRipple.splashFactory,
                textStyle: MaterialStateProperty.all(Theme.of(context).textTheme.headline3?.copyWith(fontSize: 14.sp))),
            child: Text(
              'CHANGE',
              style: Theme.of(context).textTheme.headline3?.copyWith(fontSize: 14.sp),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: ButtonStyle(
                splashFactory: InkRipple.splashFactory,
                textStyle: MaterialStateProperty.all(Theme.of(context).textTheme.headline3?.copyWith(fontSize: 14.sp))),
            child: Text(
              'CANCEL',
              style: Theme.of(context).textTheme.headline3?.copyWith(color: Colors.grey[600]!.withOpacity(0.7), fontSize: 14.sp),
            ),
          ),
        ],
      ),
    );
  }
}
