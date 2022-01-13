import 'package:flutter/material.dart';
import 'package:vivity/modules/user/screens/feed.dart';
import 'package:vivity/widgets/appbar/appbar.dart';

import 'explore.dart';

class HomePage extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: VivityAppBar(
          bottom: const TabBar(
            tabs: [Tab(text: "Feed"), Tab(text: "Explore")],
            indicatorColor: Colors.white,
          ),
        ),
        body: TabBarView(
          physics: const NeverScrollableScrollPhysics(),
          children: [
            Feed(),
            Explore(),
          ],
        ),
      ),
    );
  }
}