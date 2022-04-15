extension ListUtils<T> on List<T> {
  T? getOrNull(int index) {
    if (index < 0 || index >= this.length) {
      return null;
    }

    try {
      return this.elementAt(index);
    } on RangeError catch (e) {
      return null;
    }
  }
}
