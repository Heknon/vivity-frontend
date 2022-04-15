import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:objectid/objectid/objectid.dart';
import 'package:vivity/features/business/models/business.dart';
import 'package:vivity/features/business/repo/user_business_repository.dart';
import 'package:vivity/features/item/models/item_model.dart';
import 'package:vivity/features/item/repo/item_repository.dart';
import 'package:vivity/features/user/errors/user_error.dart';
import 'package:vivity/features/user/models/business_user.dart';
import 'package:vivity/features/user/models/user.dart';
import 'package:vivity/features/user/repo/user_repository.dart';

part 'item_page_event.dart';

part 'item_page_state.dart';

class ItemPageBloc extends Bloc<ItemPageEvent, ItemPageState> {
  UserRepository _userRepository = UserRepository();
  ItemRepository _itemRepository = ItemRepository();
  UserBusinessRepository _userBusinessRepository = UserBusinessRepository();

  ItemPageBloc() : super(ItemPageBlocked()) {
    on<ItemPageLoadEvent>((event, emit) async {
      emit(ItemPageLoading());

      User user = await _userRepository.getUser();
      bool ownsItem = false;
      bool isItemLiked = false;

      if (user is BusinessUser) {
        ObjectId businessId = user.businessId;
        try {
          Business business = await _userBusinessRepository.getBusiness();
          ownsItem = business.items.contains(event.item.id) && event.item.businessId == businessId;
        } on UserNoAccessException catch (e) {}
      }

      for (ItemModel likedItem in user.likedItems) {
        if (event.item.id == likedItem.id) {
          isItemLiked = true;
          break;
        }
      }

      emit(ItemPageLoaded(
        ownsItem: ownsItem,
        isLiked: isItemLiked,
        images: event.item.images,
        id: event.item.id,
      ));
    });

    on<ItemPageSwapImagesEvent>((event, emit) async {
      if (state is! ItemPageLoaded) return;

      ItemModel item = await _itemRepository.updateItemImage(
        image: event.image,
        index: event.index,
        id: (state as ItemPageLoaded).id.hexString,
      );


      emit((state as ItemPageLoaded).copyWith(
        images: item.images,
      ));
    });

    on<ItemPageDeleteImageEvent>((event, emit) async {
      if (state is! ItemPageLoaded) return;

      ItemModel item = await _itemRepository.deleteItemImage(
        index: event.index,
        id: (state as ItemPageLoaded).id.hexString,
      );


      emit((state as ItemPageLoaded).copyWith(
        images: item.images,
      ));
    });

    on<ItemPageUnloadEvent>((event, emit) {
      emit(ItemPageBlocked());
    });
  }
}
