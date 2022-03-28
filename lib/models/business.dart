import 'package:flutter/foundation.dart';
import 'package:latlong2/latlong.dart';
import 'package:objectid/objectid/objectid.dart';

class Business {
  final String name;
  final LatLng location;
  final List<ObjectId> items;
  final Map<String, List<ObjectId>> categories;
  final ContactInformation contact;
  final int nationalBusinessId;
  final String? ownerId; // TODO: If null ask to resubmit id.

  Business({
    required this.name,
    required this.location,
    required this.items,
    required this.categories,
    required this.contact,
    required this.nationalBusinessId,
    required this.ownerId,
  });

  Business copyWith({
    String? name,
    LatLng? location,
    List<ObjectId>? items,
    Map<String, List<ObjectId>>? categories,
    ContactInformation? contact,
    int? nationalBusinessId,
    String? ownerId,
  }) {
    if ((name == null || identical(name, this.name)) &&
        (location == null || identical(location, this.location)) &&
        (items == null || identical(items, this.items)) &&
        (categories == null || identical(categories, this.categories)) &&
        (contact == null || identical(contact, this.contact)) &&
        (nationalBusinessId == null || identical(nationalBusinessId, this.nationalBusinessId)) &&
        (ownerId == null || identical(ownerId, this.ownerId))) {
      return this;
    }

    return Business(
      name: name ?? this.name,
      location: location ?? this.location,
      items: items ?? this.items,
      categories: categories ?? this.categories,
      contact: contact ?? this.contact,
      nationalBusinessId: nationalBusinessId ?? this.nationalBusinessId,
      ownerId: ownerId ?? this.ownerId,
    );
  }

  factory Business.fromMap(Map<String, dynamic> map) {
    return Business(
      name: map['name'] as String,
      location: LatLng(map['location'][0], map['location'][1]),
      items: (map['items'] as List<dynamic>).map((e) => ObjectId.fromHexString(e)).toList(),
      categories: (map['categories'] as List<dynamic>)
          .asMap()
          .map((key, value) => MapEntry(value['name'], (value['item_ids'] as List<dynamic>).map((id) => ObjectId.fromHexString(id)).toList())),
      contact: ContactInformation.fromMap(map['contact']),
      nationalBusinessId: map['national_business_id'] as int,
      ownerId: map['owner_id_card'] as String?,
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
    } as Map<String, dynamic>;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Business &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          location == other.location &&
          listEquals(items, other.items) &&
          mapEquals(categories, other.categories) &&
          contact == other.contact &&
          nationalBusinessId == other.nationalBusinessId &&
          ownerId == other.ownerId;

  @override
  int get hashCode =>
      name.hashCode ^ location.hashCode ^ items.hashCode ^ categories.hashCode ^ contact.hashCode ^ nationalBusinessId.hashCode ^ ownerId.hashCode;

  @override
  String toString() {
    return 'Business{name: $name, location: $location, items: $items, categories: $categories, contact: $contact, nationalBusinessId: $nationalBusinessId, ownerId: $ownerId}';
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
