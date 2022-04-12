import 'package:objectid/objectid/objectid.dart';
import 'package:vivity/features/cart/models/modification_button_data_host.dart';
import 'package:vivity/features/item/models/item_model.dart';

class CartItemModel {
  final ItemModel item;
  final Iterable<ModificationButtonDataHost> modifiersChosen;
  final int quantity;

//<editor-fold desc="Data Methods">

  const CartItemModel({
    required this.item,
    required this.modifiersChosen,
    required this.quantity,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CartItemModel &&
          runtimeType == other.runtimeType &&
          item == other.item &&
          modifiersChosen == other.modifiersChosen &&
          quantity == other.quantity);

  @override
  int get hashCode =>
      item.hashCode ^ modifiersChosen.hashCode ^ quantity.hashCode;

  @override
  String toString() {
    return 'CartItemModel{' +
        ' item: $item,' +
        ' modifiersChosen: $modifiersChosen,' +
        ' quantity: $quantity,' +
        '}';
  }

  CartItemModel copyWith({
    ItemModel? item,
    Iterable<ModificationButtonDataHost>? modifiersChosen,
    int? quantity,
  }) {
    return CartItemModel(
      item: item ?? this.item,
      modifiersChosen: modifiersChosen ?? this.modifiersChosen,
      quantity: quantity ?? this.quantity,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'item_id': this.item,
      'modifiers_chosen': this.modifiersChosen.map((e) => e.toMap()),
      'quantity': this.quantity,
    };
  }

  factory CartItemModel.fromMap(Map<String, dynamic> map, ItemModel item) {
    assert(
      ObjectId.fromHexString(map['item_id']) == item.id,
      'Item passed to CartItemModel is not matching to the map item id given',
    );

    return CartItemModel(
      item: item,
      modifiersChosen: (map['modifiers_chosen'] as List<dynamic>)
          .map((e) => ModificationButtonDataHost.fromMap(e)),
      quantity: map['quantity'] as int,
    );
  }

//</editor-fold>
}
