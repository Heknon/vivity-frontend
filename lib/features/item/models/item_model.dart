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
}

class Review {
  final String posterName;
  final String pfpImage;
  final double rating;
  final String textContent;
  final List<String> imageUrls;

  const Review({required this.posterName, required this.pfpImage, required this.rating, required this.textContent, required this.imageUrls});
}

class ItemStoreFormat {
  final String title;
  final String? subtitle;
  final String? description;
  final List<ModificationButton> modificationButtons;

  const ItemStoreFormat({required this.title, this.subtitle, this.description, this.modificationButtons = const []});
}

enum ModificationButtonSide { left, center, right }

enum ModificationButtonDataType { text, color, image }

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
}
