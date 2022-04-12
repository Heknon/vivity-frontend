import 'package:flutter/foundation.dart';
import 'package:vivity/features/item/models/modification_button.dart';
import 'package:vivity/features/item/models/modification_button_data_type.dart';

class ModificationButtonDataHost {
  final String name;
  final ModificationButtonDataType dataType;
  final List<dynamic> selectedData;

  ModificationButtonDataHost({required this.name, required this.dataType, required this.selectedData});

  factory ModificationButtonDataHost.fromModificationButton(ModificationButton button, Iterable<int> chosenIndices) {
    int dataLength = button.data.length;
    List<dynamic> chosenData = List.empty(growable: true);

    for (int index in chosenIndices) {
      if (index >= dataLength) throw IndexError(index, dataLength, "Chosen indices passed an index out of the data's range!");

      chosenData.add(button.data[index]);
    }

    return ModificationButtonDataHost(name: button.name, dataType: button.dataType, selectedData: chosenData);
  }

  @override
  String toString() {
    return 'ModificationButtonDataHost{name: $name, dataType: $dataType, selectedData: $selectedData}';
  }

  ModificationButtonDataHost copyWith({
    String? name,
    ModificationButtonDataType? dataType,
    List<Object>? selectedData,
  }) {
    return ModificationButtonDataHost(
      name: name ?? this.name,
      dataType: dataType ?? this.dataType,
      selectedData: selectedData ?? this.selectedData,
    );
  }

  factory ModificationButtonDataHost.fromMap(Map<String, dynamic> map) {
    return ModificationButtonDataHost(
      name: map['name'] as String,
      dataType: ModificationButtonDataType.values[map['data_type']],
      selectedData: map['selected_data'] as List<dynamic>,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'data_type': dataType.index,
      'selected_data': selectedData,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is ModificationButtonDataHost &&
              runtimeType == other.runtimeType &&
              name == other.name &&
              dataType == other.dataType &&
              listEquals(selectedData, other.selectedData);

  @override
  int get hashCode => name.hashCode ^ dataType.hashCode ^ selectedData.hashCode;
}