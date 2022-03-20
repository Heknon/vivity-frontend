part of 'user_bloc.dart';

@immutable
abstract class UserState {
  const UserState();
}

class UserLoggedOutState extends UserState {}

class UserLoadingState extends UserState {}

class UserLoginFailedState extends UserLoggedOutState {
  final String reason;

  UserLoginFailedState(this.reason);

  @override
  String toString() {
    return 'UserLoginFailedState{reason: $reason}';
  }
}

class UserLoggedInState extends UserState {
  final String token;

  late ObjectId id;
  late String name;
  late String email;
  late String phone;
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
  });

  Future<String?> init() async {
    Map<String, dynamic>? mapUser = await getUserFromToken(token);
    if (mapUser == null) return 'Token expired';

    id = ObjectId.fromHexString(mapUser['_id']);
    email = mapUser['email'];
    name = mapUser['name'];
    phone = mapUser['phone'];
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
    return addresses
        .map((e) => Address.fromMap(e))
        .toList();
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
