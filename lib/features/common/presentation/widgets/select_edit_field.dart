import 'package:flutter/material.dart';
import 'package:searchable_dropdown/searchable_dropdown.dart';

// ignore: must_be_immutable
class SelectEditField<T> extends StatefulWidget {
  SelectEditField({
    Key key,
    @required this.label,
    @required this.labelColor,
    @required this.valueColor,
    @required this.value,
    @required this.items,
    @required this.searchFn,
    @required this.onChange,
    this.enabled = true,
  }) : super(key: key);

  final String label;
  final Color labelColor;
  final Color valueColor;
  final ValueChanged<T> onChange;
  T value;
  bool enabled;
  List<DropdownMenuItem> items;
  Function searchFn;

  @override
  State<StatefulWidget> createState() => _SelectEditFieldState();
}

class _SelectEditFieldState extends State<SelectEditField> {
  dynamic selectedValue;
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 90,
      width: MediaQuery.of(context).size.width,
      child: SearchableDropdown.single(
        readOnly: !widget.enabled,
        items: widget.items,
        value: widget.value,
        hint: 'Select one',
        searchHint: 'Select one',
        label: Text(
          widget.label,
          style: TextStyle(color: widget.labelColor, fontSize: 16),
        ),
        style: TextStyle(color: Colors.black, fontSize: 16),
        onChanged: (value) {
          selectedValue = value;
          widget.onChange(selectedValue);
        },
        isExpanded: true,
        searchFn: (String keyword, items) {
          return widget.searchFn(keyword, items);
        },
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    setState(() {
      selectedValue = widget.value;
    });
  }
}
