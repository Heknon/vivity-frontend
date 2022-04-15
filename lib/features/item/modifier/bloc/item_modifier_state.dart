part of 'item_modifier_bloc.dart';

/// State has a list of chosen items

class ItemModifierState {
  final Set<int> chosenIndices;

  const ItemModifierState({this.chosenIndices = const {}});

//<editor-fold desc="Data Methods">

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is ItemModifierState && runtimeType == other.runtimeType && chosenIndices == other.chosenIndices);

  @override
  int get hashCode => chosenIndices.hashCode;

  @override
  String toString() {
    return 'ItemModifierState{' + ' chosenIndices: $chosenIndices,' + '}';
  }

  ItemModifierState copyWith({
    Set<int>? chosenIndices,
  }) {
    return ItemModifierState(
      chosenIndices: chosenIndices ?? this.chosenIndices,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'chosenIndices': this.chosenIndices,
    };
  }

  factory ItemModifierState.fromMap(Map<String, dynamic> map) {
    return ItemModifierState(
      chosenIndices: map['chosenIndices'] as Set<int>,
    );
  }

//</editor-fold>
}
