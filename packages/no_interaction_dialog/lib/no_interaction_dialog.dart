import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class NoInteractionDialog extends StatefulWidget {
  final NoInteractionDialogController? controller;
  final Widget child;

  const NoInteractionDialog({this.controller, required this.child,});

  @override
  State<NoInteractionDialog> createState() => _NoInteractionDialogState();
}

class _NoInteractionDialogState extends State<NoInteractionDialog> {
  late final NoInteractionDialogController _controller;

  @override
  void initState() {
    super.initState();

    _controller = widget.controller ?? NoInteractionDialogController(child: widget.child);
    _controller.child = widget.child;
    _controller.addListener(() {
      if (mounted) setState(() {

      });
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => _controller.canPop,
      child: AlertDialog(
        content: _controller.child,
      ),
    );
  }
}

class NoInteractionDialogController extends ChangeNotifier {
  late bool isOpen;
  late bool canPop;
  late Widget? child;

  bool get isClosed => !isOpen;

  NoInteractionDialogController({this.isOpen = true, this.canPop = false, this.child});

  void toggle() {
    isOpen = !isOpen;
    notifyListeners();
  }

  void close() {
    isOpen = false;
    notifyListeners();
  }

  void open() {
    isOpen = true;
    notifyListeners();
  }

  void setCanPop(bool canPop) {
    this.canPop = canPop;
    notifyListeners();
  }

  void swapChild(Widget child) {
    this.child = child;
    notifyListeners();
  }
}


