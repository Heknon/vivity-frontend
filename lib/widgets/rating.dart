import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import 'package:vivity/features/item/models/item_model.dart';

class Rating extends StatelessWidget {
  final double rating;
  final Color color;
  final double fontSize;

  const Rating({Key? key, required this.rating, this.color = Colors.black, this.fontSize = 10})
      : assert(rating >= 0 && rating <= 5),
        super(key: key);

  factory Rating.fromReviews(Iterable<Review> reviews, {Color color = Colors.black, double fontSize = 10}) {
    double sum = 0;
    double length = 0;

    for (var element in reviews) {
      length += 1;
      sum += element.rating;
    }

    return Rating(rating: sum / length, color: color, fontSize: fontSize,);
  }

  @override
  Widget build(BuildContext context) {
    double ratingStr = double.parse(rating.toStringAsFixed(2));

    return Row(
      children: [
        SvgPicture.asset(
          "assets/icons/star.svg",
          color: Theme.of(context).colorScheme.primaryVariant,
          height: 11.sp,
        ),
        Padding(
          padding: const EdgeInsets.only(left: 3.0),
          child: Text(
            ratingStr.toString(),
            style: GoogleFonts.roboto(fontWeight: FontWeight.w500, fontSize: 12.sp).copyWith(color: color),
          ),
        )
      ],
    );
  }
}
