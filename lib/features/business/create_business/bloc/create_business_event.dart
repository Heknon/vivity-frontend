part of 'create_business_bloc.dart';

@immutable
abstract class CreateBusinessEvent {}

class CreateBusinessCreateEvent extends CreateBusinessEvent {
  final String businessName;
  final String businessEmail;
  final String businessPhone;
  final String nationalBusinessNumber;
  final File ownerId;
  final LatLng location;

  CreateBusinessCreateEvent({
    required this.businessName,
    required this.businessEmail,
    required this.businessPhone,
    required this.nationalBusinessNumber,
    required this.ownerId,
    required this.location,
  });
}
