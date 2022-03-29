import 'package:flutter/foundation.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:objectid/objectid/objectid.dart';
import 'package:uuid/uuid.dart';
import 'package:vivity/constants/app_constants.dart';
import 'package:vivity/services/item_service.dart';
import 'package:vivity/services/storage_service.dart';
import 'package:latlong2/latlong.dart';


class CartItemModel {
  final String previewImage;
  final String title;
  final Iterable<ModificationButtonDataHost> modifiersChosen;
  final double price;
  int insertionId;
  ItemModel item;
  int quantity;

  CartItemModel({
    required this.previewImage,
    required this.title,
    required this.modifiersChosen,
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
      modifiersChosen: chosenData,
      quantity: quantity,
      price: model.price,
      item: model,
    );
  }

  CartItemModel copyWith({
    String? previewImage,
    String? title,
    Iterable<ModificationButtonDataHost>? modifiersChosen,
    double? price,
    int? quantity,
    ObjectId? id,
    ItemModel? model,
    int? insertionId,
  }) {
    return CartItemModel(
      previewImage: previewImage ?? this.previewImage,
      title: title ?? this.title,
      modifiersChosen: modifiersChosen ?? this.modifiersChosen.map((e) => e.copyWith()).toList(growable: false),
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
      item: model ?? item,
      insertionId: insertionId ?? this.insertionId,
    );
  }

  factory CartItemModel.fromMap(Map<String, dynamic> map, ItemModel itemModel) {
    return CartItemModel(
      previewImage: map['previewImage'] as String,
      title: map['title'] as String,
      modifiersChosen: (map['modifiersChosen'] as List<dynamic>).map((e) => ModificationButtonDataHost.fromMap(e)).toList(),
      price: map['price'] as double,
      quantity: map['quantity'] as int,
      item: itemModel,
    );
  }

  Map<String, dynamic> toMap() {
    // ignore: unnecessary_cast
    return {
      'previewImage': previewImage,
      'title': title,
      'modifiersChosen': modifiersChosen.map((e) => e.toMap()).toList(),
      'price': price,
      'quantity': quantity,
      'id': item.id,
      'businessId': item.businessId,
    } as Map<String, dynamic>;
  }

  @override
  String toString() {
    return 'CartItemModel{previewImage: $previewImage, title: $title, chosenData: $modifiersChosen, price: $price, quantity: $quantity, insertionId: $insertionId, id: ${item.id}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CartItemModel &&
          runtimeType == other.runtimeType &&
          previewImage == other.previewImage &&
          title == other.title &&
          listEquals(modifiersChosen.toList(), other.modifiersChosen.toList()) &&
          price == other.price &&
          item.id == other.item.id &&
          quantity == other.quantity;

  bool looseEquals(Object other) {
    return identical(this, other) ||
        other is CartItemModel &&
            runtimeType == other.runtimeType &&
            previewImage == other.previewImage &&
            title == other.title &&
            listEquals(modifiersChosen.toList(), other.modifiersChosen.toList()) &&
            price == other.price &&
            item.id == other.item.id;
  }

  @override
  int get hashCode => previewImage.hashCode ^ title.hashCode ^ modifiersChosen.hashCode ^ price.hashCode ^ item.id.hashCode ^ quantity.hashCode;
}

class ItemModel {
  final ObjectId businessId;
  final ObjectId id;
  final String businessName;
  final LatLng location;
  final double price;
  final List<String> images;
  final int previewImageIndex;
  final List<Review> reviews;
  final ItemStoreFormat itemStoreFormat;
  final String brand;
  final String category;
  final List<String> tags;
  final int stock;

  const ItemModel({
    required this.id,
    required this.businessId,
    required this.location,
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
  });

  @override
  String toString() {
    return 'ItemModel{businessName: $businessName, price: $price, images: $images, previewImageIndex: $previewImageIndex, reviews: $reviews, itemStoreFormat: $itemStoreFormat, brand: $brand, category: $category, tags: $tags, stock: $stock}';
  }

  ItemModel copyWith({
    ObjectId? id,
    ObjectId? businessId,
    LatLng? location,
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
  }) {
    return ItemModel(
      businessId: businessId ?? this.businessId,
      location: location ?? this.location,
      id: id ?? this.id,
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
    );
  }

  factory ItemModel.fromDBMap(Map<String, dynamic> map) {
    return ItemModel(
      businessId: ObjectId.fromHexString(map['business_id']),
      location: LatLng(map['location'][0], map['location'][1]),
      id: ObjectId.fromHexString(map['_id']),
      businessName: map['business_name'] as String,
      price: map['price'] as double,
      images: (map['images'] as List<dynamic>).map((e) => e as String).toList(),
      previewImageIndex: map['preview_image'] as int,
      reviews: (map['reviews'] as List<dynamic>).map((e) => Review.fromDBMap(e)).toList(),
      itemStoreFormat: ItemStoreFormat.fromDBMap(map['item_store_format']),
      brand: map['brand'] as String,
      category: map['category'] as String,
      tags: (map['tags'] as List<dynamic>).map((e) => e as String).toList(),
      stock: map['stock'] as int,
    );
  }

  Map<String, dynamic> toDBMap() {
    return {
      'business_id': businessId.bytes,
      '_id': id.bytes,
      'business_name': businessName,
      'price': price,
      'images': images,
      'preview_image': previewImageIndex,
      'reviews': reviews.map((e) => e.toDBMap()).toList(),
      'item_store_format': itemStoreFormat.toDBMap(),
      'brand': brand,
      'category': category,
      'tags': tags,
      'stock': stock,
      'location': [location.latitude, location.longitude]
    };
  }
}

class Review {
  final ObjectId posterId;
  final String posterName;
  final String pfpImage;
  final double rating;
  final String textContent;
  final List<String> images;

