import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_options.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:sizer/sizer.dart';

class Carousel extends StatefulWidget {
  final List<String> imageUrls;

  /// Scaling is applied to size. Sizes are a percentage of the screen.
  final Size imageSize;
  final int initialPage;
  final Color activeColor;
  final Color inactiveColor;

  final double topLeftRadius;
  final double topRightRadius;
  final double bottomRightRadius;
  final double bottomLeftRadius;

  Carousel({
    Key? key,
    this.topRightRadius = 0,
    this.topLeftRadius = 0,
    this.bottomLeftRadius = 0,
    this.bottomRightRadius = 0,
    this.imageSize = const Size(70, 50),
    this.initialPage = 0,
    this.activeColor = const Color(0xff18112d),
    this.inactiveColor = Colors.grey,
    required this.imageUrls,
  }) : super(key: key);

  @override
  State<Carousel> createState() => _CarouselState();
}

class _CarouselState extends State<Carousel> {
  final CarouselController _carouselController = CarouselController();
  late int _currentPage;

  @override
  void initState() {
    super.initState();
    _currentPage = widget.initialPage;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: widget.imageSize.width.w,
          height: widget.imageSize.height.h,
          child: CarouselSlider(
            carouselController: _carouselController,
            options: CarouselOptions(
                height: widget.imageSize.height.h,
                initialPage: widget.initialPage,
                enableInfiniteScroll: false,
                viewportFraction: 2,
                reverse: false,
                onPageChanged: (pageIndex, _) => setState(() => _currentPage = pageIndex)),
            items: widget.imageUrls
                .map(
                  (e) => ClipRRect(
                    borderRadius: BorderRadius.only(
                      bottomRight: Radius.circular(widget.bottomRightRadius),
                      bottomLeft: Radius.circular(widget.bottomLeftRadius),
                      topLeft: Radius.circular(widget.topLeftRadius),
                      topRight: Radius.circular(widget.topRightRadius),
                    ),
                    child: Container(
                      color: Colors.white,
                      child: CachedNetworkImage(
                        imageUrl: e,
                        imageBuilder: (ctx, prov) => Image(
                          alignment: Alignment.topCenter,
                          fit: BoxFit.fitHeight,
                          width: widget.imageSize.width.w,
                          height: widget.imageSize.height.h,
                          image: prov,
                        ),
                      ),
                    ),
                  ),
                )
                .toList(growable: false),
          ),
        ),
        Container(
          width: (8.sp + 5) * widget.imageUrls.length,
          padding: EdgeInsets.only(top: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(
              widget.imageUrls.length,
              (index) => Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _currentPage == index ? widget.activeColor : widget.inactiveColor,
                ),
                width: 8.sp,
                height: 8.sp,
              ),
            ),
          ),
        )
      ],
    );
  }
}
