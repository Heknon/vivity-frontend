import 'package:vivity/features/item/models/item_model.dart';

class ItemPageNavigation {
  final ItemModel item;
  final bool isView;
  final bool shouldOpenEditor;

//<editor-fold desc="Data Methods">

  const ItemPageNavigation({
    required this.item,
    this.isView = true,
    this.shouldOpenEditor = false,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ItemPageNavigation &&
          runtimeType == other.runtimeType &&
          item == other.item &&
          isView == other.isView &&
          shouldOpenEditor == other.shouldOpenEditor);

  @override
  int get hashCode => item.hashCode ^ isView.hashCode ^ shouldOpenEditor.hashCode;

  @override
  String toString() {
    return 'ItemPageNavigation{' + ' item: $item,' + ' isView: $isView,' + '}';
  }

  ItemPageNavigation copyWith({
    ItemModel? item,
    bool? isView,
    bool? shouldOpenEditor,
  }) {
    return ItemPageNavigation(
      item: item ?? this.item,
      isView: isView ?? this.isView,
      shouldOpenEditor:  shouldOpenEditor ?? this.shouldOpenEditor,
    );
  }

//</editor-fold>
}
