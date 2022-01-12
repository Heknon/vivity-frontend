import 'package:flutter/cupertino.dart';

class TabBarData {
  const TabBarData({this.tabs, this.child, this.body});

  final List<TabBarData>? tabs;
  final Widget? child;
  final Widget? body;
}