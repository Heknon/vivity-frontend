part of 'business_bloc.dart';

@immutable
abstract class BusinessEvent {}

class BusinessLoadEvent extends BusinessEvent {}

class BusinessCreateItemEvent extends BusinessEvent {
  final ItemModel item;

  BusinessCreateItemEvent(this.item);
}

class BusinessUpdateStockEvent extends BusinessEvent {
  final String id;
  final int stock;

  BusinessUpdateStockEvent(this.id, this.stock);
}

class BusinessChangeOrderEvent extends BusinessEvent {
  final Order order;

  BusinessChangeOrderEvent(this.order);
}
