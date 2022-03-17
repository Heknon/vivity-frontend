class Address {
  final String name;
  final String country;
  final String city;
  final String street;
  final String houseNumber;
  final String zipCode;
  final String phone;

  Address({
    required this.name,
    required this.country,
    required this.city,
    required this.street,
    required this.houseNumber,
    required this.zipCode,
    required this.phone,
  });

  factory Address.fromMap(Map<String, dynamic> map) {
    return Address(
      name: map['name'] as String,
      country: map['country'] as String,
      city: map['city'] as String,
      street: map['street'] as String,
      houseNumber: map['houseNumber'] as String,
      zipCode: map['zipCode'] as String,
      phone: map['phone'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    // ignore: unnecessary_cast
    return {
      'name': name,
      'country': country,
      'city': city,
      'street': street,
      'houseNumber': houseNumber,
      'zipCode': zipCode,
      'phone': phone,
    } as Map<String, dynamic>;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Address &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          country == other.country &&
          city == other.city &&
          street == other.street &&
          houseNumber == other.houseNumber &&
          zipCode == other.zipCode &&
          phone == other.phone;

  @override
  int get hashCode => name.hashCode ^ country.hashCode ^ city.hashCode ^ street.hashCode ^ houseNumber.hashCode ^ zipCode.hashCode ^ phone.hashCode;

  @override
  String toString() {
    return 'Address{name: $name, country: $country, city: $city, street: $street, houseNumber: $houseNumber, zipCode: $zipCode, phone: $phone}';
  }
}
