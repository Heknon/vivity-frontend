import 'package:flutter/foundation.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:path_provider/path_provider.dart';

HydratedStorage? _storage;

Future<HydratedStorage> initializeStorage() async {
  _storage = await HydratedStorage.build(
      storageDirectory: kIsWeb ? HydratedStorage.webStorageDirectory : await getApplicationDocumentsDirectory(),
  );

  return _storage!;
}

HydratedStorage? getStorage() {
  return _storage;
}

