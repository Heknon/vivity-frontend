import 'dart:collection';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:sizer/sizer.dart';

class ProgressBar extends StatefulWidget {
  final Color activeColor;
  final Color inactiveColor;
  final List<Text> labelsActive;
  final List<Text> labelsInactive;
  final int initialStep;
  final ProgressBarController? controller;

  const ProgressBar({
    required this.activeColor,
    required this.inactiveColor,
    required this.labelsActive,
    required this.labelsInactive,
    this.initialStep = 0,
    this.controller,
  });

  @override
  _ProgressBarState createState() => _ProgressBarState();
}

class _ProgressBarState extends State<ProgressBar> {
  late ProgressBarController _controller;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? ProgressBarController();

    _controller.init(widget.initialStep, widget.activeColor, widget.inactiveColor, widget.labelsActive.length);

    _controller.addListener(() {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    double maxSize = 80.w;
    double indicatorSize = 17;
    double seperatorSize = (maxSize - widget.labelsActive.length * indicatorSize) / (widget.labelsActive.length - 1);

    List<Widget> indicatorBarList = List.generate(
      widget.labelsActive.length,
      (i) {
        Color indicatorColor = _controller.currentStep >= i ? _controller.activeColor : _controller.inactiveColor;
        Color barColor = _controller.currentStep > i ? _controller.activeColor : _controller.inactiveColor;
        Text label = _controller.currentStep >= i ? widget.labelsActive[i] : widget.labelsInactive[i];

        return Positioned(
          left: (indicatorSize + seperatorSize) * i,
          child: buildIndicatorBar(
            indicatorColor,
            barColor,
            label,
            indicatorSize,
            i >= widget.labelsActive.length - 1 ? 0 : seperatorSize,
          ),
        );
      },
    );

    return Align(
      alignment: Alignment.center,
      child: SizedBox(
        width: maxSize,
        height: 50,
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: indicatorBarList,
        ),
      ),
    );
  }

  Widget buildIndicatorBar(Color color, Color barColor, Text label, double indicatorSize, double? barSize) {
    Size labelSize = getLabelSize(label);

    return SizedBox(
      width: indicatorSize + (barSize ?? 0) + labelSize.width,
      height: 50,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          barSize != null
              ? Positioned( // bar
                  left: indicatorSize - 1,
                  top: indicatorSize / 2 - 7 / 2,
                  child: Container(
                    height: 7,
                    width: barSize + 2,
                    color: barColor,
                  ),
                )
              : SizedBox(),
          Positioned( // circle
            left: 0,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color,
              ),
              height: indicatorSize + 2,
              width: indicatorSize + 2,
            ),
          ),
          Positioned(
            child: label,
            left: -labelSize.width / 2 + indicatorSize / 2,
            bottom: 0,
          ),
        ],
      ),
    );
  }

  Size getLabelSize(Text label) {
    return (TextPainter(
            text: TextSpan(text: label.data, style: label.style),
            maxLines: 1,
            textScaleFactor: MediaQuery.of(context).textScaleFactor,
            textDirection: TextDirection.ltr)
          ..layout())
        .size;
  }
}

class ProgressBarController extends ChangeNotifier {
  late int initialStep;
  late Color activeColor;
  late Color inactiveColor;

  late int maxStep;

  late int currentStep;

  void init(int initialStep, Color activeColor, Color inactiveColor, int maxStep) {
    this.initialStep = initialStep;
    this.activeColor = activeColor;
    this.inactiveColor = inactiveColor;
    print(initialStep);
    this.currentStep = initialStep;
    this.maxStep = maxStep;
  }

  void nextStep() {
    if (currentStep + 1 > maxStep) return;
    this.currentStep++;

    notifyListeners();
  }

  void previousStep() {
    if (currentStep - 1 < 0) return;

    this.currentStep--;

    notifyListeners();
  }

  void setStep(int step) {
    if (step > maxStep || step < 0) return;

    this.currentStep = step;

    notifyListeners();
  }
}
