class UserOptions {
  final Unit? unit;
  final String? currencyType;

  UserOptions({
    this.unit,
    this.currencyType,
  });

  factory UserOptions.fromMap(Map<String, dynamic> map) {
    return UserOptions(
      unit: Unit.values[map['unit']],
      currencyType: map['currency_type'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'unit': unit,
      'currency_type': currencyType,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserOptions &&
          runtimeType == other.runtimeType &&
          unit == other.unit &&
          currencyType == other.currencyType;

  @override
  int get hashCode =>
       unit.hashCode ^ currencyType.hashCode;

  @override
  String toString() {
    return 'UserOptions{unit: $unit, currencyType: $currencyType}';
  }
}

enum Unit {
  metric,
  empirical
}
