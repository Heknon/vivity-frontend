class CartItemModel {
  final String previewImage;
  final String title;
  final Iterable<ModificationButtonDataHost> chosenData;
  final double price;
  int quantity;

  CartItemModel({
    required this.previewImage,
    required this.title,
    required this.chosenData,
    required this.quantity,
    required this.price,
  });

  /// dataChosen: Key is ModificationButton index value are the indices of the data chosen.
  factory CartItemModel.fromItemModel({required ItemModel model, required int quantity, required Map<int, List<int>> dataChosen}) {
    List<ModificationButtonDataHost> chosenData = List.empty(growable: true);

    dataChosen.forEach(
      (key, value) => chosenData.add(ModificationButtonDataHost.fromModificationButton(model.itemStoreFormat.modificationButtons[key], value)),
    );

    return CartItemModel(
      previewImage: model.images[model.previewImageIndex],
      title: model.itemStoreFormat.title,
      chosenData: chosenData,
      quantity: quantity,
      price: model.price,
    );
  }

  CartItemModel copyWith({
    String? previewImage,
    String? title,
    Iterable<ModificationButtonDataHost>? chosenData,
    double? price,
    int? quantity,
  }) {
    return CartItemModel(
      previewImage: previewImage ?? this.previewImage,
      title: title ?? this.title,
      chosenData: chosenData ?? this.chosenData.map((e) => e.copyWith()),
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
    );
  }

  @override
  String toString() {
    return 'CartItemModel{previewImage: $previewImage, title: $title, chosenData: $chosenData, price: $price, quantity: $quantity}';
  }
}

class ItemModel {
  final String businessName;
  final double price;
  final List<String> images;
  final int previewImageIndex;
  final List<Review> reviews;
  final ItemStoreFormat itemStoreFormat;
  final String brand;
  final String category;
  final List<String> tags;
  final int stock;

  const ItemModel({
    required this.businessName,
    required this.price,
    required this.images,
    this.previewImageIndex = 0,
    required this.reviews,
    required this.itemStoreFormat,
    required this.brand,
    required this.category,
    required this.tags,
    required this.stock,
  });

  @override
  String toString() {
    return 'ItemModel{businessName: $businessName, price: $price, images: $images, previewImageIndex: $previewImageIndex, reviews: $reviews, itemStoreFormat: $itemStoreFormat, brand: $brand, category: $category, tags: $tags, stock: $stock}';
  }

  ItemModel copyWith({
    String? businessName,
    double? price,
    List<String>? images,
    int? previewImageIndex,
    List<Review>? reviews,
    ItemStoreFormat? itemStoreFormat,
    String? brand,
    String? category,
    List<String>? tags,
    int? stock,
  }) {
    return ItemModel(
      businessName: businessName ?? this.businessName,
      price: price ?? this.price,
      images: images ?? this.images,
      previewImageIndex: previewImageIndex ?? this.previewImageIndex,
      reviews: reviews ?? this.reviews,
      itemStoreFormat: itemStoreFormat ?? this.itemStoreFormat.copyWith(),
      brand: brand ?? this.brand,
      category: category ?? this.category,
      tags: tags ?? this.tags,
      stock: stock ?? this.stock,
    );
  }
}

class Review {
  final String posterName;
  final String pfpImage;
  final double rating;
  final String textContent;
  final List<String> imageUrls;

  const Review({required this.posterName, required this.pfpImage, required this.rating, required this.textContent, required this.imageUrls});

  @override
  String toString() {
    return 'Review{posterName: $posterName, pfpImage: $pfpImage, rating: $rating, textContent: $textContent, imageUrls: $imageUrls}';
  }

  Review copyWith({
    String? posterName,
    String? pfpImage,
    double? rating,
    String? textContent,
    List<String>? imageUrls,
  }) {
    return Review(
      posterName: posterName ?? this.posterName,
      pfpImage: pfpImage ?? this.pfpImage,
      rating: rating ?? this.rating,
      textContent: textContent ?? this.textContent,
      imageUrls: imageUrls ?? this.imageUrls,
    );
  }
}

class ItemStoreFormat {
  final String title;
  final String? subtitle;
  final String? description;
  final List<ModificationButton> modificationButtons;

  const ItemStoreFormat({required this.title, this.subtitle, this.description, this.modificationButtons = const []});

  @override
  String toString() {
    return 'ItemStoreFormat{title: $title, subtitle: $subtitle, description: $description, modificationButtons: $modificationButtons}';
  }

  ItemStoreFormat copyWith({
    String? title,
    String? subtitle,
    String? description,
    List<ModificationButton>? modificationButtons,
  }) {
    return ItemStoreFormat(
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      description: description ?? this.description,
      modificationButtons: modificationButtons ?? this.modificationButtons.map((e) => e.copyWith()).toList(),
    );
  }
}

enum ModificationButtonSide {
  left,
  center,
  right,
}

enum ModificationButtonDataType {
  text,
  color,
  image,
}

class ModificationButtonDataHost {
  final String name;
  final ModificationButtonDataType dataType;
  final List<Object> dataChosen;

  ModificationButtonDataHost({required this.name, required this.dataType, required this.dataChosen});

  factory ModificationButtonDataHost.fromModificationButton(ModificationButton button, List<int> chosenIndices) {
    int dataLength = button.data.length;
    List<Object> chosenData = List.generate(chosenIndices.length, (index) {
      int _index = chosenIndices[index];
      if (_index >= dataLength) throw IndexError(_index, dataLength, "Chosen indices passed an index out of the data's range!");

      return button.data[_index];
    });

    return ModificationButtonDataHost(name: button.name, dataType: button.dataType, dataChosen: chosenData);
  }

  @override
  String toString() {
    return 'ModificationButtonDataHost{name: $name, dataType: $dataType, dataChosen: $dataChosen}';
  }

  ModificationButtonDataHost copyWith({
    String? name,
    ModificationButtonDataType? dataType,
    List<Object>? dataChosen,
  }) {
    return ModificationButtonDataHost(
      name: name ?? this.name,
      dataType: dataType ?? this.dataType,
      dataChosen: dataChosen ?? this.dataChosen,
    );
  }
}

class ModificationButton {
  final String name;
  final ModificationButtonSide modificationButtonSide;
  final List<Object> data;
  final ModificationButtonDataType dataType;
  final bool multiSelect;

  const ModificationButton({
    required this.name,
    required this.data,
    required this.dataType,
    this.multiSelect = false,
    required this.modificationButtonSide,
  });

  @override
  String toString() {
    return 'ModificationButton{name: $name, modificationButtonSide: $modificationButtonSide, data: $data, dataType: $dataType, multiSelect: $multiSelect}';
  }

  ModificationButton copyWith({
    String? name,
    ModificationButtonSide? modificationButtonSide,
    List<Object>? data,
    ModificationButtonDataType? dataType,
    bool? multiSelect,
  }) {
    return ModificationButton(
      name: name ?? this.name,
      modificationButtonSide: modificationButtonSide ?? this.modificationButtonSide,
      data: data ?? this.data,
      dataType: dataType ?? this.dataType,
      multiSelect: multiSelect ?? this.multiSelect,
    );
  }
}
