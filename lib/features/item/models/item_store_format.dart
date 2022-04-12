import 'package:vivity/features/item/models/modification_button.dart';

class ItemStoreFormat {
  final String title;
  final String? subtitle;
  final String? description;
  final List<ModificationButton> modificationButtons;

  ItemStoreFormat({required this.title, this.subtitle, this.description, this.modificationButtons = const []}) {
    modificationButtons.sort((a, b) => a.side.index.compareTo(b.side.index));
  }

  @override
  String toString() {
    return 'ItemStoreFormat{title: $title, subtitle: $subtitle, description: $description, modificationButtons: $modificationButtons}';
  }

  ItemStoreFormat copyWith({
    String? title,
    String? subtitle,
    String? description,
    List<ModificationButton>? modificationButtons,
  }) {
    List<ModificationButton> modButtons = modificationButtons ?? this.modificationButtons.map((e) => e.copyWith()).toList();
    modButtons.sort((a, b) => a.side.index.compareTo(b.side.index));

    return ItemStoreFormat(
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      description: description ?? this.description,
      modificationButtons: modificationButtons ?? this.modificationButtons.map((e) => e.copyWith()).toList(),
    );
  }

  factory ItemStoreFormat.fromMap(Map<String, dynamic> map) {
    List<ModificationButton> modButtons = (map['modification_buttons'] as List<dynamic>).map((e) => ModificationButton.fromMap(e)).toList();
    modButtons.sort((a, b) => a.side.index.compareTo(b.side.index));

    return ItemStoreFormat(
      title: map['title'] as String,
      subtitle: map['subtitle'] as String?,
      description: map['description'] as String?,
      modificationButtons: modButtons,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'subtitle': subtitle,
      'description': description,
      'modification_buttons': modificationButtons.map((e) => e.toMap()).toList(),
    };
  }
}
