import 'package:flutter/foundation.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:uuid/uuid.dart';
import 'package:vivity/constants/app_constants.dart';
import 'package:vivity/services/item_service.dart';
import 'package:vivity/services/storage_service.dart';

class CartItemModel {
  final String previewImage;
  final String title;
  final Iterable<ModificationButtonDataHost> chosenData;
  final double price;
  int insertionId;
  ItemModel item;
  int quantity;

  CartItemModel({
    required this.previewImage,
    required this.title,
    required this.chosenData,
    required this.quantity,
    required this.price,
    required this.item,
    this.insertionId = -1,
  });

  /// dataChosen: Key is ModificationButton index value are the indices of the data chosen.
  factory CartItemModel.fromItemModel({required ItemModel model, required int quantity, required Map<int, Iterable<int>> dataChosen}) {
    List<ModificationButtonDataHost> chosenData = List.empty(growable: true);

    dataChosen.forEach(
      (key, value) => chosenData.add(ModificationButtonDataHost.fromModificationButton(model.itemStoreFormat.modificationButtons[key], value)),
    );

    return CartItemModel(
      previewImage: model.images[model.previewImageIndex],
      title: model.itemStoreFormat.title,
      chosenData: chosenData,
      quantity: quantity,
      price: model.price,
      item: model,
    );
  }

  CartItemModel copyWith({
    String? previewImage,
    String? title,
    Iterable<ModificationButtonDataHost>? chosenData,
    double? price,
    int? quantity,
    List<int>? id,
    ItemModel? model,
    int? insertionId,
  }) {
    return CartItemModel(
      previewImage: previewImage ?? this.previewImage,
      title: title ?? this.title,
      chosenData: chosenData ?? this.chosenData.map((e) => e.copyWith()).toList(growable: false),
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
      item: model ?? item,
      insertionId: insertionId ?? this.insertionId,
    );
  }

  factory CartItemModel.fromMap(Map<String, dynamic> map) {
    ItemModel item;
    try {
      // TODO: Implement check to see if item no longer exists. if it doesn't remove. An error can also be a connection error.
      item = getItemFromId(map['id']) ?? itemModelDemo2;
    } catch (ex) {
      rethrow;
    }

    return CartItemModel(
      previewImage: map['previewImage'] as String,
      title: map['title'] as String,
      chosenData: (map['chosenData'] as List<dynamic>).map((e) => ModificationButtonDataHost.fromMap(e)).toList(),
      price: map['price'] as double,
      quantity: map['quantity'] as int,
      item: item,
    );
  }

  Map<String, dynamic> toMap() {
    // ignore: unnecessary_cast
    return {
      'previewImage': previewImage,
      'title': title,
      'chosenData': chosenData.map((e) => e.toMap()).toList(),
      'price': price,
      'quantity': quantity,
      'id': item.id,
    } as Map<String, dynamic>;
  }

  @override
  String toString() {
    return 'CartItemModel{previewImage: $previewImage, title: $title, chosenData: $chosenData, price: $price, quantity: $quantity, insertionId: $insertionId}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CartItemModel &&
          runtimeType == other.runtimeType &&
          previewImage == other.previewImage &&
          title == other.title &&
          listEquals(chosenData.toList(), other.chosenData.toList()) &&
          price == other.price &&
          listEquals(item.id, other.item.id) &&
          quantity == other.quantity;

  bool looseEquals(Object other) {
    print("THIS: $this");
    print("OTHER: $other");
    return identical(this, other) ||
      other is CartItemModel &&
          runtimeType == other.runtimeType &&
          previewImage == other.previewImage &&
          title == other.title &&
          listEquals(chosenData.toList(), other.chosenData.toList()) &&
          price == other.price &&
          listEquals(item.id, other.item.id);
  }

  @override
  int get hashCode => previewImage.hashCode ^ title.hashCode ^ chosenData.hashCode ^ price.hashCode ^ item.id.hashCode ^ quantity.hashCode;
}

class ItemModel {
  final String businessName;
  final double price;
  final List<String> images;
  final int previewImageIndex;
  final List<Review> reviews;
  final ItemStoreFormat itemStoreFormat;
  final String brand;
  final String category;
  final List<String> tags;
  final int stock;
  final List<int> id;

  const ItemModel({
    required this.businessName,
    required this.price,
    required this.images,
    this.previewImageIndex = 0,
    required this.reviews,
    required this.itemStoreFormat,
    required this.brand,
    required this.category,
    required this.tags,
    required this.stock,
    required this.id,
  });

  @override
  String toString() {
    return 'ItemModel{businessName: $businessName, price: $price, images: $images, previewImageIndex: $previewImageIndex, reviews: $reviews, itemStoreFormat: $itemStoreFormat, brand: $brand, category: $category, tags: $tags, stock: $stock}';
  }

  ItemModel copyWith({
    String? businessName,
    double? price,
    List<String>? images,
    int? previewImageIndex,
    List<Review>? reviews,
    ItemStoreFormat? itemStoreFormat,
    String? brand,
    String? category,
    List<String>? tags,
    int? stock,
    List<int>? id,
  }) {
    return ItemModel(
        businessName: businessName ?? this.businessName,
        price: price ?? this.price,
        images: images ?? this.images,
        previewImageIndex: previewImageIndex ?? this.previewImageIndex,
        reviews: reviews ?? this.reviews,
        itemStoreFormat: itemStoreFormat ?? this.itemStoreFormat.copyWith(),
        brand: brand ?? this.brand,
        category: category ?? this.category,
        tags: tags ?? this.tags,
        stock: stock ?? this.stock,
        id: id ?? this.id);
  }
}

class Review {
  final String posterName;
  final String pfpImage;
  final double rating;
  final String textContent;
  final List<String> imageUrls;

