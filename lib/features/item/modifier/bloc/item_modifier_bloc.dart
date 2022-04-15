import 'dart:async';

import 'package:bloc/bloc.dart';

part 'item_modifier_event.dart';

part 'item_modifier_state.dart';

class ItemModifierBloc extends Bloc<ItemModifierEvent, ItemModifierState> {
  ItemModifierBloc({Iterable<int> initialDataChosen = const []}) : super(ItemModifierState(chosenIndices: Set.of(initialDataChosen))) {
    on<ItemModifierAddItemEvent>((event, emit) {
      Set<int> newIndices = Set.of(state.chosenIndices);
      newIndices.add(event.index);

      emit(state.copyWith(chosenIndices: newIndices));
    });

    on<ItemModifierRemoveItemEvent>((event, emit) {
      Set<int> newIndices = Set.of(state.chosenIndices);
      newIndices.removeWhere((element) => element == event.index);

      emit(state.copyWith(chosenIndices: newIndices));
    });
  }
}
