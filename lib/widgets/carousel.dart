import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_options.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:sizer/sizer.dart';

class Carousel extends StatefulWidget {
  final List<File> images;

  /// Scaling is applied to size. Sizes are a percentage of the screen.
  final Size imageSize;
  final int initialPage;
  final Color activeColor;
  final Color inactiveColor;

  final double topLeftRadius;
  final double topRightRadius;
  final double bottomRightRadius;
  final double bottomLeftRadius;

  final void Function(int)? onImageTap;

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
    required this.images,
    this.onImageTap,
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
    List<Image> images = widget.images.map((e) => Image.file(
      e,
      alignment: Alignment.topCenter,
      fit: BoxFit.fitHeight,
      width: widget.imageSize.width,
      height: widget.imageSize.height,
    )).toList();

    List<Widget> items = List.empty(growable: true);
    images.add(Image.asset(
      "assets/images/addImage.png",
      alignment: Alignment.topCenter,
      fit: BoxFit.scaleDown,
      width: widget.imageSize.width,
      height: widget.imageSize.height,
    ));

    int index = 0;
    for (var image in images) {
      final currentIndex = index;
      items.add(InkWell(
        onTap: () => widget.onImageTap != null ? widget.onImageTap!(currentIndex) : null,
        child: ClipRRect(
          borderRadius: BorderRadius.only(
            bottomRight: Radius.circular(widget.bottomRightRadius),
            bottomLeft: Radius.circular(widget.bottomLeftRadius),
            topLeft: Radius.circular(widget.topLeftRadius),
            topRight: Radius.circular(widget.topRightRadius),
          ),
          child: Container(
            color: Colors.white,
            child: image,
          ),
        ),
      ));
      index++;
    }

    return Column(
      children: [
        SizedBox(
          width: widget.imageSize.width,
          height: widget.imageSize.height,
          child: CarouselSlider(
            carouselController: _carouselController,
            options: CarouselOptions(
                height: widget.imageSize.height,
                initialPage: widget.initialPage,
                enableInfiniteScroll: false,
                viewportFraction: 2,
                reverse: false,
                onPageChanged: (pageIndex, _) => setState(() => _currentPage = pageIndex)),
            items: items,
          ),
        ),
        Container(
          width: (8.sp + 5) * items.length,
          padding: EdgeInsets.only(top: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(
              items.length,
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