  const Review({
    required this.posterId,
    required this.posterName,
    required this.pfpImage,
    required this.rating,
    required this.textContent,
    required this.images,
  });

  @override
  String toString() {
    return 'Review{posterName: $posterName, pfpImage: $pfpImage, rating: $rating, textContent: $textContent, imageUrls: $images}';
  }

  Review copyWith({
    ObjectId? posterId,
    String? posterName,
    String? pfpImage,
    double? rating,
    String? textContent,
    List<String>? images,
  }) {
    return Review(
      posterId: posterId ?? this.posterId,
      posterName: posterName ?? this.posterName,
      pfpImage: pfpImage ?? this.pfpImage,
      rating: rating ?? this.rating,
      textContent: textContent ?? this.textContent,
      images: images ?? this.images,
    );
  }

  factory Review.fromDBMap(Map<String, dynamic> map) {
    return Review(
      posterId: ObjectId.fromHexString(map["poster_id"]),
      posterName: map['poster_name'] as String,
      pfpImage: map['pfp_image'] as String,
      rating: (map['rating'] as num).toDouble(),
      textContent: map['text_content'] as String,
      images: (map['images'] as List<dynamic>).map((e) => e as String).toList(),
    );
  }

  Map<String, dynamic> toDBMap() {
    return {
      'poster_id': posterId,
      'poster_name': posterName,
      'pfp_image': pfpImage,
      'rating': rating,
      'text_content': textContent,
      'images': images,
    };
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

  factory ItemStoreFormat.fromDBMap(Map<String, dynamic> map) {
    return ItemStoreFormat(
      title: map['title'] as String,
      subtitle: map['subtitle'] as String?,
      description: map['description'] as String?,
      modificationButtons: (map['modification_buttons'] as List<dynamic>).map((e) => ModificationButton.fromDBMap(e)).toList(),
    );
  }

  Map<String, dynamic> toDBMap() {
    return {
      'title': title,
      'subtitle': subtitle,
      'description': description,
      'modification_buttons': modificationButtons.map((e) => e.toDBMap()).toList(),
    };
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
  final List<dynamic> selectedData;

  ModificationButtonDataHost({required this.name, required this.dataType, required this.selectedData});

  factory ModificationButtonDataHost.fromModificationButton(ModificationButton button, Iterable<int> chosenIndices) {
    int dataLength = button.data.length;
    List<dynamic> chosenData = List.empty(growable: true);

    for (int index in chosenIndices) {
      if (index >= dataLength) throw IndexError(index, dataLength, "Chosen indices passed an index out of the data's range!");

      chosenData.add(button.data[index]);
    }

    return ModificationButtonDataHost(name: button.name, dataType: button.dataType, selectedData: chosenData);
  }

  @override
  String toString() {
    return 'ModificationButtonDataHost{name: $name, dataType: $dataType, selectedData: $selectedData}';
  }

  ModificationButtonDataHost copyWith({
    String? name,
    ModificationButtonDataType? dataType,
    List<Object>? selectedData,
  }) {
    return ModificationButtonDataHost(
      name: name ?? this.name,
      dataType: dataType ?? this.dataType,
      selectedData: selectedData ?? this.selectedData,
    );
  }

  factory ModificationButtonDataHost.fromMap(Map<String, dynamic> map) {
    return ModificationButtonDataHost(
      name: map['name'] as String,
      dataType: ModificationButtonDataType.values[map['data_type']],
      selectedData: map['selected_data'] as List<dynamic>,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'data_type': dataType.index,
      'selected_data': selectedData,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ModificationButtonDataHost &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          dataType == other.dataType &&
          listEquals(selectedData, other.selectedData);

  @override
  int get hashCode => name.hashCode ^ dataType.hashCode ^ selectedData.hashCode;
}

class ModificationButton {
  final String name;
  final ModificationButtonSide side;
  final List<Object> data;
  final ModificationButtonDataType dataType;
  final bool multiSelect;

  const ModificationButton({
    required this.name,
    required this.data,
    required this.dataType,
    this.multiSelect = false,
    required this.side,
  });

  @override
  String toString() {
    return 'ModificationButton{name: $name, side: $side, data: $data, dataType: $dataType, multiSelect: $multiSelect}';
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
      side: modificationButtonSide ?? this.side,
      data: data ?? this.data,
      dataType: dataType ?? this.dataType,
      multiSelect: multiSelect ?? this.multiSelect,
    );
  }

  factory ModificationButton.fromDBMap(Map<String, dynamic> map) {
    return ModificationButton(
      name: map['name'] as String,
      side: ModificationButtonSide.values[map['side']],
      data: (map['data'] as List<dynamic>).map((e) => e as Object).toList(),
      dataType: ModificationButtonDataType.values[map['data_type']],
      multiSelect: map['multi_select'] as bool,
    );
  }

  Map<String, dynamic> toDBMap() {
    return {
      'name': name,
      'side': side.index,
      'data': data,
      'data_type': dataType.index,
      'multi_select': multiSelect,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ModificationButton &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          side == other.side &&
          listEquals(data, other.data) &&
          dataType == other.dataType &&
          multiSelect == other.multiSelect;

  @override
  int get hashCode => name.hashCode ^ side.hashCode ^ data.hashCode ^ dataType.hashCode ^ multiSelect.hashCode;
}
