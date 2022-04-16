import 'package:flutter_map/plugin_api.dart';

extension MapHelper on MapControllerImpl {
  MapControllerImpl? ifInitialized() {
    try {
      this.center;
      return this;
    } catch (e) {
      return null;
    }
  }
}