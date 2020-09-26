import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:mood_manager/core/constants/app_constants.dart';
import 'package:intl/intl.dart';
import 'package:mood_manager/features/mood_manager/domain/entities/gender.dart';

class SelectEditBottomSheetField extends StatefulWidget {
  SelectEditBottomSheetField({
    Key key,
    @required this.label,
    @required this.labelColor,
    @required this.valueColor,
    @required this.value,
    @required this.onChange,
  }) : super(key: key);

  Gender value;
  final String label;
  final Color labelColor;
  final Color valueColor;
  final ValueChanged<Gender> onChange;

  @override
  State<StatefulWidget> createState() => _SelectEditBottomSheetFieldState();
}

class _SelectEditBottomSheetFieldState
    extends State<SelectEditBottomSheetField> {
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
            decoration: InputDecoration(
              enabledBorder: InputBorder.none,
              suffixIcon: IconButton(
                icon: Icon(
                  Icons.edit,
                  size: 18,
                ),
                onPressed: () {},
              ),
              fillColor: Colors.lightBlueAccent,
              labelText: widget.label,
              labelStyle: TextStyle(color: widget.labelColor, fontSize: 20),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _selectOption(BuildContext context) async {
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return Container(
            child: Wrap(
                children: AppConstants.genderList
                    .map((item) => ListTile(
                          leading: Icon(MdiIcons.humanMale),
                          title: Text(item.name),
                          onTap: () {
                            widget.onChange(item);
                            Navigator.of(context).pop();
                          },
                        ))
                    .toList()),
          );
        });
  }

  Gender getSelectedValue() {
    return widget.value;
  }

  @override
  void initState() {
    super.initState();
    controller = TextEditingController(text: widget.value?.name ?? '');
  }
}
