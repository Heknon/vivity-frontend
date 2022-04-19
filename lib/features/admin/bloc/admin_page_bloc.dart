import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:vivity/features/admin/repo/admin_repository.dart';
import 'package:vivity/features/business/models/business.dart';
import 'package:vivity/helpers/list_utils.dart';

part 'admin_page_event.dart';

part 'admin_page_state.dart';

class AdminPageBloc extends Bloc<AdminPageEvent, AdminPageState> {
  final AdminRepository _adminRepository = AdminRepository();

  AdminPageBloc() : super(AdminPageUnloaded()) {
    on<AdminPageLoadEvent>((event, emit) async {
      emit(AdminPageLoading());

      List<Business> unapprovedBusinesses = await _adminRepository.getUnapprovedBusinesses(update: true);
      List<Business> approvedBusinesses = await _adminRepository.getApprovedBusinesses(update: true);

      emit(AdminPageLoaded(unapprovedBusinesses: unapprovedBusinesses, approvedBusinesses: approvedBusinesses));
    });

    on<AdminPageMoveToUnapprovedEvent>((event, emit) async {
      AdminPageState s = state;
      if (s is! AdminPageLoaded) return;

      Business business = await _adminRepository.updateBusinessApprovalStatus(
        businessId: event.businessId,
        approved: false,
        note: event.note,
      );

      List<Business> unapprovedBusinesses = List.empty(growable: true);
      List<Business> approvedBusinesses = List.empty(growable: true);

      for (Business unapproved in s.unapprovedBusinesses) {
        if (unapproved.businessId == business.businessId) continue;
        unapprovedBusinesses.add(unapproved);
      }
      unapprovedBusinesses.add(business);

      for (Business approved in s.approvedBusinesses) {
        if (approved.businessId == business.businessId) continue;
        approvedBusinesses.add(approved);
      }

      emit(s.copyWith(approvedBusinesses: approvedBusinesses, unapprovedBusinesses: unapprovedBusinesses));
    });

    on<AdminPageMoveToApprovedEvent>((event, emit) async {
      AdminPageState s = state;
      if (s is! AdminPageLoaded) return;

      Business business = await _adminRepository.updateBusinessApprovalStatus(
        businessId: event.businessId,
        approved: true,
        note: event.note,
      );

      List<Business> unapprovedBusinesses = List.empty(growable: true);
      List<Business> approvedBusinesses = List.empty(growable: true);

      for (Business unapproved in s.unapprovedBusinesses) {
        if (unapproved.businessId == business.businessId) continue;
        unapprovedBusinesses.add(unapproved);
      }

      for (Business approved in s.approvedBusinesses) {
        if (approved.businessId == business.businessId) continue;
        approvedBusinesses.add(approved);
      }
      approvedBusinesses.add(business);

      emit(s.copyWith(approvedBusinesses: approvedBusinesses, unapprovedBusinesses: unapprovedBusinesses));
    });
  }
}
