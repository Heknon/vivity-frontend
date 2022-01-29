part of 'item_modifier_bloc.dart';

/// State has a list of chosen items

class ItemModifierState extends Equatable {
  final Set<int> chosenIndices;

  const ItemModifierState(this.chosenIndices);

  factory ItemModifierState.initial({Set<int> chosenIndices = const {}}) {
    return ItemModifierState(chosenIndices);
  }

  factory ItemModifierState.fromStateAddIndex(ItemModifierState state, int addedIndex) {
    Set<int> clone = Set.of(state.chosenIndices);
    clone.add(addedIndex);
    return ItemModifierState(clone);
  }

  factory ItemModifierState.fromStateRemoveIndex(ItemModifierState state, int removedIndex) {
    Set<int> clone = Set.of(state.chosenIndices);
    clone.remove(removedIndex);
    return ItemModifierState(clone);
  }

  @override
  List<Object?> get props => [chosenIndices];
}
