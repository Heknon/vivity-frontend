import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:vivity/features/item/errors/item_error.dart';
import 'package:vivity/features/item/models/item_model.dart';
import 'package:vivity/features/item/service/item_service.dart';

class ItemRepository {
  static final ItemRepository _itemRepository = ItemRepository._();

  final ItemService _itemService = ItemService();
  final Map<String, ItemModel> _itemModelCache = {};

  ItemRepository._();

  factory ItemRepository() => _itemRepository;

  Future<List<ItemModel?>> getItemModelsFromId({
    required List<String> itemIds,
    bool update = false,
    bool fetchImagesOnUpdate = false,
  }) async {
    /// find the items that need to be brought from the network, if update is set, all items need to.
    List<String> updateList = itemIds.where((element) => !_itemModelCache.containsKey(element) || update).toList();

    if (updateList.isNotEmpty) {
      AsyncSnapshot<List<ItemModel>> snapshot = await _itemService.getItems(itemIds: updateList, getItemImages: fetchImagesOnUpdate);

      if (snapshot.hasError || !snapshot.hasData) {
        throw ItemFetchFailedException();
      }

      List<ItemModel> itemModels = snapshot.data!;
      for (ItemModel newItemModel in itemModels) {
        _registerNetworkItemModelToCache(newItemModel, fetchImagesOnUpdate);
      }
    }

    return List.generate(itemIds.length, (index) => _itemModelCache[itemIds[index]]);
  }

  Future<ItemModel?> getItemFromId({
    required String itemId,
    bool update = false,
    bool fetchImagesOnUpdate = false,
  }) async {
    return (await getItemModelsFromId(
      itemIds: List.of([itemId]),
      update: update,
      fetchImagesOnUpdate: fetchImagesOnUpdate,
    ))[0];
  }

  /// This is 100% network operation.
  Future<ItemModel> createItemModel({
    required String title,
    required String subtitle,
    required String brand,
    required String category,
    required List<String> tags,
    required double price,
  }) async {
    AsyncSnapshot<ItemModel> snapshot = await _itemService.createItem(
      title: title,
      subtitle: subtitle,
      brand: brand,
      category: category,
      tags: tags,
      price: price,
    );

    if (snapshot.hasError || !snapshot.hasData) {
      throw ItemCreationFailedException(response: snapshot.error is Response ? snapshot.error! as Response : null);
    }

    ItemModel created = snapshot.data!;
    _itemModelCache[created.id.hexString] = created;

    return _itemModelCache[created.id.hexString]!;
  }

  Future<ItemModel> updateItemStock({
    required int stock,
    required String id,
    bool updateDatabase = true,
  }) async {
    _throwIfNotInCache(id);

    if (updateDatabase) {
      AsyncSnapshot<ItemModel> snapshot = await _itemService.updateItemStock(
        stock: stock,
        id: id,
      );

      if (snapshot.hasError || !snapshot.hasData) {
        throw ItemUpdateStockFailedException(response: snapshot.error is Response ? snapshot.error! as Response : null);
      }

      ItemModel updatedItem = snapshot.data!;
      _registerNetworkItemModelToCache(updatedItem, false);

      return _itemModelCache[updatedItem.id.hexString]!;
    }

    ItemModel item = _itemModelCache[id]!;
    _itemModelCache[id] = item.copyWith(stock: stock);
    return _itemModelCache[id]!;
  }

  Future<ItemModel> updateItemImage({
    required File image,
    required int index,
    required String id,
    bool updateDatabase = true,
  }) async {
    _throwIfNotInCache(id);

    if (updateDatabase) {
      AsyncSnapshot<ItemModel> snapshot = await _itemService.updateItemImage(
        image: image,
        index: index,
        id: id,
      );

      if (snapshot.hasError || !snapshot.hasData) {
        throw ItemUpdateImageFailedException(response: snapshot.error is Response ? snapshot.error! as Response : null);
      }

      ItemModel updatedItem = snapshot.data!;
      updatedItem = updatedItem.copyWith(images: List.generate(index + 1, (i) => index == i ? image.readAsBytesSync() : null));
      _registerNetworkItemModelToCache(updatedItem, false);

      return _itemModelCache[updatedItem.id.hexString]!;
    }

    ItemModel item = _itemModelCache[id]!;
    item = item.copyWith(
      images: List.generate(index + 1, (i) {
        return index == i ? image.readAsBytesSync() : null;
      }),
    );
    _registerNetworkItemModelToCache(item, false);

    return _itemModelCache[id]!;
  }

  Future<ItemModel> deleteItemImage({
    required int index,
    required String id,
    bool updateDatabase = true,
  }) async {
    _throwIfNotInCache(id);

    if (updateDatabase) {
      AsyncSnapshot<ItemModel> snapshot = await _itemService.deleteItemImage(
        index: index,
        id: id,
      );

      if (snapshot.hasError || !snapshot.hasData) {
        throw ItemUpdateImageFailedException(response: snapshot.error is Response ? snapshot.error! as Response : null);
      }

      ItemModel updatedItem = snapshot.data!;
      _registerNetworkItemModelToCache(updatedItem, false);
      ItemModel cachedItem = _itemModelCache[updatedItem.id.hexString]!;
      List<Uint8List?> newImages = List.empty(growable: true);
      for (int i = 0; i < (cachedItem.images?.length ?? 0); i++) {
        if (i != index) newImages.add(cachedItem.images?[i]);
      }

      _itemModelCache[updatedItem.id.hexString] = cachedItem.copyWith(images: newImages);
      return _itemModelCache[updatedItem.id.hexString]!;
    }

    ItemModel item = _itemModelCache[id]!;
    List<Uint8List?> newImages = List.empty(growable: true);
    for (int i = 0; i < (item.images?.length ?? 0); i++) {
      if (i != index) newImages.add(item.images?[i]);
    }

    _itemModelCache[item.id.hexString] = item.copyWith(images: newImages);
    return _itemModelCache[id]!;
  }

