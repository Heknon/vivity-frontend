part of 'create_business_bloc.dart';

@immutable
abstract class CreateBusinessState {}

class CreateBusinessNotCreated extends CreateBusinessState {}

class CreateBusinessCreating extends CreateBusinessState {}

class CreateBusinessFailedCreating extends CreateBusinessState {
  final String message;

  CreateBusinessFailedCreating(this.message);
}


class CreateBusinessCreated extends CreateBusinessState {
  final Business business;

  CreateBusinessCreated(this.business);
}
