import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'item_modifier_event.dart';

part 'item_modifier_state.dart';

class ItemModifierBloc extends Bloc<ItemModifierEvent, ItemModifierState> {
  ItemModifierBloc({Iterable<int> initialDataChosen = const []})
      : super(ItemModifierState.initial(chosenIndices: Set.of(initialDataChosen))) {
    on<ItemModifierEvent>((event, emit) {
      if (event is ItemModifierAddItemEvent) {
        emit(ItemModifierState.fromStateAddIndex(state, event.addedItemIndex));
      } else if (event is ItemModifierRemoveItemEvent) {
        emit(ItemModifierState.fromStateRemoveIndex(state, event.removedItemIndex));
      }
    });
  }

  @override
  void onTransition(Transition<ItemModifierEvent, ItemModifierState> transition) {
    super.onTransition(transition);
  }
}
