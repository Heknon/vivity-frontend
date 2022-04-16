part of 'admin_page_bloc.dart';

@immutable
abstract class AdminPageEvent {
  const AdminPageEvent();
}

class AdminPageLoadEvent extends AdminPageEvent {}

class AdminPageChangeApprovalEvent extends AdminPageEvent {
  final String note;
  final String businessId;

  const AdminPageChangeApprovalEvent({
    required this.note,
    required this.businessId,
  });
}

class AdminPageMoveToApprovedEvent extends AdminPageChangeApprovalEvent {
  AdminPageMoveToApprovedEvent({
    required String note,
    required String businessId,
  }) : super(note: note, businessId: businessId);
}

class AdminPageMoveToUnapprovedEvent extends AdminPageChangeApprovalEvent {
  AdminPageMoveToUnapprovedEvent({
    required String note,
    required String businessId,
  }) : super(note: note, businessId: businessId);
}
