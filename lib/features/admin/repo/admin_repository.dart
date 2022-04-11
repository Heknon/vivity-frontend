import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:vivity/features/admin/service/admin_service.dart';
import 'package:vivity/features/business/models/business.dart';
import 'package:vivity/features/user/errors/user_error.dart';

class AdminRepository {
  static final AdminRepository _adminRepository = AdminRepository._();
  final AdminService _adminService = AdminService();

  AdminRepository._();

  factory AdminRepository() => _adminRepository;

  List<Business>? _unapprovedBusinesses;

  Future<List<Business>> getUnapprovedBusinesses({
    bool update = false,
    bool getImages = true,
  }) async {
    if (_unapprovedBusinesses != null && !update) return _unapprovedBusinesses!;

    AsyncSnapshot<List<Business>> snapshot = await _adminService.getUnapprovedBusinesses(getImages: getImages);
    if (snapshot.hasError || !snapshot.hasData) {
      throw UserNoAccessException(response: snapshot.error is Response ? snapshot.error as Response : null);
    }

    List<Business> business = snapshot.data!;
    _unapprovedBusinesses = business;
    return _unapprovedBusinesses!;
  }

  Future<Business> updateBusinessApprovalStatus({
    required String businessId,
    required bool approved,
    required String note,
  }) async {
    AsyncSnapshot<Business> snapshot = await _adminService.updateBusinessApproval(businessId: businessId, approved: approved, note: note);
    if (snapshot.hasError || !snapshot.hasData) {
      throw UserNoAccessException(response: snapshot.error is Response ? snapshot.error as Response : null);
    }

    Business business = snapshot.data!;
    _unapprovedBusinesses?.removeWhere((element) => element.businessId == business.businessId);
    _unapprovedBusinesses?.add(business);
    return business;
  }
}