  Future<ItemModel> updateItem({
    required String id,
    String? title,
    String? subtitle,
    String? description,
    double? price,
    String? brand,
    String? category,
    Iterable<String>? tags,
    int? stock,
    List<ModificationButton>? modificationButtons,
    bool updateDatabase = true,
  }) async {
    _throwIfNotInCache(id);

    if (updateDatabase) {
      AsyncSnapshot<ItemModel> snapshot = await _itemService.updateItem(
        id: id,
        stock: stock,
        title: title,
        modificationButtons: modificationButtons,
        brand: brand,
        description: description,
        price: price,
        category: category,
        subtitle: subtitle,
        tags: tags,
      );

      if (snapshot.hasError || !snapshot.hasData) {
        throw ItemUpdateFailedException(response: snapshot.error is Response ? snapshot.error! as Response : null);
      }

      ItemModel updatedItem = snapshot.data!;
      _registerNetworkItemModelToCache(updatedItem, false);

      return _itemModelCache[updatedItem.id.hexString]!;
    }

    ItemModel item = _itemModelCache[id]!;
    Set<String> editedTags = tags?.toSet() ?? item.tags.toSet();

    item = item.copyWith(
      stock: stock,
      itemStoreFormat: item.itemStoreFormat.copyWith(
        title: title,
        description: description,
        subtitle: subtitle,
        modificationButtons: modificationButtons,
      ),
      brand: brand,
      price: price,
      category: category,
      tags: editedTags.toList(),
    );
    _registerNetworkItemModelToCache(item, false);

    return _itemModelCache[id]!;
  }

  Future<void> deleteItem({
    required String id,
    bool updateDatabase = true,
  }) async {
    if (updateDatabase) {
      AsyncSnapshot<bool> snapshot = await _itemService.deleteItem(id: id);

      if (snapshot.hasError || !snapshot.hasData) {
        throw ItemDeleteFailedException(response: snapshot.error is Response ? snapshot.error! as Response : null);
      }

      bool success = snapshot.data!;
      if (!success) {
        throw ItemDeleteFailedException();
      }
    }

    _itemModelCache.remove(id);
  }

  void gracefullyUpdateItems(List<ItemModel> items) {
    for (var item in items) {
      _registerNetworkItemModelToCache(item, false);
    }
  }

  void _registerNetworkItemModelToCache(ItemModel itemModel, bool imagesFetched) {
    ItemModel? oldModel = _itemModelCache[itemModel.id.hexString];

    /// if there is no old model just update to new model and continue since there is no need to see if image data should be set
    if (oldModel == null || oldModel.images == null) {
      _itemModelCache[itemModel.id.hexString] = itemModel;
      return;
    }

    int oldImagesLength = oldModel.images?.length ?? 0;
    int newImagesLength = itemModel.images?.length ?? 0;

    /// go through the images of both old and new models.
    List<Uint8List?> images = List.generate(max(oldImagesLength, newImagesLength), (i) {
      Uint8List? oldImage = i < oldImagesLength ? (oldModel.images?[i]) : null;
      Uint8List? newImage = i < newImagesLength ? (itemModel.images?[i]) : null;
      // if old image is available but there is no new image keep the old one if images werent updated
      if (oldImage != null && newImage == null && !imagesFetched) {
        return oldImage;
      }

      return newImage;
    });

    /// set the image data found with copyWith and set it as the new item model
    _itemModelCache[itemModel.id.hexString] = itemModel.copyWith(images: images);
  }

  /// This is a 100% network call
  Future<ItemModel> addReview({
    required String id,
    required Iterable<File> images,
    required bool anonymous,
    required double rating,
    required String textContent,
  }) async {
    _throwIfNotInCache(id);

    AsyncSnapshot<ItemModel> snapshot = await _itemService.addReview(
      id: id,
      images: images.map((e) => e.readAsBytesSync()).toList(),
      anonymous: anonymous,
      rating: rating,
      textContent: textContent,
    );

    if (snapshot.hasError || !snapshot.hasData) {
      throw ItemAddReviewFailedException(response: snapshot.error is Response ? snapshot.error! as Response : null);
    }

    ItemModel updatedItem = snapshot.data!;
    _registerNetworkItemModelToCache(updatedItem, false);

    return _itemModelCache[updatedItem.id.hexString]!;
  }

  /// This is a 100% network call
  Future<ItemModel> deleteReview({
    required String id,
  }) async {
    _throwIfNotInCache(id);

    AsyncSnapshot<ItemModel> snapshot = await _itemService.deleteReview(
      id: id,
    );

    if (snapshot.hasError || !snapshot.hasData) {
      throw ItemDeleteReviewFailedException(response: snapshot.error is Response ? snapshot.error! as Response : null);
    }

    ItemModel updatedItem = snapshot.data!;
    _registerNetworkItemModelToCache(updatedItem, false);

    return _itemModelCache[updatedItem.id.hexString]!;
  }

  void _throwIfNotInCache(String id) async {
    if (!_itemModelCache.containsKey(id)) {
      try {
        await getItemFromId(itemId: id);
        if (!_itemModelCache.containsKey(id)) throw ItemUpdateFailedException(message: "Item doesn't exist");
      } on ItemFetchFailedException catch (e) {
        throw ItemUpdateFailedException(message: "Item doesn't exist");
      }
    }
  }
}
