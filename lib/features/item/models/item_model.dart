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
