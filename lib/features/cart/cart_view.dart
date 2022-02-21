import 'package:fade_in_widget/fade_in_widget.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import 'package:uuid/uuid.dart';
import 'package:vivity/constants/app_constants.dart';
import 'package:vivity/features/item/models/item_model.dart';
import 'package:vivity/widgets/quantity.dart';
import '../../../features/item/cart_item/cart_item.dart';
import 'cart_bloc/cart_bloc.dart';

class CartView extends StatefulWidget {
  final ScrollController? scrollController;
  final Iterable<CartItemModel> itemModels;
  final CartViewController? controller;

  const CartView({
    Key? key,
    this.scrollController,
    required this.itemModels,
    this.controller,
  }) : super(key: key);

  @override
  State<CartView> createState() => _CartViewState();
}

FadeInController controller = FadeInController();

class _CartViewState extends State<CartView> {
  late CartViewController _controller;

  @override
  void initState() {
    super.initState();

    _controller = widget.controller ?? CartViewController();
    _controller.init(items: widget.itemModels);

    _controller.addListener(() {
      setState(() {});

      updateCost();
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (ctx, constraints) {
        double itemsToFitInList = 2.7;
        double listPadding = 15;
        double itemsPadding = 25;
        Size listSize = Size(constraints.maxWidth * 0.9, constraints.maxHeight * 0.8);
        Size itemSize = Size(listSize.width * 0.95, (listSize.height) / itemsToFitInList);

        return Material(
          elevation: 7,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(15),
              bottomLeft: Radius.circular(15),
            ),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.only(top: listPadding),
                height: listSize.height,
                width: listSize.width,
                child: _controller.itemModels.isEmpty
                    ? Align(
                        alignment: Alignment.center.add(Alignment(constraints.maxWidth / 4, 0)),
                        child: Text(
                          "Start adding items to your cart!",
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.headline4?.copyWith(fontSize: 16.sp),
                        ),
                      )
                    : buildItemsList(itemsPadding, itemSize),
              ),
              Spacer(),
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    buildCheckoutButton(context),
                    buildCheckoutCostInfo(),
                  ],
                ),
              )
            ],
          ),
        );
      },
    );
  }

  ListView buildItemsList(double itemsPadding, Size itemSize) {
    return ListView.builder(
      itemCount: _controller.itemModels.length,
      controller: widget.scrollController,
      itemBuilder: (ctx, i) => Padding(
        padding: i != 0 ? EdgeInsets.only(top: itemsPadding) : const EdgeInsets.only(),
        child: Align(
          alignment: Alignment.centerLeft,
          child: CartItem(
            itemModel: _controller.itemModels[i],
            width: itemSize.width,
            height: itemSize.height,
            onQuantityIncrement: onQuantityIncrement,
            onQuantityDecrement: onQuantityDecrement,
            id: _controller.itemModels[i].insertionId,
          ),
        ),
      ),
    );
  }

  Padding buildCheckoutCostInfo() {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: 18.sp + 8, minHeight: 18.sp + 8),
        child: NotificationListener(
          onNotification: (SizeChangedLayoutNotification notification) {
            WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
              controller.swapCurrentWidget(
                Text(
                  'Total: \$' + (_controller.priceSum).toStringAsFixed(2),
                  style: GoogleFonts.raleway(fontSize: 18.sp),
                ),
              );
            });
            return true;
          },
          child: SizeChangedLayoutNotifier(
            child: FadeInWidget(
              duration: Duration(milliseconds: 500),
              controller: controller,
              initialWidget: Text(
                'Total: \$' + (_controller.priceSum).toStringAsFixed(2),
                style: GoogleFonts.raleway(fontSize: 18.sp),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Padding buildCheckoutButton(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 8),
      child: TextButton(
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all(Theme.of(context).colorScheme.primary),
          elevation: MaterialStateProperty.all(7),
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
          ),
          splashFactory: InkSplash.splashFactory,
        ),
        onPressed: () {},
        child: Text(
          'Checkout',
          style: TextStyle(
            color: Colors.white,
            fontFamily: "Futura",
            fontSize: 18.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  void onQuantityIncrement(QuantityController quantityController, int? id) {
    BlocProvider.of<CartBloc>(context).add(CartIncrementItemEvent(id!));

    _controller.incrementQuantity(id);
  }

  void onQuantityDecrement(QuantityController quantityController, int? id) {
    BlocProvider.of<CartBloc>(context).add(CartDecrementItemEvent(id!));

    _controller.decrementQuantity(id);
  }

  void updateCost() {
    controller.gracefullySwapCurrentAnimatedWidget(
      Text(
        'Total: \$' + _controller.priceSum.toStringAsFixed(2),
        style: GoogleFonts.raleway(fontSize: 18.sp),
      ),
    );
  }
}

//TODO: Move to Bloc state...
class CartViewController extends ChangeNotifier {
  late List<CartItemModel> itemModels;
  late double priceSum = 0;

  void init({Iterable<CartItemModel>? items}) {
    itemModels = items?.toList() ?? List.empty(growable: true);

    int insertionId = 0;
    for (CartItemModel item in itemModels) {
      item.insertionId = insertionId++;
      priceSum += item.price * item.quantity;
    }
  }

  void addItem(CartItemModel item) {
    if (item.quantity <= 0) {
      throw Exception("Error! Can only add an item with a quantity above 0.");
    }

    Iterable<CartItemModel> cartedItems = itemModels.where((element) => element == item);
    if (cartedItems.isNotEmpty) {
      CartItemModel cartedItem = cartedItems.first;
      cartedItem.quantity += item.quantity;
      priceSum += item.price * item.quantity;
      notifyListeners();
      return;
    }

    itemModels.add(item);
    priceSum += item.price * item.quantity;
    notifyListeners();
  }

  void removeItem(int insertionId) {
    bool removed = false;

    itemModels.removeWhere((element) {
      if (element.insertionId == insertionId) {
        priceSum -= element.price * element.quantity;
        element.quantity = 0;
        removed = true;
        return true;
      }

      return false;
    });

    if (removed) notifyListeners();
  }

  void decrementQuantity(int insertionId) {
    CartItemModel item = getItem(insertionId);
    item.quantity--;
    priceSum -= item.price;

    if (item.quantity <= 0) {
      removeItem(insertionId);
    }

    notifyListeners();
  }

  void incrementQuantity(int insertionId) {
    CartItemModel item = getItem(insertionId);
    item.quantity++;
    priceSum += item.price;
    notifyListeners();
  }

  CartItemModel getItem(int insertionId) {
    return itemModels.where((element) => element.insertionId == insertionId).first;
  }
}
