import 'package:objectid/objectid/objectid.dart';

class Review {
  final ObjectId posterId;
  final String posterName;
  final String pfpImage;
  final double rating;
  final String textContent;
  final List<String> images;

  const Review({
    required this.posterId,
    required this.posterName,
    required this.pfpImage,
    required this.rating,
    required this.textContent,
    required this.images,
  });

  @override
  String toString() {
    return 'Review{posterName: $posterName, pfpImage: $pfpImage, rating: $rating, textContent: $textContent, imageUrls: $images}';
  }

  Review copyWith({
    ObjectId? posterId,
    String? posterName,
    String? pfpImage,
    double? rating,
    String? textContent,
    List<String>? images,
  }) {
    return Review(
      posterId: posterId ?? this.posterId,
      posterName: posterName ?? this.posterName,
      pfpImage: pfpImage ?? this.pfpImage,
      rating: rating ?? this.rating,
      textContent: textContent ?? this.textContent,
      images: images ?? this.images,
    );
  }

  factory Review.fromMap(Map<String, dynamic> map) {
    return Review(
      posterId: ObjectId.fromHexString(map["poster_id"]),
      posterName: map['poster_name'] as String,
      pfpImage: map['pfp_image'] as String,
      rating: (map['rating'] as num).toDouble(),
      textContent: map['text_content'] as String,
      images: (map['images'] as List<dynamic>).map((e) => e as String).toList(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'poster_id': posterId,
      'poster_name': posterName,
      'pfp_image': pfpImage,
      'rating': rating,
      'text_content': textContent,
      'images': images,
    };
  }
}