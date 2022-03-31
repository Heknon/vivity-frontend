import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class LikeButton extends StatefulWidget {
  final LikeButtonController? controller;
  final Color? color;
  final Color? splashColor;
  final Color? backgroundColor;
  final void Function(bool liked)? onClick;
  final bool initialLiked;
  final double? radius;
  final BorderRadius? borderRadius;
  final EdgeInsets? padding;

  const LikeButton({
    Key? key,
    this.controller,
    this.color = Colors.white,
    this.splashColor,
    this.onClick,
    this.initialLiked = false,
    this.backgroundColor,
    this.radius,
    this.borderRadius,
    this.padding,
  }) : super(key: key);

  @override
  _LikeButtonState createState() => _LikeButtonState();
}

class _LikeButtonState extends State<LikeButton> {
  late LikeButtonController _controller;

  late Widget _likedSvg;
  late Widget _notLikedSvg;

  @override
  void initState() {
    super.initState();

    _likedSvg = Icon(
      Icons.favorite,
      color: widget.color,
    );

    _notLikedSvg = Icon(
      Icons.favorite_border,
      color: widget.color,
    );

    _controller = widget.controller ?? LikeButtonController();
    _controller.liked = widget.initialLiked;
    _controller.addListener(() {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: widget.backgroundColor ?? Theme.of(context).primaryColor,
      child: InkWell(
        borderRadius: widget.borderRadius,
        radius: widget.radius,
        splashFactory: InkRipple.splashFactory,
        overlayColor: MaterialStateProperty.all(widget.splashColor ?? Colors.white.withOpacity(0.6)),
        splashColor: widget.splashColor ?? Colors.white.withOpacity(0.6),
        onTap: () {
          _controller.toggleLike();
          if (widget.onClick != null) {
            widget.onClick!(_controller.liked);
          }
        },
        child: Padding(
          padding: widget.padding ?? EdgeInsets.zero,
          child: _controller.liked ? _likedSvg : _notLikedSvg,
        ),
      ),
    );
  }
}

class LikeButtonController extends ChangeNotifier {
  bool liked;

  LikeButtonController({this.liked = false});

  void setLiked(bool liked) {
    this.liked = liked;
    notifyListeners();
  }

  void toggleLike() {
    liked = !liked;
    notifyListeners();
  }
}
