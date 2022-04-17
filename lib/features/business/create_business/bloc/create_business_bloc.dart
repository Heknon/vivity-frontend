import 'dart:async';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:latlng/latlng.dart';
import 'package:meta/meta.dart';
import 'package:vivity/features/business/models/business.dart';
import 'package:vivity/features/business/repo/user_business_repository.dart';
import 'package:vivity/features/user/repo/user_repository.dart';
import 'package:vivity/services/network_exception.dart';

part 'create_business_event.dart';

part 'create_business_state.dart';

class CreateBusinessBloc extends Bloc<CreateBusinessEvent, CreateBusinessState> {
  UserBusinessRepository _businessRepository = UserBusinessRepository();
  UserRepository _userRepository = UserRepository();

  CreateBusinessBloc() : super(CreateBusinessNotCreated()) {
    on<CreateBusinessCreateEvent>((event, emit) async {
      try {
        emit(CreateBusinessCreating());
        Business business = await _businessRepository.createBusiness(
          name: event.businessName,
          email: event.businessEmail,
          phone: event.businessPhone,
          latitude: event.location.latitude,
          longitude: event.location.longitude,
          nationalBusinessId: event.nationalBusinessNumber,
          ownerId: event.ownerId,
        );

        await _userRepository.getUser(update: true);
        emit(CreateBusinessCreated(business));
      } on Exception catch (e) {
        if (e is NetworkException) return emit(CreateBusinessFailedCreating(e.message ?? e.response?.data['error'] ?? 'Failed creating business'));
        emit(CreateBusinessFailedCreating('Failed creating business'));
      }
    });
  }
}
