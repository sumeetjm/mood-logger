import 'package:mood_manager/features/mood_manager/presentation/bloc/mood_circle_index.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class FormActionsControls extends StatefulWidget {
  const FormActionsControls({
    Key key,
  }) : super(key: key);

  @override
  _FormActionsControlsState createState() => _FormActionsControlsState();
}

class _FormActionsControlsState extends State<FormActionsControls> {

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[],
    );
  }

  @override
  void initState() {
    super.initState();
    BlocProvider.of<MoodCircleBloc>(context).add(GetMoodMetaEvent());
  }
  
}
