import 'package:vivity/features/item/models/item_model.dart';

class ItemPageNavigation {
  final ItemModel item;
  final bool isView;

//<editor-fold desc="Data Methods">

  const ItemPageNavigation({
    required this.item,
    this.isView = true,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is ItemPageNavigation && runtimeType == other.runtimeType && item == other.item && isView == other.isView);

  @override
  int get hashCode => item.hashCode ^ isView.hashCode;

  @override
  String toString() {
    return 'ItemPageNavigation{' + ' item: $item,' + ' isView: $isView,' + '}';
  }

  ItemPageNavigation copyWith({
    ItemModel? item,
    bool? isView,
  }) {
    return ItemPageNavigation(
      item: item ?? this.item,
      isView: isView ?? this.isView,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'item': this.item,
      'isView': this.isView,
    };
  }

  factory ItemPageNavigation.fromMap(Map<String, dynamic> map) {
    return ItemPageNavigation(
      item: map['item'] as ItemModel,
      isView: map['isView'] as bool,
    );
  }

//</editor-fold>
}