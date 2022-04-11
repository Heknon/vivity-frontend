class BusinessMetrics {
  final int views;

  BusinessMetrics({
    required this.views,
  });

  factory BusinessMetrics.fromMap(Map<String, dynamic> map) {
    return BusinessMetrics(
      views: (map['views'] as num).toInt(),
    );
  }

  Map<String, dynamic> toMap() {
    // ignore: unnecessary_cast
    return {
      'views': views,
    } as Map<String, dynamic>;
  }

  BusinessMetrics copyWith({
    int? views,
  }) {
    return BusinessMetrics(
      views: views ?? this.views,
    );
  }

  @override
  String toString() {
    return 'BusinessMetrics{views: $views}';
  }

  @override
  bool operator ==(Object other) => identical(this, other) || other is BusinessMetrics && runtimeType == other.runtimeType && views == other.views;

  @override
  int get hashCode => views.hashCode;
}