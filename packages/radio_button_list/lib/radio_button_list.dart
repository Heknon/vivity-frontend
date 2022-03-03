import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class RadioButtonList extends StatefulWidget {
  final Color color;
  final List<Widget> labels;
  final int initialSelection;
  final RadioButtonListController? controller;
  final void Function(int)? onChange;

  const RadioButtonList({
    required this.color,
    required this.labels,
    this.initialSelection = 0,
    this.controller,
    this.onChange,
  });

  @override
  _RadioButtonListState createState() => _RadioButtonListState();
}

class _RadioButtonListState extends State<RadioButtonList> {
  late RadioButtonListController _controller;

  @override
  void initState() {
    super.initState();

    _controller = widget.controller ?? RadioButtonListController();
    _controller.init(widget.initialSelection);

    _controller.addListener(() {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    List<Radio> radioButtons = List.generate(
      widget.labels.length,
      (index) => Radio(
        value: index,
        visualDensity: VisualDensity.compact,
        fillColor: MaterialStateProperty.all(widget.color),
        groupValue: _controller.selectedLabel,
        onChanged: (dynamic val) {
          _controller.setSelectedLabel(val);
          if (widget.onChange != null) widget.onChange!(val as int);
        },
      ),
    );

    return Column(
      children: radioButtons.map(
        (e) => Row(
          children: [e, widget.labels[e.value]],
        ),
      ).toList(),
    );
  }
}

class RadioButtonListController extends ChangeNotifier {
  int selectedLabel = 0;

  void init(int initialSelectedLabel) {
    selectedLabel = initialSelectedLabel;
  }

  void setSelectedLabel(int index) {
    selectedLabel = index;
    notifyListeners();
  }
}
