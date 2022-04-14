part of 'profile_bloc.dart';


@immutable
abstract class ProfileEvent {}

class ProfileLoadEvent extends ProfileEvent {}

class ProfileUnloadEvent extends ProfileEvent {}

class ProfileDeleteAddressEvent extends ProfileEvent {
  final int index;

  ProfileDeleteAddressEvent(this.index);
}

class ProfileAddAddressEvent extends ProfileEvent {
  final Address address;

  ProfileAddAddressEvent(this.address);
}

