import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vivity/features/item/models/item_model.dart';


class Rating extends StatelessWidget {
  final double rating;

  const Rating({Key? key, required this.rating})
      : assert(rating >= 0 && rating <= 5),
        super(key: key);

  factory Rating.fromReviews(Iterable<Review> reviews) {
    double sum = 0;
    double length = 0;

    for (var element in reviews) {
      length += 1;
      sum += element.rating;
    }

    return Rating(rating: sum / length);
  }

  @override
  Widget build(BuildContext context) {
    double ratingStr = double.parse(rating.toStringAsFixed(2));

    return Row(
      children: [
        SvgPicture.asset(
          "assets/icons/star.svg",
          color: Theme.of(context).colorScheme.primaryVariant,
          width: 12,
        ),
        Padding(
          padding: const EdgeInsets.only(left: 3.0, top: 2),
          child: Text(ratingStr.toString(), style: GoogleFonts.roboto(fontWeight: FontWeight.w500),),
        )
      ],
    );
  }
}
