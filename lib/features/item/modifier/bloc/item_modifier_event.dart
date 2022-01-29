part of 'item_modifier_bloc.dart';

abstract class ItemModifierEvent extends Equatable {
  const ItemModifierEvent();
}

class ItemModifierAddItemEvent extends ItemModifierEvent {
  final int addedItemIndex;

  const ItemModifierAddItemEvent(this.addedItemIndex);

  @override
  List<Object?> get props => [addedItemIndex];
}

class ItemModifierRemoveItemEvent extends ItemModifierEvent {
  final int removedItemIndex;

  const ItemModifierRemoveItemEvent(this.removedItemIndex);

  @override
  List<Object?> get props => [removedItemIndex];
}
