/*import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class FocusField extends StatefulWidget {
  const FocusField({Key key, this.child}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _FocusFieldState();

  final Widget child;
}

class _FocusFieldState extends State<FocusField> {
  FocusNode _focus = FocusNode();
  //InputDecoration _inputDecoration;

  @override
  Widget build(BuildContext context) {
  InputDecoration(
                    errorStyle: TextStyle(fontSize: 12),
                    enabledBorder: InputBorder.none,
                    suffixIcon: getSuffixIcon(_focus),
                    fillColor: Colors.lightBlueAccent,
                    labelText: 'About',
                    labelStyle: TextStyle(
                        color: Theme.of(context).primaryColor, fontSize: 16),
                  ),
   // return Focus(
      //child: (widget.child as TextField).decoration.suffixIcon = suffixIcon,
  //    focusNode: _focus,
    //);
  }

  @override
  void initState() {
    super.initState();
    _focus.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    setState(() {});
  }

  IconButton getSuffixIcon(FocusNode _focus) {
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
    return icon;
}
*/
