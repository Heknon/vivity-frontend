part of 'home_bloc.dart';

@immutable
abstract class HomeState {}

class HomeBlocked extends HomeState {}

class HomeLoading extends HomeState {}

class HomeLoadFailed extends HomeBlocked {
  final String? message;

  HomeLoadFailed({this.message});
}

class HomeLoaded extends HomeState {
  final User user;

  HomeLoaded({required this.user});
}
