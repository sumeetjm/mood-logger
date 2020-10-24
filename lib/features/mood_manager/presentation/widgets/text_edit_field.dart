import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TextEditField extends StatefulWidget {
  const TextEditField({
    Key key,
    @required this.label,
    @required this.labelColor,
    @required this.valueColor,
    @required this.value,
    @required this.onChange,
    @required this.save,
    this.inputType = TextInputType.text,
  }) : super(key: key);

  final String label;
  final Color labelColor;
  final Color valueColor;
  final String value;
  final ValueChanged<String> onChange;
  final Function save;
  final TextInputType inputType;

  @override
  State<StatefulWidget> createState() => _TextEditFieldState();
}

class _TextEditFieldState extends State<TextEditField> {
  TextEditingController textEditingController;
  FocusNode _focus = new FocusNode();
  bool isFocused = false;
  bool isChanged = false;
  @override
  Widget build(BuildContext context) {
    IconButton icon = !_focus.hasFocus
        ? IconButton(
            icon: Icon(
              Icons.edit,
              size: 18,
            ),
            onPressed: () {},
          )
        : IconButton(
            icon: Icon(
              Icons.check,
              size: 18,
            ),
            onPressed: () {
              _focus.unfocus();
            },
          );

    /*TextFormField(
      validator: (value) {
        if (value != null &&
            !value.isNotEmpty &&
            RegExp('^[_A-z0-9]*((-|\s)*[_A-z0-9])*\$').hasMatch(value)) {
          return 'Invalid';
        }
        return null;
      },
      inputFormatters: [
        FilteringTextInputFormatter.allow(
            RegExp('^[_A-z0-9]*((-|\s)*[_A-z0-9])*\$'))
      ],
      keyboardType: TextInputType.text,
      focusNode: _focus,
      controller: textEditingController,
      style: TextStyle(color: Colors.black, fontSize: 16),
      onChanged: print,
      decoration: InputDecoration(
        enabledBorder: InputBorder.none,
        suffixIcon: Icon(Icons.edit),
        fillColor: Colors.lightBlueAccent,
        labelText: widget.label,
        labelStyle: TextStyle(color: widget.valueColor, fontSize: 16),
      ),
    );*/
    return Container(
      height: 65,
      width: MediaQuery.of(context).size.width,
      child: TextFormField(
        autovalidate: true,
        validator: (value) {
          if (value != null &&
              value.isNotEmpty &&
              RegExp('[_A-z0-9]*((-|\s)*[_A-z0-9])*').hasMatch(value)) {
            return 'Invalid';
          }
          return null;
        },
        keyboardType: TextInputType.text,
        focusNode: _focus,
        controller: textEditingController,
        style: TextStyle(color: Colors.black, fontSize: 16),
        onChanged: print,
        decoration: InputDecoration(
          enabledBorder: InputBorder.none,
          suffixIcon: Icon(Icons.edit),
          fillColor: Colors.lightBlueAccent,
          labelText: widget.label,
          labelStyle: TextStyle(color: widget.valueColor, fontSize: 16),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    textEditingController = TextEditingController(text: widget.value);
    _focus.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    setState(() {
      if (_focus.hasFocus) {
        isFocused = true;
      } else if (isFocused && isChanged) {
        widget.save();
        isFocused = false;
        isChanged = false;
      }
    });
  }
}
