import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:objectid/objectid/objectid.dart';
import 'package:uuid/uuid.dart';
import 'package:vivity/constants/app_constants.dart';
import 'package:vivity/features/item/models/item_metrics.dart';
import 'package:vivity/features/item/models/item_store_format.dart';
import 'package:vivity/features/item/models/modification_button.dart';
import 'package:vivity/features/item/models/review.dart';
import 'package:vivity/services/item_service.dart';
import 'package:vivity/services/storage_service.dart';
import 'package:latlong2/latlong.dart';

class ItemModel {
  final ObjectId id;
  final ObjectId businessId;
  final String businessName;
  final ItemStoreFormat itemStoreFormat;
  final ItemMetrics metrics;
  final List<Review> reviews;
  final List<Uint8List?>? images;
  final List<String> tags;
  final LatLng location;
  final double price;
  final int previewImageIndex;
  final String brand;
  final String category;
  final int stock;

//<editor-fold desc="Data Methods">

  const ItemModel({
    required this.id,
    required this.businessId,
    required this.businessName,
    required this.itemStoreFormat,
    required this.metrics,
    required this.reviews,
    this.images,
    required this.tags,
    required this.location,
    required this.price,
    required this.previewImageIndex,
    required this.brand,
    required this.category,
    required this.stock,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ItemModel &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          businessId == other.businessId &&
          businessName == other.businessName &&
          itemStoreFormat == other.itemStoreFormat &&
          metrics == other.metrics &&
          reviews == other.reviews &&
          images == other.images &&
          tags == other.tags &&
          location == other.location &&
          price == other.price &&
          previewImageIndex == other.previewImageIndex &&
          brand == other.brand &&
          category == other.category &&
          stock == other.stock);

  @override
  int get hashCode =>
      id.hashCode ^
      businessId.hashCode ^
      businessName.hashCode ^
      itemStoreFormat.hashCode ^
      metrics.hashCode ^
      reviews.hashCode ^
      images.hashCode ^
      tags.hashCode ^
      location.hashCode ^
      price.hashCode ^
      previewImageIndex.hashCode ^
      brand.hashCode ^
      category.hashCode ^
      stock.hashCode;

  @override
  String toString() {
    return 'ItemModel{' +
        ' id: $id,' +
        ' businessId: $businessId,' +
        ' businessName: $businessName,' +
        ' itemStoreFormat: $itemStoreFormat,' +
        ' metrics: $metrics,' +
        ' reviews: $reviews,' +
        ' images: $images,' +
        ' tags: $tags,' +
        ' location: $location,' +
        ' price: $price,' +
        ' previewImageIndex: $previewImageIndex,' +
        ' brand: $brand,' +
        ' category: $category,' +
        ' stock: $stock,' +
        '}';
  }

  ItemModel copyWith({
    ObjectId? id,
    ObjectId? businessId,
    String? businessName,
    ItemStoreFormat? itemStoreFormat,
    ItemMetrics? metrics,
    List<Review>? reviews,
    List<Uint8List?>? images,
    List<String>? tags,
    LatLng? location,
    double? price,
    int? previewImageIndex,
    String? brand,
    String? category,
    int? stock,
  }) {
    return ItemModel(
      id: id ?? this.id,
      businessId: businessId ?? this.businessId,
      businessName: businessName ?? this.businessName,
      itemStoreFormat: itemStoreFormat ?? this.itemStoreFormat,
      metrics: metrics ?? this.metrics,
      reviews: reviews ?? this.reviews,
      images: images ?? this.images,
      tags: tags ?? this.tags,
      location: location ?? this.location,
      price: price ?? this.price,
      previewImageIndex: previewImageIndex ?? this.previewImageIndex,
      brand: brand ?? this.brand,
      category: category ?? this.category,
      stock: stock ?? this.stock,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': this.id,
      'businessId': this.businessId,
      'businessName': this.businessName,
      'itemStoreFormat': this.itemStoreFormat,
      'metrics': this.metrics,
      'reviews': this.reviews,
      'images': this.images,
      'tags': this.tags,
      'location': this.location,
      'price': this.price,
      'previewImageIndex': this.previewImageIndex,
      'brand': this.brand,
      'category': this.category,
      'stock': this.stock,
    };
  }

  factory ItemModel.fromMap(Map<String, dynamic> map) {
    List<Uint8List> images = List.empty(growable: true);
    for (String? probableImage in map['images'] as List<dynamic>? ?? []) {
      if (probableImage != null) images.add(base64Decode(probableImage));
    }

    return ItemModel(
      id: ObjectId.fromHexString(map['_id']),
      businessId: ObjectId.fromHexString(map['business_id']),
      businessName: map['business_name'] as String,
      itemStoreFormat: ItemStoreFormat.fromMap(map['item_store_format']),
      metrics: ItemMetrics.fromMap(map['metrics']),
      reviews: (map['reviews'] as List<dynamic>).map((e) => Review.fromMap(e)).toList(),
      images: images.isEmpty ? null : images,
      tags: (map['tags'] as List<dynamic>).map((e) => e as String).toList(),
      location: LatLng(
        (map['location'][0] as num).toDouble(),
        (map['location'][0] as num).toDouble(),
      ),
      price: (map['price'] as num).toDouble(),
      previewImageIndex: (map['preview_image'] as num).toInt(),
      brand: map['brand'] as String,
      category: map['category'] as String,
      stock: (map['stock'] as num).toInt(),
    );
  }

//</editor-fold>
}
