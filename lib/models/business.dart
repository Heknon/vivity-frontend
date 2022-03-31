import 'package:flutter/foundation.dart';
import 'package:latlong2/latlong.dart';
import 'package:objectid/objectid/objectid.dart';
import 'package:vivity/features/item/models/item_model.dart';
import 'package:vivity/models/order.dart';
import 'package:vivity/services/business_service.dart';
import 'package:vivity/services/item_service.dart';

class Business {
  late Future<List<ItemModel>> _cachedItems;
  late Future<List<Order>> _cachedOrders;
  Future<List<ItemModel>>? _cachedOrderItems;
  Map<ObjectId, ItemModel>? _cachedItemIdMap;

  final String? ownerToken;
  final String name;
  final ObjectId businessId;
  final LatLng location;
  final List<ObjectId> items;
  final Map<String, List<ObjectId>> categories;
  final ContactInformation contact;
  final int nationalBusinessId;
  final BusinessMetrics metrics;
  final List<ObjectId> orders;
  final String? ownerId; // TODO: If null ask to resubmit id.
  final bool approved;
  final String adminNote;

  Business(
    this.ownerToken, {
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
  }) {
    if (ownerToken != null) {
      _cachedItems = getItemsFromIds(ownerToken!, items);
      _cachedOrders = getBusinessOrders(ownerToken!);
    }
  }

  Future<List<Order>> getOrders({bool updateCache = false}) async {
    if (ownerToken == null) throw Exception("You do not have access to business data. No owner token.");

    if (updateCache) {
      _cachedOrders = getBusinessOrders(ownerToken!);
      _cachedOrderItems = getItemsFromOrders(ownerToken!, await _cachedOrders);
    }

    return await _cachedOrders;
  }

  Future<List<ItemModel>> getCachedOrderItems() async {
    if (ownerToken == null) throw Exception("You do not have access to business data. No owner token.");

    _cachedOrderItems ??= getItemsFromOrders(ownerToken!, await _cachedOrders);

    return await _cachedOrderItems!;
  }

  Future<Map<ObjectId, ItemModel>> getIdItemMap({bool updateCache = false}) async {
    if (ownerToken == null) throw Exception("You do not have access to business data. No owner token.");
    if (updateCache) {
      _cachedItems = getItemsFromIds(ownerToken!, items);
      _cachedItemIdMap == null;
    }

    if (_cachedItemIdMap == null) {
      _cachedItemIdMap = {};

      for (var item in await _cachedItems) {
        _cachedItemIdMap![item.id] = item;
      }
    }

    return _cachedItemIdMap!;
  }

  void updateItem(ItemModel item) async {
    List<ItemModel> cached = await _cachedItems;
    cached.removeWhere((element) => element.id == item.id);
    cached.add(item);

    if (_cachedItemIdMap != null) {
      _cachedItemIdMap![item.id] = item;
    }

    items.removeWhere((element) => element == item.id);
    items.add(item.id);
  }

  void updateOrderStatus(Order order) async {
    List<Order> cached = await _cachedOrders;
    cached.removeWhere((element) => element.orderId == order.orderId);
    cached.add(order);
  }

  Business copyWith({
    String? ownerToken,
    ObjectId? businessId,
    String? name,
    LatLng? location,
    List<ObjectId>? items,
    Map<String, List<ObjectId>>? categories,
    ContactInformation? contact,
    int? nationalBusinessId,
    String? ownerId,
    BusinessMetrics? metrics,
    List<ObjectId>? orders,
    bool? approved,
    String? adminNote,
  }) {
    if ((name == null || identical(name, this.name)) &&
        (location == null || identical(location, this.location)) &&
        (items == null || identical(items, this.items)) &&
        (categories == null || identical(categories, this.categories)) &&
        (contact == null || identical(contact, this.contact)) &&
        (nationalBusinessId == null || identical(nationalBusinessId, this.nationalBusinessId)) &&
        (ownerId == null || identical(ownerId, this.ownerId)) &&
        (ownerId == null || identical(ownerId, this.ownerId))) {
      return this;
    }

    return Business(
      ownerToken ?? this.ownerToken,
      businessId: businessId ?? this.businessId,
      name: name ?? this.name,
      location: location ?? this.location,
      items: items ?? this.items,
      categories: categories ?? this.categories,
      contact: contact ?? this.contact,
      nationalBusinessId: nationalBusinessId ?? this.nationalBusinessId,
      ownerId: ownerId ?? this.ownerId,
      metrics: metrics ?? this.metrics,
      orders: orders ?? this.orders,
      approved: approved ?? this.approved,
      adminNote: adminNote ?? this.adminNote,
    );
  }

