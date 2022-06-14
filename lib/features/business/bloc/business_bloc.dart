import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:objectid/objectid/objectid.dart';
import 'package:vivity/features/business/models/business.dart';
import 'package:vivity/features/business/models/order.dart';
import 'package:vivity/features/business/models/order_item.dart';
import 'package:vivity/features/business/repo/user_business_repository.dart';
import 'package:vivity/features/item/models/item_model.dart';
import 'package:vivity/features/item/repo/item_repository.dart';
import 'package:vivity/features/order/service/order_service.dart';
import 'package:vivity/helpers/list_utils.dart';

part 'business_event.dart';

part 'business_state.dart';

class BusinessBloc extends Bloc<BusinessEvent, BusinessState> {
  UserBusinessRepository _businessRepository = UserBusinessRepository();
  ItemRepository _itemRepository = ItemRepository();

  BusinessBloc() : super(BusinessNoBusiness()) {
    on<BusinessLoadEvent>((event, emit) async {
      emit(BusinessLoading());

      Business business = await _businessRepository.getBusiness(update: true);
      List<ItemModel> businessItems = (await _itemRepository.getItemModelsFromId(
        itemIds: business.items.map((e) => e.hexString).toList(),
        fetchImagesOnUpdate: true,
        update: true,
      ))
          .removeNull();

      List<Order> orders = await _businessRepository.getBusinessOrders(update: true);
      List<String> orderItemIds = List.empty(growable: true);
      for (Order order in orders) {
        for (OrderItem orderItem in order.items) {
          if (orderItem.itemId?.hexString != null) orderItemIds.add(orderItem.itemId!.hexString);
        }
      }
      List<ItemModel> orderItems = (await _itemRepository.getItemModelsFromId(
        itemIds: orderItemIds,
        fetchImagesOnUpdate: true,
        update: true,
      ))
          .removeNull();

      emit(BusinessLoaded(business: business, orders: orders, items: businessItems, orderItems: orderItems));
    });

    /// Called to update frontend only - backend should be updated separately!
    on<BusinessCreateItemEvent>((event, emit) async {
      BusinessState s = state;
      if (s is! BusinessLoaded) return;

      emit(s.copyWith(items: s.items.map((e) => e).toList()..add(event.item))); // instantly update UI and then send network request to validate

      Business business = await _businessRepository.getBusiness(update: true);
      if (business.businessId != event.item.businessId) return;

      List<ItemModel> businessItems = (await _itemRepository.getItemModelsFromId(
        itemIds: business.items.map((e) => e.hexString).toList(),
        fetchImagesOnUpdate: true,
        update: true,
      ))
          .removeNull();

      emit(s.copyWith(items: businessItems, business: business));
    });

    /// Called to update frontend only - backend should be updated separately!
    on<BusinessChangeOrderEvent>((event, emit) async {
      BusinessState s = state;
      if (s is! BusinessLoaded) return;

      Business business = await _businessRepository.getBusiness(update: true);
      if (!business.orders.contains(event.order.orderId)) return;

      List<Order> newOrders = List.empty(growable: true);
      for (Order order in s.orders) {
        if (order.orderId.hexString == event.order.orderId) {
          newOrders.add(event.order);
        } else {
          newOrders.add(order);
        }
      }

      emit(s.copyWith(orders: newOrders, business: business));
    });

    /// Called to update frontend only - backend should be updated separately!
    on<BusinessUpdateStockEvent>((event, emit) async {
      BusinessState s = state;
      if (s is! BusinessLoaded) return;

      Business business = await _businessRepository.getBusiness(update: true);
      if (!business.items.contains(ObjectId.fromHexString(event.id))) return;

      List<ItemModel> newItems = List.empty(growable: true);
      for (ItemModel item in s.items) {
        if (item.id.hexString == event.id) {
          newItems.add(item.copyWith(stock: event.stock));
        } else {
          newItems.add(item);
        }
      }

      emit(s.copyWith(items: newItems, business: business));
    });
  }
}
