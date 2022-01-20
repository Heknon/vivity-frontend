import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import 'package:vivity/constants/app_constants.dart';
import 'package:vivity/features/item/models/item_model.dart';
import 'package:vivity/widgets/quantity.dart';
import '../../features/item/cart_item/cart_item.dart';

class CartView extends StatefulWidget {
  final ScrollController? scrollController;
  final Iterable<CartItemModel> itemModels;

  CartView({Key? key, this.scrollController, required this.itemModels}) : super(key: key);

  @override
  State<CartView> createState() => _CartViewState();
}

class _CartViewState extends State<CartView> {
  late List<CartItemModel> _itemModels;
  late double _priceSum = 0;

  @override
  void initState() {
    super.initState();

    _itemModels = List.empty(growable: true);
    for (CartItemModel element in widget.itemModels) {
      _priceSum += element.quantity * element.price;
      _itemModels.add(element);
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (ctx, constraints) {
        double itemsToFitInList = 3;
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
                child: ListView.builder(
                  itemCount: 5,
                  controller: widget.scrollController,
                  itemBuilder: (ctx, i) => Padding(
                    padding: i != 0 ? EdgeInsets.only(top: itemsPadding) : const EdgeInsets.only(),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: CartItem(
                        itemModel: _itemModels[i],
                        width: itemSize.width,
                        height: itemSize.height,
                        onQuantityUpdate: onQuantityUpdate,
                        id: i,
                      ),
                    ),
                  ),
                ),
              ),
              Spacer(),
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0),
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
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: Text(
                        'Total: \$' + _priceSum.toStringAsFixed(2),
                        style: GoogleFonts.raleway(fontSize: 18.sp),
                      ),
                    )
                  ],
                ),
              )
            ],
          ),
        );
      },
    );
  }

  void addItemModel(CartItemModel itemModel) {

  }

  void removeItemModel(int index) {

  }

  void removeItemModelByModel(CartItemModel model) {

  }

  void onQuantityUpdate(QuantityController quantityController, int? id) {
    setState(() {
      _priceSum -= _itemModels[id!].quantity * _itemModels[id].price;
      _itemModels[id].quantity = quantityController.quantity;
      _priceSum += _itemModels[id].quantity * _itemModels[id].price;
    });
  }
}
