part of 'user_bloc.dart';

@immutable
abstract class UserState {
  const UserState();
}

class UserLoggedOutState extends UserState {}

class UserLoginFailedState extends UserLoggedOutState {
  final String reason;

  UserLoginFailedState(this.reason);
}

class UserLoggingInState extends UserLoggedOutState {}

class UserLoggedInState extends UserState {
  final String _token;

  late List<int> id;
  late String name;
  late String email;
  late String phone;
  late UserOptions userOptions;
  late List<Address> addresses;
  late List<ItemModel> likedItems;

  UserLoggedInState(this._token);

  Future<String?> initUserState() async {
    Map<String, dynamic>? mapUser = getUserFromToken(_token);
    if (mapUser == null) return 'Token expired';

    name = mapUser['name'];
    email = mapUser['email'];
    phone = mapUser['phone'];
    userOptions = buildUserOptionsFromUserMap(mapUser['userOptions']);
    addresses = buildAddressesFromUserMap(mapUser['addresses']);
    likedItems = buildLikedItemsFromUserMap(mapUser['likedItems']);
    return null;
  }

  UserOptions buildUserOptionsFromUserMap(Map<String, dynamic> map) {
    return UserOptions();
  }

  List<Address> buildAddressesFromUserMap(Map<String, dynamic> map) {
    return List.empty();
  }

  List<ItemModel> buildLikedItemsFromUserMap(Map<String, dynamic> map) {
    return List.empty();
  }
}
