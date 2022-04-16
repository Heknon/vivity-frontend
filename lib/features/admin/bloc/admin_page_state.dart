part of 'admin_page_bloc.dart';

@immutable
abstract class AdminPageState {
  const AdminPageState();
}

class AdminPageUnloaded extends AdminPageState {}

class AdminPageLoading extends AdminPageUnloaded {}

class AdminPageLoaded extends AdminPageState {
  final List<Business> unapprovedBusinesses;
  final List<Business> approvedBusinesses;

//<editor-fold desc="Data Methods">

  const AdminPageLoaded({
    required this.unapprovedBusinesses,
    required this.approvedBusinesses,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AdminPageLoaded &&
          runtimeType == other.runtimeType &&
          unapprovedBusinesses == other.unapprovedBusinesses &&
          approvedBusinesses == other.approvedBusinesses);

  @override
  int get hashCode => unapprovedBusinesses.hashCode ^ approvedBusinesses.hashCode;

  @override
  String toString() {
    return 'AdminPageLoaded{' + ' unapprovedBusinesses: $unapprovedBusinesses,' + ' approvedBusinesses: $approvedBusinesses,' + '}';
  }

  AdminPageLoaded copyWith({
    List<Business>? unapprovedBusinesses,
    List<Business>? approvedBusinesses,
  }) {
    return AdminPageLoaded(
      unapprovedBusinesses: unapprovedBusinesses ?? this.unapprovedBusinesses,
      approvedBusinesses: approvedBusinesses ?? this.approvedBusinesses,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'unapprovedBusinesses': this.unapprovedBusinesses,
      'approvedBusinesses': this.approvedBusinesses,
    };
  }

  factory AdminPageLoaded.fromMap(Map<String, dynamic> map) {
    return AdminPageLoaded(
      unapprovedBusinesses: map['unapprovedBusinesses'] as List<Business>,
      approvedBusinesses: map['approvedBusinesses'] as List<Business>,
    );
  }

//</editor-fold>
}
