import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:vivity/widgets/tabbar/models/tab_bar_data.dart';

class LayeredTabBar extends StatefulWidget {
  const LayeredTabBar({Key? key, required this.rootTabs}) : super(key: key);

  final List<TabBarData> rootTabs;

  @override
  _LayeredTabBarState createState() => _LayeredTabBarState();
}

class _LayeredTabBarState extends State<LayeredTabBar> with TickerProviderStateMixin {
  late TabController _tabController;
  late List<TabController?> layerControllers;

  late List<Tab> rootTabs;
  late List<List<Tab>> subTabs;

  late TabBar mainTabBar;

  late int currentIndex;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: widget.rootTabs.length, vsync: this);
    currentIndex = _tabController.index;

    layerControllers = widget.rootTabs.map((tabData) => tabData.tabs != null ? TabController(length: tabData.tabs?.length ?? 0, vsync: this) : null).toList();

    rootTabs = widget.rootTabs.map((tabData) => Tab(child: tabData.child ?? const Text("N/A"))).toList();
    subTabs = widget.rootTabs.map((tabDataList) => tabDataList.tabs!.map((tabData) => Tab(child: tabData.child ?? const Text("N/A"))).toList()).toList();

    assert(subTabs.length == rootTabs.length, "There must exist a sub tab for each root tab.");

    mainTabBar = TabBar(
      tabs: rootTabs,
      controller: _tabController,
      onTap: (index) => setState(() => currentIndex = index),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();

    for (TabController? tabController in layerControllers) {
      tabController?.dispose();
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    TabBar subTabBar = TabBar(
      tabs: subTabs[_tabController.index],
      controller: layerControllers[_tabController.index],
    );

    double contentSpaceHeight =
        MediaQuery.of(context).size.height - (Scaffold.of(context).appBarMaxHeight ?? 0) - mainTabBar.preferredSize.height - subTabBar.preferredSize.height;

    return Column(
      children: [
        Column(
          children: [mainTabBar, Material(elevation: 7, color: Theme.of(context).primaryColor, child: subTabBar)],
        ),
        SizedBox(
          height: contentSpaceHeight,
          child: TabBarView(
              controller: layerControllers[_tabController.index],
              children: widget.rootTabs[_tabController.index].tabs!.where((element) => element.body != null).map((tabData) => tabData.body!).toList()),
        )
      ],
    );
  }
}
