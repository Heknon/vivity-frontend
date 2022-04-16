class UserOptions {
  final Unit? unit;
  final String? currencyType;

//<editor-fold desc="Data Methods">

  const UserOptions({
    this.unit,
    this.currencyType,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserOptions && runtimeType == other.runtimeType && unit == other.unit && currencyType == other.currencyType);

  @override
  int get hashCode => unit.hashCode ^ currencyType.hashCode;

  @override
  String toString() {
    return 'UserOptions{' + ' unit: $unit,' + ' currencyType: $currencyType,' + '}';
  }

  UserOptions copyWith({
    Unit? unit,
    String? currencyType,
  }) {
    return UserOptions(
      unit: unit ?? this.unit,
      currencyType: currencyType ?? this.currencyType,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'unit': this.unit?.index,
      'currency_type': this.currencyType,
    };
  }

  factory UserOptions.fromMap(Map<String, dynamic> map) {
    return UserOptions(
      unit: Unit.values[(map['unit'] as num).toInt()],
      currencyType: map['currency_type'] as String,
    );
  }

//</editor-fold>
}

enum Unit { metric, empirical }
