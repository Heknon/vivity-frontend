part of 'user_bloc.dart';

@immutable
abstract class UserState {
  const UserState();
}

class UserLoggedOutState extends UserState {
  @override
  bool operator ==(Object other) => identical(this, other) || other is UserLoggedOutState && runtimeType == other.runtimeType;

  @override
  int get hashCode => 0;
}

class UserLoadingState extends UserState {}

class UserLoginFailedState extends UserLoggedOutState {
  final String reason;

  UserLoginFailedState(this.reason);

  @override
  String toString() {
    return 'UserLoginFailedState{reason: $reason}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || super == other && other is UserLoginFailedState && runtimeType == other.runtimeType && reason == other.reason;

  @override
  int get hashCode => super.hashCode ^ reason.hashCode;
}

class UserLoggedInState extends UserState {
  final String token;

  late ObjectId id;
  late ObjectId? businessId;
  late bool isSystemAdmin;
  late String name;
  late String email;
  late String phone;
  late File? profilePicture;
  late UserOptions userOptions;
  late List<Address> addresses;
  late List<ItemModel> likedItems;
  late List<CartItemModel> cart;
  late List<Order> orderHistory;

  UserLoggedInState(this.token);

  UserLoggedInState.copyConstructor({
    required this.token,
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.userOptions,
    required this.addresses,
    required this.likedItems,
    required this.cart,
    required this.orderHistory,
    this.profilePicture,
    this.businessId,
    this.isSystemAdmin = false,
  });

  Future<String?> init() async {
    Map<String, dynamic>? mapUser = await getUserFromToken(token);
    if (mapUser == null) return 'Token expired';

    id = ObjectId.fromHexString(mapUser['_id']);
    businessId = mapUser.containsKey('business_id') ? ObjectId.fromHexString(mapUser['business_id']) : null;
    isSystemAdmin = mapUser['is_system_admin'] ?? false;
    email = mapUser['email'];
    name = mapUser['name'];
    phone = mapUser['phone'];
    userOptions = buildUserOptionsFromUserMap(mapUser['options']);
    addresses = buildAddressesFromUserMap(token, mapUser['shipping_addresses']);
    likedItems = await buildLikedItemsFromUserMap(token, mapUser['liked_items']);
    orderHistory = await buildOrderHistoryFromUserMap(token, mapUser['order_history'] ?? []);
    cart = await buildCartFromUserMap(token, mapUser['cart'] ?? []);
    profilePicture = await getProfilePicture(token);

    return null;
  }

  UserOptions buildUserOptionsFromUserMap(Map<String, dynamic> map) {
    return UserOptions(
      businessSearchRadius: (map["business_search_radius"] as num?)?.toDouble(),
      distanceUnit: map["distance_unit"],
      currencyType: map["currency_type"],
      jeansSize: map["jeans_size"],
      shirtSize: map["shirt_size"],
      sweatsSize: map["sweats_size"],
    );
  }

  static List<Address> buildAddressesFromUserMap(String token, List<dynamic> addresses) {
    return addresses.map((e) => Address.fromMap(e)).toList();
  }

  static Future<List<ItemModel>> buildLikedItemsFromUserMap(String token, List<dynamic> likedItems) async {
    if (likedItems.isEmpty) return List.empty(growable: true);

    List<ObjectId> itemIds = likedItems.map((e) => ObjectId.fromHexString(e as String)).toList();

    return await getItemsFromIds(token, itemIds);
  }

  static Future<List<Order>> buildOrderHistoryFromUserMap(String token, List<dynamic> ordersMap) async {
    return (await getOrdersFromIds(token, ordersMap.map((e) => e as String).toList())) ?? [];
  }

  static Future<List<CartItemModel>> buildCartFromUserMap(String token, List<dynamic> cartMap) async {
    if (cartMap.isEmpty) {
      return List<CartItemModel>.empty(growable: true);
    }
    return await getCartFromDBCart(token, cartMap);
  }

  Future<BusinessUserLoggedInState?> createBusiness(UserRegisterBusinessEvent e) async {
    String route = businessRoute +
        "?name=${e.businessName}" +
        "&email=${e.businessEmail}" +
        "&phone=${e.businessPhone}" +
        "&latitude=${e.location.latitude}" +
        "&longitude=${e.location.longitude}" +
        "&business_national_number=${e.businessNationalId}";
    Response res = await sendPostRequestUploadFile(subRoute: route, file: e.ownerId, token: token, context: e.context);

    if (res.statusCode != 200) return null;

    return BusinessUserLoggedInState.fromCreationObject(res.data['token'], this, res.data['business']);
  }

