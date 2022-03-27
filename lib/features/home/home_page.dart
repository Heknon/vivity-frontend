import 'package:flutter/material.dart';
import 'package:vivity/features/base_page.dart';
import 'package:vivity/features/drawer/vivity_drawer.dart';
import 'package:vivity/widgets/appbar/appbar.dart';
import '../explore/explore.dart';
import 'feed/feed.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: BasePage(
        appBar: VivityAppBar(
          bottom: const TabBar(
            tabs: [
              Tab(text: "Explore"),
              Tab(text: "Feed"),
            ],
            indicatorColor: Colors.white,
          ),
        ),
        body: TabBarView(
          physics: const NeverScrollableScrollPhysics(),
          children: [
            Explore(),
            Feed(),
          ],
        ),
      ),
    );
  }
}
