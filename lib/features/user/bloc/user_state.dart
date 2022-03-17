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
  final String _token;

  late List<int> id;
  late String name;
  late String email;
  late String phone;
  late UserOptions userOptions;
  late List<Address> addresses;
  late List<ItemModel> likedItems;
  late List<Order> orderHistory;

  UserLoggedInState(this._token);

  Future<String?> init() async {
    Map<String, dynamic>? mapUser = await getUserFromToken(_token);
    if (mapUser == null) return 'Token expired';

    print(mapUser);
    email = mapUser['email'];
    name = mapUser['name'];
    phone = mapUser['phone'];
    userOptions = buildUserOptionsFromUserMap(mapUser['options']);
    addresses = buildAddressesFromUserMap(mapUser['addresses']);
    likedItems = buildLikedItemsFromUserMap(mapUser['liked_items']);
    orderHistory = buildOrderHistoryFromUserMap(mapUser['order_history'] ?? []);

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
        .map((e) => Address(
              city: e["city"],
              houseNumber: e["house_number"],
              country: e["country"],
              name: e["name"],
              phone: e["phone"],
              street: e["street"],
              zipCode: e["zip_code"],
            ))
        .toList();
  }

  List<ItemModel> buildLikedItemsFromUserMap(Map<String, dynamic> likedItems) {
    List<ItemModel> items = List.empty(growable: true);

    for (var entry in likedItems.entries) {
      // TODO: Move to thread pools
      for (var itemId in entry.value) {
        ItemModel? item = getItemFromId(stringToByteUuid(entry.key), stringToByteUuid(itemId));
        if (item != null) items.add(item);
      }
    }

    return items;
  }

  List<Order> buildOrderHistoryFromUserMap(List<dynamic> ordersMap) {
    List<Order> orders = List.empty(growable: true);

    for (var orderMap in ordersMap) {
      List<OrderItem> items = (orderMap["items"] as List<dynamic>)
          .map(
            (e) => OrderItem(
              businessId: stringToByteUuid(e["business_id"]),
              itemId: stringToByteUuid(e["item_id"]),
              previewImage: e["preview_image"],
              title: e["title"],
              selectedModifiers: (orderMap["selected_modification_button_data"] as List<dynamic>)
                  .map((e) => ModificationButtonDataHost(name: e["name"], dataType: e["data_type"], dataChosen: e["selected_data"]))
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
}
