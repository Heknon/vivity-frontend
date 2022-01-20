import 'package:flutter/widgets.dart';

class AutoScroll extends StatefulWidget {
  final Widget child;
  final Axis axis;

  const AutoScroll({Key? key, required this.child, this.axis = Axis.horizontal}) : super(key: key);

  @override
  _AutoScrollState createState() => _AutoScrollState();
}

class _AutoScrollState extends State<AutoScroll> with SingleTickerProviderStateMixin {
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();

    _scrollController = ScrollController();
  }

  @override
  Widget build(BuildContext context) {
    animate();
    return SingleChildScrollView(
      scrollDirection: widget.axis,
      controller: _scrollController,
      child: widget.child,
    );
  }

  void animate() {
    _scrollController.animateTo(100, duration: Duration(seconds: 2), curve: Curves.linear).whenComplete(() => animate());
  }
}