  const Review({required this.posterName, required this.pfpImage, required this.rating, required this.textContent, required this.imageUrls});

  @override
  String toString() {
    return 'Review{posterName: $posterName, pfpImage: $pfpImage, rating: $rating, textContent: $textContent, imageUrls: $imageUrls}';
  }

  Review copyWith({
    String? posterName,
    String? pfpImage,
    double? rating,
    String? textContent,
    List<String>? imageUrls,
  }) {
    return Review(
      posterName: posterName ?? this.posterName,
      pfpImage: pfpImage ?? this.pfpImage,
      rating: rating ?? this.rating,
      textContent: textContent ?? this.textContent,
      imageUrls: imageUrls ?? this.imageUrls,
    );
  }
}

class ItemStoreFormat {
  final String title;
  final String? subtitle;
  final String? description;
  final List<ModificationButton> modificationButtons;

  const ItemStoreFormat({required this.title, this.subtitle, this.description, this.modificationButtons = const []});

  @override
  String toString() {
    return 'ItemStoreFormat{title: $title, subtitle: $subtitle, description: $description, modificationButtons: $modificationButtons}';
  }

  ItemStoreFormat copyWith({
    String? title,
    String? subtitle,
    String? description,
    List<ModificationButton>? modificationButtons,
  }) {
    return ItemStoreFormat(
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      description: description ?? this.description,
      modificationButtons: modificationButtons ?? this.modificationButtons.map((e) => e.copyWith()).toList(),
    );
  }
}

enum ModificationButtonSide {
  left,
  center,
  right,
}

enum ModificationButtonDataType {
  text,
  color,
  image,
}

class ModificationButtonDataHost {
  final String name;
  final ModificationButtonDataType dataType;
  final List<dynamic> dataChosen;

  ModificationButtonDataHost({required this.name, required this.dataType, required this.dataChosen});

  factory ModificationButtonDataHost.fromModificationButton(ModificationButton button, Iterable<int> chosenIndices) {
    int dataLength = button.data.length;
    List<dynamic> chosenData = List.empty(growable: true);

    for (int index in chosenIndices) {
      if (index >= dataLength) throw IndexError(index, dataLength, "Chosen indices passed an index out of the data's range!");

      chosenData.add(button.data[index]);
    }

    return ModificationButtonDataHost(name: button.name, dataType: button.dataType, dataChosen: chosenData);
  }

  @override
  String toString() {
    return 'ModificationButtonDataHost{name: $name, dataType: $dataType, dataChosen: $dataChosen}';
  }

  ModificationButtonDataHost copyWith({
    String? name,
    ModificationButtonDataType? dataType,
    List<Object>? dataChosen,
  }) {
    return ModificationButtonDataHost(
      name: name ?? this.name,
      dataType: dataType ?? this.dataType,
      dataChosen: dataChosen ?? this.dataChosen,
    );
  }

  factory ModificationButtonDataHost.fromMap(Map<String, dynamic> map) {
    return ModificationButtonDataHost(
      name: map['name'] as String,
      dataType: ModificationButtonDataType.values[map['dataType']],
      dataChosen: map['dataChosen'] as List<dynamic>,
    );
  }

  Map<String, dynamic> toMap() {
    // ignore: unnecessary_cast
    return {
      'name': name,
      'dataType': dataType.index,
      'dataChosen': dataChosen,
    } as Map<String, dynamic>;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ModificationButtonDataHost &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          dataType == other.dataType &&
          listEquals(dataChosen, other.dataChosen);

  @override
  int get hashCode => name.hashCode ^ dataType.hashCode ^ dataChosen.hashCode;
}

class ModificationButton {
  final String name;
  final ModificationButtonSide modificationButtonSide;
  final List<Object> data;
  final ModificationButtonDataType dataType;
  final bool multiSelect;

  const ModificationButton({
    required this.name,
    required this.data,
    required this.dataType,
    this.multiSelect = false,
    required this.modificationButtonSide,
  });

  @override
  String toString() {
    return 'ModificationButton{name: $name, modificationButtonSide: $modificationButtonSide, data: $data, dataType: $dataType, multiSelect: $multiSelect}';
  }

  ModificationButton copyWith({
    String? name,
    ModificationButtonSide? modificationButtonSide,
    List<Object>? data,
    ModificationButtonDataType? dataType,
    bool? multiSelect,
  }) {
    return ModificationButton(
      name: name ?? this.name,
      modificationButtonSide: modificationButtonSide ?? this.modificationButtonSide,
      data: data ?? this.data,
      dataType: dataType ?? this.dataType,
      multiSelect: multiSelect ?? this.multiSelect,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ModificationButton &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          modificationButtonSide == other.modificationButtonSide &&
          listEquals(data, other.data) &&
          dataType == other.dataType &&
          multiSelect == other.multiSelect;

  @override
  int get hashCode => name.hashCode ^ modificationButtonSide.hashCode ^ data.hashCode ^ dataType.hashCode ^ multiSelect.hashCode;
}
