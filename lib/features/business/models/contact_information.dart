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