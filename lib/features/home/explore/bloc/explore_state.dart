part of 'explore_bloc.dart';

@immutable
abstract class ExploreState {
  const ExploreState();
}

class ExploreBlocked extends ExploreState {}

class ExploreSearchable extends ExploreState {
  const ExploreSearchable();
}

class ExploreSearched extends ExploreSearchable {
  final List<ItemModel> itemsFound;
  final List<Business> businessesFound;

//<editor-fold desc="Data Methods">

  const ExploreSearched({
    required this.itemsFound,
    required this.businessesFound,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ExploreSearched &&
          runtimeType == other.runtimeType &&
          listEquals(itemsFound, other.itemsFound) &&
          listEquals(businessesFound, other.businessesFound));

  @override
  int get hashCode => itemsFound.hashCode ^ businessesFound.hashCode;

  @override
  String toString() {
    return 'ExploreSearched{' + ' itemsFound: $itemsFound,' + ' businessesFound: $businessesFound,' + '}';
  }

  ExploreSearched copyWith({
    List<ItemModel>? itemsFound,
    List<Business>? businessesFound,
  }) {
    return ExploreSearched(
      itemsFound: itemsFound ?? this.itemsFound,
      businessesFound: businessesFound ?? this.businessesFound,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'itemsFound': this.itemsFound,
      'businessesFound': this.businessesFound,
    };
  }

  factory ExploreSearched.fromMap(Map<String, dynamic> map) {
    return ExploreSearched(
      itemsFound: map['itemsFound'] as List<ItemModel>,
      businessesFound: map['businessesFound'] as List<Business>,
    );
  }

//</editor-fold>
}
