import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sizer/sizer.dart';
import 'package:vivity/features/item/models/modification_button_data_type.dart';
import 'package:vivity/features/item/modifier/bloc/item_modifier_bloc.dart';

import 'item_modifier_service.dart';

class ItemModifierContainer extends StatefulWidget {
  final String name;
  final List<Object> selectableData;
  final ModificationButtonDataType dataType;

  final double sizeScale;

  const ItemModifierContainer({
    Key? key,
    required this.selectableData,
    required this.dataType,
    required this.name,
    this.sizeScale = 9,
  }) : super(key: key);

  @override
  State<ItemModifierContainer> createState() => _ItemModifierContainerState();
}

class _ItemModifierContainerState extends State<ItemModifierContainer> {
  Size get _widgetSize => Size(widget.sizeScale.h, widget.sizeScale.h);

  List<Object> _getSelectedData(Set<int> indices) {
    int index = 0;
    List<Object> selected = List.empty(growable: true);

    for (var element in widget.selectableData) {
      if (indices.contains(index)) selected.add(element);
      index++;
    }

    return selected;
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size size = _widgetSize;

    return Material(
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(15))),
      color: Colors.white,
      clipBehavior: Clip.antiAlias,
      elevation: 7,
      child: SizedBox(
        width: size.width,
        height: size.height,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              flex: 2,
              child: Container(
                width: size.width,
                padding: const EdgeInsets.only(top: 7),
                child: BlocBuilder(
                  bloc: BlocProvider.of<ItemModifierBloc>(context),
                  builder: (ctx, ItemModifierState state) => SingleChildScrollView(
                    child: Wrap(
                      alignment: WrapAlignment.center,
                      direction: Axis.horizontal,
                      runSpacing: 10,
                      spacing: 10,
                      children: state.chosenIndices.isNotEmpty
                          ? buildSelectionList(
                              context,
                              widget.dataType,
                              _getSelectedData(state.chosenIndices),
                              includeInkWell: true,
                            )
                          : [
                              Text(
                                'N/A',
                                style: Theme.of(context).textTheme.headline4!.copyWith(fontSize: 16.sp),
                              )
                            ],
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                widget.name,
                overflow: TextOverflow.clip,
                maxLines: 1,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headline4!.copyWith(fontSize: 13.sp),
              ),
            )
          ],
        ),
      ),
    );
  }
}
