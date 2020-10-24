import 'package:flutter/material.dart';

class CheckboxList<T> extends StatefulWidget {
  CheckboxList({
    this.options,
    this.selectedValues,
    this.onChanged,
  });

  final List<CheckboxListOption> options;
  final List<T> selectedValues;
  final ValueChanged<List<T>> onChanged;

  @override
  CheckboxListState createState() => CheckboxListState();
}

class CheckboxListState extends State<CheckboxList> {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        itemCount: widget.options.length,
        itemBuilder: (BuildContext context, int index) {
          final item = widget.options[index];
          return CheckboxListTile(
              title: Text(item.label),
              value: widget.selectedValues.contains(item.value),
              onChanged: (bool value) {
                if (value) {
                  if (!widget.selectedValues.contains(item.value)) {
                    setState(() {
                      widget.selectedValues.add(item.value);
                    });
                  }
                } else {
                  if (widget.selectedValues.contains(item.value)) {
                    setState(() {
                      widget.selectedValues.removeWhere((e) => e == item.value);
                    });
                  }
                }
                widget.onChanged(widget.selectedValues);
              });
        });
  }
}

class CheckboxListOption<T> {
  final T value;
  final String label;

  CheckboxListOption({
    @required this.value,
    @required this.label,
  });

  static List<CheckboxListOption<R>> listFrom<R, E>(
          {@required List<E> source,
          @required _CheckboxListOptionProp<E, R> value,
          @required _CheckboxListOptionProp<E, String> label}) =>
      source
          .asMap()
          .map((index, item) => MapEntry(
              index,
              CheckboxListOption<R>(
                value: value?.call(index, item),
                label: label?.call(index, item),
              )))
          .values
          .toList()
          .cast<CheckboxListOption<R>>();
}

typedef R _CheckboxListOptionProp<T, R>(int index, T item);
