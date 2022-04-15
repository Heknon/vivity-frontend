import 'package:flutter/foundation.dart';
import 'package:vivity/features/item/models/modification_button_data_type.dart';
import 'package:vivity/features/item/models/modification_button_side.dart';

class ModificationButton {
  final String name;
  final ModificationButtonSide side;
  final List<Object> data;
  final ModificationButtonDataType dataType;
  final bool multiSelect;

  const ModificationButton({
    required this.name,
    required this.data,
    required this.dataType,
    this.multiSelect = false,
    required this.side,
  });

  @override
  String toString() {
    return 'ModificationButton{name: $name, side: $side, data: $data, dataType: $dataType, multiSelect: $multiSelect}';
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
      side: modificationButtonSide ?? this.side,
      data: data ?? this.data,
      dataType: dataType ?? this.dataType,
      multiSelect: multiSelect ?? this.multiSelect,
    );
  }

  factory ModificationButton.fromMap(Map<String, dynamic> map) {
    return ModificationButton(
      name: map['name'] as String,
      side: ModificationButtonSide.values[map['side']],
      data: (map['data'] as List<dynamic>).map((e) => e as Object).toList(),
      dataType: ModificationButtonDataType.values[map['data_type']],
      multiSelect: map['multi_select'] as bool,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'side': side.index,
      'data': data,
      'data_type': dataType.index,
      'multi_select': multiSelect,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is ModificationButton &&
              runtimeType == other.runtimeType &&
              name == other.name &&
              side == other.side &&
              listEquals(data, other.data) &&
              dataType == other.dataType &&
              multiSelect == other.multiSelect;

  @override
  int get hashCode => name.hashCode ^ side.hashCode ^ data.hashCode ^ dataType.hashCode ^ multiSelect.hashCode;
}