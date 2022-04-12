class ItemMetrics {
  final int views;
  final int orders;
  final int likes;

  ItemMetrics({
    required this.views,
    required this.orders,
    required this.likes,
  });

  ItemMetrics copyWith({
    int? views,
    int? orders,
    int? likes,
  }) {
    if ((views == null || identical(views, this.views)) &&
        (orders == null || identical(orders, this.orders)) &&
        (likes == null || identical(likes, this.likes))) {
      return this;
    }

    return ItemMetrics(
      views: views ?? this.views,
      orders: orders ?? this.orders,
      likes: likes ?? this.likes,
    );
  }

  factory ItemMetrics.fromMap(Map<String, dynamic> map) {
    return ItemMetrics(
      views: (map['views'] as num).toInt(),
      orders: (map['orders'] as num).toInt(),
      likes: (map['likes'] as num).toInt(),
    );
  }

  Map<String, dynamic> toMap() {
    // ignore: unnecessary_cast
    return {
      'views': views,
      'orders': orders,
      'likes': likes,
    } as Map<String, dynamic>;
  }

  @override
  String toString() {
    return 'ItemMetrics{views: $views, orders: $orders, likes: $likes}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is ItemMetrics && runtimeType == other.runtimeType && views == other.views && orders == other.orders && likes == other.likes;

  @override
  int get hashCode => views.hashCode ^ orders.hashCode ^ likes.hashCode;
}
