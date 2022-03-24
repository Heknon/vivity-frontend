import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class LikeButton extends StatefulWidget {
  final LikeButtonController? controller;
  final Color? color;
  final void Function(bool liked)? onClick;

  const LikeButton({Key? key, this.controller, this.color = Colors.white, this.onClick}) : super(key: key);

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
    _controller.addListener(() {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _controller.toggleLike();
        if (widget.onClick != null) {
          widget.onClick!(_controller.liked);
        }
      },
      child: _controller.liked ? _likedSvg : _notLikedSvg,
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
