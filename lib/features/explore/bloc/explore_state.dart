part of 'explore_bloc.dart';

@immutable
abstract class ExploreState {}

class ExploreUnloaded extends ExploreState {}

class ExploreLoaded extends ExploreState {
  String token;

  final LatLng position;
  final LatLng registeredPosition;
  final LatLngBounds bounds;
  final LatLngBounds registeredBounds;
  final List<ItemModel> itemModels;

  ExploreLoaded({
    required this.token,
    required this.position,
    required this.registeredPosition,
    required this.bounds,
    required this.registeredBounds,
    required this.itemModels,
  });

  Future<String?> fetchItemModels() async {
    double radius = Geolocator.distanceBetween(
      registeredPosition.latitude,
      registeredPosition.longitude,
      registeredBounds.southEast.latitude,
      registeredBounds.southEast.longitude,
    );
    itemModels.clear();
    print("fetching items");
    List<ItemModel> models = await searchByCoordinates(token, position, radius);
    itemModels.addAll(models);
    return null;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExploreLoaded &&
          runtimeType == other.runtimeType &&
          registeredPosition == other.registeredPosition &&
          registeredBounds == other.registeredBounds &&
          position == other.position &&
          bounds == other.bounds;

  @override
  int get hashCode => registeredPosition.hashCode ^ registeredBounds.hashCode ^ position.hashCode ^ bounds.hashCode ^ itemModels.hashCode;

  ExploreLoaded copyWith({
    LatLng? position,
    LatLng? registeredPosition,
    LatLngBounds? bounds,
    LatLngBounds? registeredBounds,
    List<ItemModel>? itemModels,
    String? token,
  }) {
    if ((position == null || identical(position, this.position)) &&
        (registeredPosition == null || identical(registeredPosition, this.registeredPosition)) &&
        (bounds == null || identical(bounds, this.bounds)) &&
        (registeredBounds == null || identical(registeredBounds, this.registeredBounds)) &&
        (token == null || identical(token, this.token))) {
      return this;
    }

    return ExploreLoaded(
        token: token ?? this.token,
        position: position ?? this.position,
        registeredPosition: registeredPosition ?? this.registeredPosition,
        bounds: bounds ?? this.bounds,
        registeredBounds: registeredBounds ?? this.registeredBounds,
        itemModels: itemModels ?? this.itemModels);
  }
}
