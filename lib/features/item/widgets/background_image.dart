import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/widgets.dart';

class BackgroundImage extends StatelessWidget {
  final String imageUrl;
  final Color backgroundColor;

  const BackgroundImage({
    Key? key,
    required this.imageUrl,
    required this.backgroundColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (ctx, constraints) => Stack(
        alignment: Alignment.center,
        children: [
          Container(
            color: const Color(0xfff8f1f1),
            width: constraints.maxWidth,
            height: constraints.maxHeight * 0.7,
          ),
          SizedBox(
            width: constraints.maxWidth * 0.9,
            height: constraints.maxHeight * 0.7 * 0.9,
            child: CachedNetworkImage(
              imageUrl: imageUrl,
            ),
          ),
        ],
      ),
    );
  }
}
