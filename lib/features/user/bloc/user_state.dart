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
  late String? profilePicture;
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
    profilePicture = mapUser['profile_picture'];
    userOptions = buildUserOptionsFromUserMap(mapUser['options']);
    addresses = buildAddressesFromUserMap(mapUser['addresses']);
    likedItems = await buildLikedItemsFromUserMap(mapUser['liked_items']);
    orderHistory = buildOrderHistoryFromUserMap(mapUser['order_history'] ?? []);
    cart = await buildCartFromUserMap(mapUser['cart'] ?? []);

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

  List<Address> buildAddressesFromUserMap(List<dynamic> addresses) {
    return addresses.map((e) => Address.fromMap(e)).toList();
  }

  Future<List<ItemModel>> buildLikedItemsFromUserMap(List<dynamic> likedItems) async {
    if (likedItems.isEmpty) return List.empty(growable: true);

    List<String> itemIds = likedItems.map((e) => e as String).toList();

    return await getItemsFromStringIds(token, itemIds);
  }

  List<Order> buildOrderHistoryFromUserMap(List<dynamic> ordersMap) {
    List<Order> orders = List.empty(growable: true);

    for (var orderMap in ordersMap) {
      List<OrderItem> items = (orderMap["items"] as List<dynamic>)
          .map(
            (e) => OrderItem(
              businessId: ObjectId.fromHexString(e["business_id"]),
              itemId: ObjectId.fromHexString(e["item_id"]),
              previewImage: e["preview_image"],
              title: e["title"],
              selectedModifiers: (orderMap["selected_modification_button_data"] as List<dynamic>)
                  .map((e) => ModificationButtonDataHost(name: e["name"], dataType: e["data_type"], selectedData: e["selected_data"]))
                  .toList(),
              subtitle: e["subtitle"],
              description: e["description"],
            ),
          )
          .toList();

      Order order = Order(orderDate: DateTime.fromMillisecondsSinceEpoch(orderMap["order_date"] as int), items: items);
      orders.add(order);
    }

    return orders;
  }

  Future<List<CartItemModel>> buildCartFromUserMap(List<dynamic> cartMap) async {
    if (cartMap.isEmpty) {
      return List<CartItemModel>.empty(growable: true);
    }
    return await getCartFromDBCart(token, cartMap);
  }

  Future<BusinessUserLoggedInState> createBusiness(UserRegisterBusinessEvent e) async {
    Response res = await sendPostRequest(
        subRoute:
            "$businessRoute?name=${e.businessName}&email=${e.businessEmail}&phone=${e.businessPhone}&latitude=${e.location.latitude}&longitude=${e.location.longitude}&business_national_number=${e.businessNationalId}",
        token: token,
        contentType: 'image/png',
        data: await e.ownerId.readAsBytes());

    dynamic parsed = jsonDecode(res.body);
    return BusinessUserLoggedInState.fromCreationObject(parsed['token'], this, parsed['business']);
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
  }) {
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
      orderHistory.hashCode;
}

class BusinessUserLoggedInState extends UserLoggedInState {
  late final Business business;

  BusinessUserLoggedInState(String token) : super(token);

  @override
  Future<String?> init() async {
    await super.init();
    dynamic businessData = await sendGetRequest(subRoute: businessRoute, token: token);
    business = Business.fromMap(businessData);
  }

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
          isSystemAdmin: state.isSystemAdmin,
          businessId: state.businessId,
        ) {
    business = Business.fromMap(businessData);
  }
}
