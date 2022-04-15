part of 'item_page_bloc.dart';

@immutable
abstract class ItemPageEvent {}

class ItemPageLoadEvent extends ItemPageEvent {
  final ItemModel item;

  ItemPageLoadEvent({required this.item});
}

class ItemPageUnloadEvent extends ItemPageEvent {}

class ItemPageSwapImagesEvent extends ItemPageEvent {
  final int index;
  final File image;

  ItemPageSwapImagesEvent({required this.index, required this.image});
}

class ItemPageDeleteImageEvent extends ItemPageEvent {
  final int index;

  ItemPageDeleteImageEvent({required this.index});
}

