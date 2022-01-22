import 'package:flutter/material.dart';
import 'package:vivity/widgets/appbar/appbar.dart';
import 'feed/feed.dart';

import 'explore/explore.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        resizeToAvoidBottomInset: false,
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
