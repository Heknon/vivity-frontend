class UserOptions {
  final double? businessSearchRadius;
  final String? distanceUnit;
  final String? currencyType;
  final String? shirtSize;
  final String? jeansSize;
  final String? sweatsSize;

  UserOptions({
    this.businessSearchRadius,
    this.distanceUnit,
    this.currencyType,
    this.shirtSize,
    this.jeansSize,
    this.sweatsSize,
  });

  factory UserOptions.fromMap(Map<String, dynamic> map) {
    return UserOptions(
      businessSearchRadius: map['businessSearchRadius'] as double?,
      distanceUnit: map['distanceUnit'] as String?,
      currencyType: map['currencyType'] as String?,
      shirtSize: map['shirtSize'] as String?,
      jeansSize: map['jeansSize'] as String?,
      sweatsSize: map['sweatsSize'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'businessSearchRadius': businessSearchRadius,
      'distanceUnit': distanceUnit,
      'currencyType': currencyType,
      'shirtSize': shirtSize,
      'jeansSize': jeansSize,
      'sweatsSize': sweatsSize,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserOptions &&
          runtimeType == other.runtimeType &&
          businessSearchRadius == other.businessSearchRadius &&
          distanceUnit == other.distanceUnit &&
          currencyType == other.currencyType &&
          shirtSize == other.shirtSize &&
          jeansSize == other.jeansSize &&
          sweatsSize == other.sweatsSize;

  @override
  int get hashCode =>
      businessSearchRadius.hashCode ^ distanceUnit.hashCode ^ currencyType.hashCode ^ shirtSize.hashCode ^ jeansSize.hashCode ^ sweatsSize.hashCode;

  @override
  String toString() {
    return 'UserOptions{businessSearchRadius: $businessSearchRadius, distanceUnit: $distanceUnit, currencyType: $currencyType, shirtSize: $shirtSize, jeansSize: $jeansSize, sweatsSize: $sweatsSize}';
  }
}
