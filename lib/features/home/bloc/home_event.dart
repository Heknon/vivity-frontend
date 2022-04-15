part of 'home_bloc.dart';

@immutable
abstract class HomeEvent {}

class HomeLoadEvent extends HomeEvent {}

class HomeUnloadEvent extends HomeEvent {}
