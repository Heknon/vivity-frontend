import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:latlong2/latlong.dart';
import 'package:objectid/objectid/objectid.dart';
import 'package:vivity/features/business/models/business_metrics.dart';
import 'package:vivity/features/business/models/contact_information.dart';

class Business {
  final String? ownerToken = '';
  final String name;
  final ObjectId businessId;
  final LatLng location;
  final List<ObjectId> items;
  final Map<String, List<ObjectId>> categories;
  final ContactInformation contact;
  final String nationalBusinessId;
  final BusinessMetrics metrics;
  final List<ObjectId> orders;
  final Uint8List? ownerId; // TODO: If null ask to resubmit id.
  final bool approved;
  final String adminNote;

  Business({
    required this.businessId,
    required this.name,
    required this.location,
    required this.items,
    required this.categories,
    required this.contact,
    required this.nationalBusinessId,
    required this.ownerId,
    required this.metrics,
    required this.orders,
    required this.approved,
    required this.adminNote,
  });

  Business copyWith({
    ObjectId? businessId,
    String? name,
    LatLng? location,
    List<ObjectId>? items,
    Map<String, List<ObjectId>>? categories,
    ContactInformation? contact,
    String? nationalBusinessId,
    Uint8List? ownerId,
    BusinessMetrics? metrics,
    List<ObjectId>? orders,
    bool? approved,
    String? adminNote,
  }) {
    return Business(
      businessId: businessId ?? this.businessId,
      name: name ?? this.name,
      location: location ?? this.location,
      items: items ?? this.items.map((e) => ObjectId.fromBytes(e.bytes)).toList(),
      categories: categories ?? this.categories.map((key, value) => MapEntry(key, value.map((e) => ObjectId.fromBytes(e.bytes)).toList())),
      contact: contact ?? this.contact.copyWith(),
      nationalBusinessId: nationalBusinessId ?? this.nationalBusinessId,
      ownerId: ownerId ?? this.ownerId,
      metrics: metrics ?? this.metrics.copyWith(),
      orders: orders ?? this.orders.map((e) => ObjectId.fromBytes(e.bytes)).toList(),
      approved: approved ?? this.approved,
      adminNote: adminNote ?? this.adminNote,
    );
  }

  factory Business.fromMap(Map<String, dynamic> map) {
    return Business(
      businessId: ObjectId.fromHexString(map['_id']),
      name: map['name'] as String,
      location: LatLng((map['location'][0] as num).toDouble(), (map['location'][1] as num).toDouble()),
      items: (map['items'] as List<dynamic>).map((e) => ObjectId.fromHexString(e)).toList(),
      categories: (map['categories'] as List<dynamic>)
          .asMap()
          .map((key, value) => MapEntry(value['name'], (value['item_ids'] as List<dynamic>).map((id) => ObjectId.fromHexString(id)).toList())),
      contact: ContactInformation.fromMap(map['contact']),
      nationalBusinessId: map['national_business_id'] as String,
      ownerId: map.containsKey('owner_id_card') && (map['owner_id_card'] as String).length > 100 ? base64Decode(map['owner_id_card']) : null,
      metrics: BusinessMetrics.fromMap(map["metrics"]),
      orders: (map["orders"] as List<dynamic>).map((e) => ObjectId.fromHexString(e)).toList(),
      approved: map['approved'],
      adminNote: map['admin_note'],
    );
  }

  Map<String, dynamic> toMap() {
    List<dynamic> categoriesMapped = List.empty();
    categories.forEach((key, value) {
      categoriesMapped.add({
        'name': key,
        'item_ids': value.map((e) => e.hexString),
      });
    });

    // ignore: unnecessary_cast
    return {
      'name': name,
      'location': [location.latitude, location.longitude],
      'items': items.map((e) => e.hexString).toList(),
      'categories': categoriesMapped,
      'contact': contact.toMap(),
      'national_business_id': nationalBusinessId,
      'owner_id_card': ownerId != null ? base64Encode(ownerId!) : null,
      'metrics': metrics.toMap(),
      'orders': orders.map((e) => e.hexString).toList(),
      'approved': approved,
      'admin_note': adminNote,
      '_id': businessId.hexString,
    } as Map<String, dynamic>;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Business &&
          runtimeType == other.runtimeType &&
          businessId == other.businessId &&
          name == other.name &&
          location == other.location &&
          listEquals(items, other.items) &&
          mapEquals(categories, other.categories) &&
          contact == other.contact &&
          nationalBusinessId == other.nationalBusinessId &&
          ownerId == other.ownerId &&
          metrics == other.metrics &&
          listEquals(orders, other.orders) &&
          approved == other.approved &&
          adminNote == other.adminNote;

  @override
  int get hashCode =>
      name.hashCode ^
      location.hashCode ^
      items.hashCode ^
      categories.hashCode ^
      contact.hashCode ^
      nationalBusinessId.hashCode ^
      ownerId.hashCode ^
      metrics.hashCode ^
      orders.hashCode ^
      approved.hashCode ^
      adminNote.hashCode ^
      businessId.hashCode;

  @override
  String toString() {
    return 'Business{name: $name, location: $location, items: $items, categories: $categories, contact: $contact, nationalBusinessId: $nationalBusinessId, ownerId: $ownerId, metrics: $metrics, orders: $orders}';
  }
}
