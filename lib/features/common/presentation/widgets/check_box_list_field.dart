import 'package:flutter/material.dart';
import 'package:mood_manager/features/metadata/domain/entities/gender.dart';
import 'package:mood_manager/features/common/presentation/widgets/checkbox_list.dart';
import 'package:mood_manager/home.dart';

// ignore: must_be_immutable
class CheckboxSelectBottomSheet extends StatefulWidget {
  CheckboxSelectBottomSheet({
    Key key,
    @required this.label,
    @required this.labelColor,
    @required this.valueColor,
    @required this.values,
    @required this.onChange,
    @required this.options,
    @required this.inputDecoration,
  }) : super(key: key);

  List<Gender> values;
  final String label;
  final Color labelColor;
  final Color valueColor;
  final ValueChanged<List<Gender>> onChange;
  final List<Gender> options;
  final InputDecoration inputDecoration;

  @override
  State<StatefulWidget> createState() => _CheckboxSelectBottomSheetState();
}

class _CheckboxSelectBottomSheetState extends State<CheckboxSelectBottomSheet> {
  TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 65,
      width: MediaQuery.of(context).size.width,
      child: InkWell(
        onTap: () {
          _selectOption(context);
        },
        child: IgnorePointer(
          child: TextField(
            controller: controller,
            onTap: () {
              FocusScope.of(context).requestFocus(new FocusNode());
            },
            style: TextStyle(color: widget.valueColor, fontSize: 16),
            decoration: widget.inputDecoration,
          ),
        ),
      ),
    );
  }

  Future<void> _selectOption(BuildContext context) async {
    showModalBottomSheet(
        context: appNavigatorContext(context),
        builder: (context) {
          return Container(
            height: 60.0 * widget.options.length,
            child: CheckboxList(
              onChanged: (value) {
                widget.onChange(value);
                controller.text =
                    widget.values.map((e) => e.altName).join(', ');
              },
              options: CheckboxListOption.listFrom<Gender, Gender>(
                source: widget.options,
                value: (i, v) => v,
                label: (i, v) => v.altName,
              ),
              selectedValues: widget.values,
            ),
          );
        });
  }

  @override
  void initState() {
    super.initState();
    controller = TextEditingController(
        text: widget.values.map((e) => e.altName).join(', '));
  }
}
