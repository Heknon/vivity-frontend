import 'package:flutter/foundation.dart';
import 'package:objectid/objectid/objectid.dart';
import 'package:vivity/features/item/models/item_model.dart';
import 'package:vivity/features/user/models/order.dart';

class OrderItem {
  final ObjectId itemId;
  final String previewImage;
  final String title;
  final String? subtitle;
  final String? description;
  final List<ModificationButtonDataHost> selectedModifiers;

  OrderItem({
    required this.itemId,
    required this.previewImage,
    required this.title,
    this.subtitle,
    this.description,
    required this.selectedModifiers,
  });

  factory OrderItem.fromModifiers({
    required ObjectId itemId,
    required String previewImage,
    required String title,
    String? subtitle,
    String? description,
    required List<ModificationButton> modifiers,
    required Map<int, Iterable<int>> dataChosen,
  }) {
    List<ModificationButtonDataHost> chosenData = List.empty(growable: true);
    dataChosen.forEach(
      (key, value) => chosenData.add(ModificationButtonDataHost.fromModificationButton(modifiers[key], value)),
    );

    return OrderItem(
      itemId: itemId,
      previewImage: previewImage,
      selectedModifiers: chosenData,
      title: title,
      description: description,
      subtitle: subtitle,
    );
  }

  factory OrderItem.fromCartItem(CartItemModel cartItem) {
    return OrderItem(
      itemId: cartItem.item.id,
      previewImage: cartItem.previewImage,
      title: cartItem.title,
      selectedModifiers: cartItem.modifiersChosen.toList(),
    );
  }

  factory OrderItem.fromMap(Map<String, dynamic> map) {
    return OrderItem(
      itemId: ObjectId.fromHexString(map['item_id']),
      previewImage: map['preview_image'] as String,
      title: map['title'] as String,
      subtitle: map['subtitle'] as String?,
      description: map['description'] as String?,
      selectedModifiers: (map['selected_modifiers'] as List<dynamic>).map((e) => ModificationButtonDataHost.fromMap(e)).toList(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'item_id': itemId,
      'preview_image': previewImage,
      'title': title,
      'subtitle': subtitle,
      'description': description,
      'selected_modifiers': selectedModifiers.map((e) => e.toMap()).toList(),
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OrderItem &&
          runtimeType == other.runtimeType &&
          itemId == other.itemId &&
          previewImage == other.previewImage &&
          title == other.title &&
          subtitle == other.subtitle &&
          description == other.description &&
          listEquals(selectedModifiers, other.selectedModifiers);

  @override
  int get hashCode =>
      itemId.hashCode ^ previewImage.hashCode ^ title.hashCode ^ subtitle.hashCode ^ description.hashCode ^ selectedModifiers.hashCode;

  @override
  String toString() {
    return 'OrderItem{itemId: $itemId, previewImage: $previewImage, title: $title, subtitle: $subtitle, description: $description, selectedModifiers: $selectedModifiers}';
  }
}
