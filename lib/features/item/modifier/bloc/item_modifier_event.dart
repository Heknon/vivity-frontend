part of 'item_modifier_bloc.dart';

abstract class ItemModifierEvent {
  const ItemModifierEvent();
}

class ItemModifierAddItemEvent extends ItemModifierEvent {
  final int index;

  const ItemModifierAddItemEvent(this.index);
}

class ItemModifierRemoveItemEvent extends ItemModifierEvent {
  final int index;

  const ItemModifierRemoveItemEvent(this.index);
}
