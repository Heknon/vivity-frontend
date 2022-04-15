part of 'item_page_bloc.dart';

@immutable
abstract class ItemPageState {
  const ItemPageState();
}

class ItemPageBlocked extends ItemPageState {}

class ItemPageLoading extends ItemPageBlocked {}

class ItemPageLoaded extends ItemPageState {
  final ObjectId id;
  final bool isLiked;
  final bool ownsItem;
  final List<Uint8List> images;

//<editor-fold desc="Data Methods">

  const ItemPageLoaded({
    required this.id,
    required this.isLiked,
    required this.ownsItem,
    required this.images,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ItemPageLoaded &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          isLiked == other.isLiked &&
          ownsItem == other.ownsItem &&
          images == other.images);

  @override
  int get hashCode => id.hashCode ^ isLiked.hashCode ^ ownsItem.hashCode ^ images.hashCode;

  @override
  String toString() {
    return 'ItemPageLoaded{' + ' id: $id,' + ' isLiked: $isLiked,' + ' ownsItem: $ownsItem,' + ' images: $images,' + '}';
  }

  ItemPageLoaded copyWith({
    ObjectId? id,
    bool? isLiked,
    bool? ownsItem,
    List<Uint8List>? images,
  }) {
    return ItemPageLoaded(
      id: id ?? this.id,
      isLiked: isLiked ?? this.isLiked,
      ownsItem: ownsItem ?? this.ownsItem,
      images: images ?? this.images,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': this.id,
      'isLiked': this.isLiked,
      'ownsItem': this.ownsItem,
      'images': this.images,
    };
  }

  factory ItemPageLoaded.fromMap(Map<String, dynamic> map) {
    return ItemPageLoaded(
      id: map['id'] as ObjectId,
      isLiked: map['isLiked'] as bool,
      ownsItem: map['ownsItem'] as bool,
      images: map['images'] as List<Uint8List>,
    );
  }

//</editor-fold>
}
