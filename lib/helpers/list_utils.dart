extension ListUtils<T> on List<T?> {
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

  List<T> removeNull() {
    List<T> newList = List.empty(growable: true);

    for (T? element in this) {
      if (element != null) newList.add(element);
    }

    return newList;
  }

  List<T> safeIndexEdit(
    int index, {
    required T? Function(T) edit,
  }) {
    List<T> newItems = List.empty(growable: true);
    for (int i = 0; i < this.length; i++) {
      T? elem = this[i];

      if (i == index) {
        T? newItem = elem != null ? edit(elem) : null;
        if (newItem != null) newItems.add(newItem);
      } else if (elem != null) {
        newItems.add(elem);
      }
    }

    return newItems;
  }
}