  UserLoggedInState copyWith({
    String? token,
    ObjectId? id,
    String? name,
    String? email,
    String? phone,
    UserOptions? userOptions,
    List<Address>? addresses,
    List<ItemModel>? likedItems,
    List<CartItemModel>? cart,
    List<Order>? orderHistory,
    ObjectId? businessId,
    bool? isSystemAdmin,
    File? profilePicture,
  }) {
    bool setPfpNull = profilePicture?.path.isEmpty ?? false;
    return UserLoggedInState.copyConstructor(
      token: token ?? this.token,
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      userOptions: userOptions ?? this.userOptions,
      addresses: addresses ?? this.addresses,
      likedItems: likedItems ?? this.likedItems,
      cart: cart ?? this.cart,
      orderHistory: orderHistory ?? this.orderHistory,
      businessId: businessId ?? this.businessId,
      isSystemAdmin: isSystemAdmin ?? this.isSystemAdmin,
      profilePicture: setPfpNull ? null : profilePicture ?? this.profilePicture,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserLoggedInState &&
          runtimeType == other.runtimeType &&
          token == other.token &&
          id == other.id &&
          name == other.name &&
          email == other.email &&
          phone == other.phone &&
          userOptions == other.userOptions &&
          isSystemAdmin == other.isSystemAdmin &&
          businessId == other.businessId &&
          profilePicture == other.profilePicture &&
          listEquals(addresses, other.addresses) &&
          listEquals(likedItems, other.likedItems) &&
          listEquals(cart, other.cart) &&
          listEquals(orderHistory, other.orderHistory);

  @override
  int get hashCode =>
      token.hashCode ^
      id.hashCode ^
      name.hashCode ^
      email.hashCode ^
      phone.hashCode ^
      userOptions.hashCode ^
      addresses.hashCode ^
      likedItems.hashCode ^
      cart.hashCode ^
      orderHistory.hashCode ^
      isSystemAdmin.hashCode ^
      businessId.hashCode ^
      profilePicture.hashCode;

  @override
  String toString() {
    return 'UserLoggedInState{token: $token, id: $id, businessId: $businessId, isSystemAdmin: $isSystemAdmin, name: $name, email: $email, phone: $phone, profilePicture: $profilePicture, userOptions: $userOptions, addresses: $addresses, likedItems: $likedItems, cart: $cart, orderHistory: $orderHistory}';
  }
}

class BusinessUserLoggedInState extends UserLoggedInState {
  late final Business business;

  BusinessUserLoggedInState(String token) : super(token);

  @override
  Future<String?> init() async {
    await super.init();
    Response businessData = await sendGetRequest(subRoute: businessRoute, token: token);
    business = Business.fromMap(token, businessData.data);
  }

  BusinessUserLoggedInState.copyConstructor({
    required this.business,
    token,
    id,
    name,
    email,
    phone,
    userOptions,
    addresses,
    likedItems,
    cart,
    orderHistory,
    profilePicture,
    businessId,
    isSystemAdmin,
  }) : super.copyConstructor(
          token: token,
          id: id,
          name: name,
          email: email,
          phone: phone,
          userOptions: userOptions,
          addresses: addresses,
          likedItems: likedItems,
          cart: cart,
          orderHistory: orderHistory,
          businessId: businessId,
          profilePicture: profilePicture,
          isSystemAdmin: isSystemAdmin,
        );

  BusinessUserLoggedInState.fromCreationObject(String token, UserLoggedInState state, dynamic businessData)
      : super.copyConstructor(
          token: token,
          addresses: state.addresses,
          phone: state.phone,
          name: state.name,
          id: state.id,
          cart: state.cart,
          email: state.email,
          likedItems: state.likedItems,
          orderHistory: state.orderHistory,
          userOptions: state.userOptions,
          profilePicture: state.profilePicture,
          isSystemAdmin: state.isSystemAdmin,
          businessId: ObjectId.fromHexString(businessData['_id']),
        ) {
    business = Business.fromMap(token, businessData);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      super == other && other is BusinessUserLoggedInState && runtimeType == other.runtimeType && business == other.business;

  @override
  int get hashCode => super.hashCode ^ business.hashCode;

  @override
  BusinessUserLoggedInState copyWith({
    Business? business,
    String? token,
    ObjectId? id,
    String? name,
    String? email,
    String? phone,
    UserOptions? userOptions,
    List<Address>? addresses,
    List<ItemModel>? likedItems,
    List<CartItemModel>? cart,
    List<Order>? orderHistory,
    ObjectId? businessId,
    bool? isSystemAdmin,
    File? profilePicture,
  }) {
    bool setPfpNull = profilePicture?.path.isEmpty ?? false;
    return BusinessUserLoggedInState.copyConstructor(
      token: token ?? this.token,
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      userOptions: userOptions ?? this.userOptions,
      addresses: addresses ?? this.addresses,
      likedItems: likedItems ?? this.likedItems,
      cart: cart ?? this.cart,
      orderHistory: orderHistory ?? this.orderHistory,
      businessId: businessId ?? this.businessId,
      isSystemAdmin: isSystemAdmin ?? this.isSystemAdmin,
      profilePicture: setPfpNull ? null : profilePicture ?? this.profilePicture,
      business: business ?? this.business,
    );
  }

  @override
  String toString() {
    return 'BusinessUserLoggedInState{business: $business}';
  }
}
