import 'package:chips_choice/chips_choice.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// ignore: must_be_immutable
class ChoiceChipGroupSelection<T> extends StatefulWidget {
  final Function onChange;
  final Function groupLabel;
  List initialValue;
  final List<ChoiceChipGroupSelectionOption<T>> choiceChipOptions;
  final List<dynamic> groupList;
  final Function labelToValue;
  final int maxSelection;

  ChoiceChipGroupSelection(
      {Key key,
      this.onChange,
      this.initialValue,
      this.choiceChipOptions,
      this.groupLabel,
      this.labelToValue,
      this.groupList,
      this.maxSelection})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _ChoiceChipGroupSelectionPage();
}

class _ChoiceChipGroupSelectionPage<T> extends State<ChoiceChipGroupSelection> {
  Map<dynamic, List<ChoiceChipGroupSelectionOption<T>>>
      choiceChipOptionsGrouped;
  List<dynamic> choiceChipOptionsGroupedKeys = [];
  Map<dynamic, List<T>> selectedOptionsGrouped;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: widget.groupList.length,
      itemBuilder: (context, index) {
        final groupKey = widget.groupList[index];
        return Column(
          children: [
            ExpansionTile(
              title: Container(
                child: Text(
                  widget.groupLabel(groupKey),
                ),
              ),
              initiallyExpanded: true,
              children: [
                Container(
                  color: Theme.of(context).primaryColor.withOpacity(0.05),
                  alignment: Alignment.centerLeft,
                  child: ChipsChoice<T>.multiple(
                    itemConfig: ChipsChoiceItemConfig(),
                    value: selectedOptionsGrouped[groupKey] ?? [],
                    options: ChipsChoiceOption.listFrom<T,
                        ChoiceChipGroupSelectionOption>(
                      disabled: (index, item) =>
                          widget.maxSelection != null &&
                          widget.maxSelection ==
                              (widget.initialValue ?? []).length &&
                          !widget.initialValue.contains(item.value),
                      source: choiceChipOptionsGrouped[groupKey] ?? [],
                      value: (i, v) => v.value,
                      label: (i, v) => v.label,
                    ),
                    onChanged: (List<T> value) {
                      setState(() {
                        selectedOptionsGrouped[groupKey] = List<T>.from(value);
                        final List<T> selectedValues = selectedOptionsGrouped
                            .values
                            .expand((element) => element)
                            .toList();
                        widget.initialValue = selectedValues;
                        widget.onChange(selectedValues);
                      });
                    },
                    isWrapped: true,
                  ),
                ),
              ],
            ),
            Divider(
              height: 0,
              color: Colors.black.withOpacity(0.5),
            )
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    choiceChipOptionsGrouped = Map.fromEntries(widget.choiceChipOptions
        .map((option) => option.group)
        .toList()
        .toSet()
        .toList()
        .map((group) =>
            MapEntry<dynamic, List<ChoiceChipGroupSelectionOption<T>>>(
                group,
                widget.choiceChipOptions
                    .where((element) => element.group == group)
                    .toList())));
    selectedOptionsGrouped = Map.fromEntries(widget.choiceChipOptions
        .map((option) => option.group)
        .toList()
        .toSet()
        .toList()
        .map((group) => MapEntry<dynamic, List<T>>(
            group,
            widget.choiceChipOptions
                .where((element) =>
                    element.group == group &&
                    widget.initialValue.contains(element.value))
                .map((e) => e.value)
                .toList())));
    choiceChipOptionsGroupedKeys = choiceChipOptionsGrouped.keys.toList();
  }
}

class ChoiceChipGroupSelectionOption<T> {
  final T value;
  final String label;
  final dynamic group;

  ChoiceChipGroupSelectionOption({
    @required this.value,
    @required this.label,
    @required this.group,
  });

  static List<ChoiceChipGroupSelectionOption<R>> listFrom<R, E>({
    @required List<E> source,
    @required _ChoiceChipGroupSelectionOptionProp<E, R> value,
    @required _ChoiceChipGroupSelectionOptionProp<E, String> label,
    @required _ChoiceChipGroupSelectionOptionProp<E, dynamic> group,
  }) =>
      source
          .asMap()
          .map((index, item) => MapEntry(
              index,
              ChoiceChipGroupSelectionOption<R>(
                value: value?.call(index, item),
                label: label?.call(index, item),
                group: group?.call(index, item),
              )))
          .values
          .toList()
          .cast<ChoiceChipGroupSelectionOption<R>>();
}

typedef R _ChoiceChipGroupSelectionOptionProp<T, R>(int index, T item);
