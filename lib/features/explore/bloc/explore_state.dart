part of 'explore_bloc.dart';

@immutable
abstract class ExploreState {}

class ExploreUnloaded extends ExploreState {}

class ExploreLoaded extends ExploreState {
  String token;

  final MapControllerImpl controller;
  final LatLng lastUpdateLocation;
  final List<ItemModel> itemModels;
  final MapGuiController mapGuiController;

  ExploreLoaded({
    required this.token,
    required this.controller,
    required this.itemModels,
    required this.lastUpdateLocation,
    required this.mapGuiController,
  });

  Future<ExploreState> fetchItemModels() async {
    int radius = Geolocator.distanceBetween(
      controller.center.latitude,
      controller.center.longitude,
      controller.bounds!.southEast.latitude,
      controller.bounds!.southEast.longitude,
    ).round();


    List<ItemModel> models = await searchByCoordinates(token, controller.center, radius.toDouble());
    itemModels.clear();

    return copyWith(
      itemModels: models,
      lastUpdateLocation: controller.center,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExploreLoaded &&
          runtimeType == other.runtimeType &&
          controller.center == other.controller.center &&
          controller.bounds == other.controller.bounds &&
          controller.zoom == other.controller.zoom &&
          lastUpdateLocation == other.lastUpdateLocation &&
          mapGuiController == other.mapGuiController &&
          listEquals(itemModels, other.itemModels);

  @override
  int get hashCode => controller.hashCode ^ itemModels.hashCode ^ lastUpdateLocation.hashCode ^ mapGuiController.hashCode;

  ExploreLoaded copyWith({
    MapControllerImpl? controller,
    List<ItemModel>? itemModels,
    LatLng? lastUpdateLocation,
    String? token,
    MapGuiController? mapGuiController,
  }) {
    return ExploreLoaded(
      token: token ?? this.token,
      controller: controller ?? this.controller,
      itemModels: itemModels ?? this.itemModels,
      lastUpdateLocation: lastUpdateLocation ?? this.lastUpdateLocation,
      mapGuiController: mapGuiController ?? this.mapGuiController,
    );
  }

  @override
  String toString() {
    return 'ExploreLoaded{controller: ${controller.hashCode}, lastUpdateLocation: $lastUpdateLocation, itemModels: $itemModels, mapGuiController: ${mapGuiController.hashCode}';
  }
}
