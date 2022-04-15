part of 'drawer_bloc.dart';

@immutable
abstract class DrawerState {
  const DrawerState();
}

class DrawerUnloaded extends DrawerState {}

class DrawerLoading extends DrawerUnloaded {}

class DrawerLoaded extends DrawerState {
  final bool ownsBusiness;
  final bool isAdmin;
  final Uint8List? profilePicture;
  final String name;

//<editor-fold desc="Data Methods">

  const DrawerLoaded({
    required this.ownsBusiness,
    required this.isAdmin,
    required this.profilePicture,
    required this.name,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DrawerLoaded &&
          runtimeType == other.runtimeType &&
          ownsBusiness == other.ownsBusiness &&
          isAdmin == other.isAdmin &&
          profilePicture == other.profilePicture &&
          name == other.name);

  @override
  int get hashCode => ownsBusiness.hashCode ^ isAdmin.hashCode ^ profilePicture.hashCode ^ name.hashCode;

  @override
  String toString() {
    return 'DrawerLoaded{' + ' ownsBusiness: $ownsBusiness,' + ' isAdmin: $isAdmin,' + ' profilePicture: $profilePicture,' + ' name: $name,' + '}';
  }

  DrawerLoaded copyWith({
    bool? ownsBusiness,
    bool? isAdmin,
    Uint8List? profilePicture,
    String? name,
  }) {
    return DrawerLoaded(
      ownsBusiness: ownsBusiness ?? this.ownsBusiness,
      isAdmin: isAdmin ?? this.isAdmin,
      profilePicture: profilePicture ?? this.profilePicture,
      name: name ?? this.name,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'ownsBusiness': this.ownsBusiness,
      'isAdmin': this.isAdmin,
      'profilePicture': this.profilePicture,
      'name': this.name,
    };
  }

  factory DrawerLoaded.fromMap(Map<String, dynamic> map) {
    return DrawerLoaded(
      ownsBusiness: map['ownsBusiness'] as bool,
      isAdmin: map['isAdmin'] as bool,
      profilePicture: map['profilePicture'] as Uint8List,
      name: map['name'] as String,
    );
  }

//</editor-fold>
}