  factory Business.fromMap(String? token, Map<String, dynamic> map) {
    return Business(
      token,
      businessId: ObjectId.fromHexString(map['_id']),
      name: map['name'] as String,
      location: LatLng((map['location'][0] as num).toDouble(), (map['location'][1] as num).toDouble()),
      items: (map['items'] as List<dynamic>).map((e) => ObjectId.fromHexString(e)).toList(),
      categories: (map['categories'] as List<dynamic>)
          .asMap()
          .map((key, value) => MapEntry(value['name'], (value['item_ids'] as List<dynamic>).map((id) => ObjectId.fromHexString(id)).toList())),
      contact: ContactInformation.fromMap(map['contact']),
      nationalBusinessId: (map['national_business_id'] as num).toInt(),
      ownerId: map['owner_id_card'] as String?,
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
      'owner_id_card': ownerId,
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
          mapEquals(_cachedItemIdMap, other._cachedItemIdMap) &&
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
      _cachedItems.hashCode ^
      _cachedItemIdMap.hashCode ^
      orders.hashCode ^
      approved.hashCode ^
      adminNote.hashCode ^
      businessId.hashCode;

  @override
  String toString() {
    return 'Business{name: $name, location: $location, items: $items, categories: $categories, contact: $contact, nationalBusinessId: $nationalBusinessId, ownerId: $ownerId, metrics: $metrics, orders: $orders}';
  }
}

class ContactInformation {
  final String phone;
  final String email;
  final String? instagram;
  final String? twitter;
  final String? facebook;

  ContactInformation({
    required this.phone,
    required this.email,
    this.instagram,
    this.twitter,
    this.facebook,
  });

  factory ContactInformation.fromMap(Map<String, dynamic> map) {
    return ContactInformation(
      phone: map['phone'] as String,
      email: map['email'] as String,
      instagram: map['instagram'] as String?,
      twitter: map['twitter'] as String?,
      facebook: map['facebook'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    // ignore: unnecessary_cast
    return {
      'phone': phone,
      'email': email,
      'instagram': instagram,
      'twitter': twitter,
      'facebook': facebook,
    } as Map<String, dynamic>;
  }

  ContactInformation copyWith({
    String? phone,
    String? email,
    String? instagram,
    String? twitter,
    String? facebook,
  }) {
    if ((phone == null || identical(phone, this.phone)) &&
        (email == null || identical(email, this.email)) &&
        (instagram == null || identical(instagram, this.instagram)) &&
        (twitter == null || identical(twitter, this.twitter)) &&
        (facebook == null || identical(facebook, this.facebook))) {
      return this;
    }

    return ContactInformation(
      phone: phone ?? this.phone,
      email: email ?? this.email,
      instagram: instagram ?? this.instagram,
      twitter: twitter ?? this.twitter,
      facebook: facebook ?? this.facebook,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ContactInformation &&
          runtimeType == other.runtimeType &&
          phone == other.phone &&
          email == other.email &&
          instagram == other.instagram &&
          twitter == other.twitter &&
          facebook == other.facebook;

  @override
  int get hashCode => phone.hashCode ^ email.hashCode ^ instagram.hashCode ^ twitter.hashCode ^ facebook.hashCode;

  @override
  String toString() {
    return 'ContactInformation{phone: $phone, email: $email, instagram: $instagram, twitter: $twitter, facebook: $facebook}';
  }
}

class BusinessMetrics {
  final int views;

  BusinessMetrics({
    required this.views,
  });

  factory BusinessMetrics.fromMap(Map<String, dynamic> map) {
    return BusinessMetrics(
      views: (map['views'] as num).toInt(),
    );
  }

  Map<String, dynamic> toMap() {
    // ignore: unnecessary_cast
    return {
      'views': views,
    } as Map<String, dynamic>;
  }

  BusinessMetrics copyWith({
    int? views,
  }) {
    return BusinessMetrics(
      views: views ?? this.views,
    );
  }

  @override
  String toString() {
    return 'BusinessMetrics{views: $views}';
  }

  @override
  bool operator ==(Object other) => identical(this, other) || other is BusinessMetrics && runtimeType == other.runtimeType && views == other.views;

  @override
  int get hashCode => views.hashCode;
}
