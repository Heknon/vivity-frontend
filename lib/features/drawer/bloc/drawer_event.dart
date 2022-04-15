part of 'drawer_bloc.dart';

@immutable
abstract class DrawerEvent {}

class DrawerLoadEvent extends DrawerEvent {}

class DrawerUpdateProfilePictureEvent extends DrawerEvent {
  final File file;

  DrawerUpdateProfilePictureEvent(this.file);
}

class DrawerDeleteProfilePictureEvent extends DrawerEvent {}
