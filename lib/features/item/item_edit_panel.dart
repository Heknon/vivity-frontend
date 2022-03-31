import 'package:advanced_panel/panel.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:vivity/config/themes/themes_config.dart';
import 'package:vivity/features/item/ui_item_helper.dart';
import 'package:vivity/helpers/ui_helpers.dart';

import 'models/item_model.dart';

class ItemEditPanel extends StatelessWidget {
  final ItemModel item;
  final PanelController panelController;

  const ItemEditPanel({
    Key? key,
    required this.item,
    required this.panelController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (ctx, constraints) {
        Size tabSize = Size(constraints.maxWidth, constraints.maxWidth * 0.2);
        Size itemViewSize = Size(tabSize.width, constraints.maxHeight * 0.83 - tabSize.height);

        return ConstrainedBox(
          child: SlidingUpPanel(
            controller: panelController,
            panelSize: tabSize.height,
            contentSize: itemViewSize.height + tabSize.height,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(18.0),
              topRight: Radius.circular(18.0),
            ),
            backdropEnabled: true,
            panel: buildTab(
              Text(
                item.itemStoreFormat.title,
                style: Theme.of(context).textTheme.headline4?.copyWith(color: fillerColor, fontSize: 24.sp, fontWeight: FontWeight.bold),
              ),
              tabSize,
              constraints,
            ),
            contentBuilder: (sc) => buildContent(context, itemViewSize, constraints, sc),
            //parallaxEnabled: true,
          ),
          constraints: constraints,
        );
      },
    );
  }

  Widget buildContent(BuildContext context, Size itemViewSize, BoxConstraints constraints, ScrollController sc) {
    Color offWhite = const Color(0xff737373);
    List<String> titles = ["Price", "Subtitle", "Tags", "Brand", "Category"];
    List<String> dataStrings = [
      '\$${item.price.toStringAsFixed(2)} USD',
      item.itemStoreFormat.subtitle ?? 'N/A',
      item.tags.join(', '),
      item.brand,
      item.category
    ];
    List<Widget> titleWidgets = List.empty(growable: true);
    List<Widget> dataWidgets = List.empty(growable: true);
    const baseSpace = 60;
    SizedBox spaceTitle = SizedBox(height: baseSpace - 14.sp);
    SizedBox spaceData = SizedBox(height: baseSpace - 18.5.sp);

    for (int i = 0; i < titles.length * 2 - 1; i++) {
      if (i.isOdd) {
        titleWidgets.add(spaceTitle);
        dataWidgets.add(spaceData);
        continue;
      }

      String title = titles[i ~/ 2];
      String data = dataStrings[i ~/ 2];
      titleWidgets.add(buildTitleText(title, context));
      dataWidgets.add(buildDataText(data, context));
    }

    return Positioned(
      bottom: 1,
      width: itemViewSize.width,
      child: SingleChildScrollView(
        child: Container(
          color: Colors.white,
          height: itemViewSize.height,
          child: Padding(
            padding: const EdgeInsets.only(left: 25, right: 8, top: 15, bottom: 10),
            child: Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: titleWidgets,
                ),
                SizedBox(width: 20.w),
                SizedBox(
                  width: 50.w,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: dataWidgets,
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildTitleText(String title, BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.subtitle1?.copyWith(fontSize: 14.sp),
    );
  }

  Widget buildDataText(String data, BuildContext context) {
    Text text = Text(
      data,
      overflow: TextOverflow.ellipsis,
      maxLines: 1,
      style: Theme.of(context).textTheme.headline4?.copyWith(fontSize: 16.5.sp, fontWeight: FontWeight.normal),
    );

    return TextButton(
      style: ButtonStyle(
        padding: MaterialStateProperty.all(EdgeInsets.zero),
        visualDensity: VisualDensity.compact,
        fixedSize: MaterialStateProperty.all(getTextSize(text)),
        alignment: Alignment.topLeft,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      onPressed: () {},
      child: text,
    );
  }
}
