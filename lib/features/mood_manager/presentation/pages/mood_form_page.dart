import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mood_manager/core/util/resource_util.dart';
import 'package:mood_manager/features/mood_manager/data/models/t_mood_model.dart';
import 'package:mood_manager/features/mood_manager/data/streams/stream_service.dart';
import 'package:mood_manager/features/mood_manager/domain/entities/m_mood.dart';
import 'package:mood_manager/features/mood_manager/presentation/bloc/mood_circle_index.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:mood_manager/features/mood_manager/data/models/m_mood_model.dart';
import 'package:mood_manager/features/mood_manager/presentation/widgets/date_selector.dart';
import 'package:mood_manager/features/mood_manager/presentation/widgets/empty_widget.dart';
import 'package:mood_manager/features/mood_manager/presentation/widgets/time_picker.dart';
import 'package:mood_manager/features/mood_manager/presentation/widgets/radio_selection.dart';
import 'package:mood_manager/features/mood_manager/presentation/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';

import '../../../../injection_container.dart';

class MoodFormPage extends StatefulWidget {
  DateTime date = DateTime.now();
  TimeOfDay time = TimeOfDay.now();
  List<MMoodModel> moodList;
  MMoodModel selectedMood;
  Map<String, dynamic> arguments;
  MoodFormPage(this.arguments);
  @override
  State<MoodFormPage> createState() => _MoodFormPageState();
}

class _MoodFormPageState extends State<MoodFormPage> {
  MoodCircleBloc _moodCircleBloc;

  _MoodFormPageState() {
    this._moodCircleBloc = sl<MoodCircleBloc>();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Add Entry"),
      ),
      body: Column(
        children: <Widget>[
          DateSelector(
              initialDate: widget.date,
              selectDate: (DateTime date) {
                setState(() {
                  widget.date = date;
                });
              }),
          TimePicker(
            selectedTime: widget.time,
            selectTime: (time) {
              setState(() {
                widget.time = time;
              });
            },
          ),
          Text(
            'how are you ?'.toUpperCase(),
            style: TextStyle(
              fontSize: 30,
            ),
          ),
          StreamProvider<List<MMood>>.value(
            initialData: [],
            value: sl<StreamService>().moods,
            child: RadioSelection(
              initialValue: widget.selectedMood,
              onChange: this.updateState,
              parentCircleColor: Colors.blueGrey[50],
              parentCircleRadius: 150,
            ),
          ),
          SizedBox(
            height: 20,
          ),
        ],
      ),
      floatingActionButton: new Visibility(
        visible: widget.selectedMood != null,
        child: new FloatingActionButton(
          onPressed: saveMood,
          tooltip: 'Increment',
          child: new Icon(Icons.check),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget buildCircleButton() {
    if (widget.selectedMood == null) {
      return EmptyWidget();
    }

    return RawMaterialButton(
      onPressed: saveMood,
      elevation: 2.0,
      fillColor: Colors.green,
      child: Icon(
        Icons.check,
        size: 35.0,
        color: Colors.white,
      ),
      padding: EdgeInsets.all(15.0),
      shape: CircleBorder(),
    );
  }

  BlocProvider<MoodCircleBloc> buildMoodCircle(BuildContext context) {
    return BlocProvider<MoodCircleBloc>(
      create: (_) => _moodCircleBloc,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            children: <Widget>[
              BlocBuilder<MoodCircleBloc, MoodCircleState>(
                builder: (context, state) {
                  if (state is MoodCircleEmpty || state is MoodCircleLoading) {
                    return LoadingWidget();
                  } else if (state is MoodCircleLoaded) {
                    widget.moodList = state.moodList;
                    return RadioSelection(
                      // moodList: widget.moodList,
                      initialValue: widget.selectedMood,
                      onChange: this.updateState,
                      parentCircleColor: Colors.blueGrey[50],
                      parentCircleRadius: 150,
                    );
                  } else if (state is MoodCircleError) {
                    return MessageDisplay(
                      message: state.message,
                    );
                  }
                  return EmptyWidget();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  updateState(value) {
    setState(() {
      widget.selectedMood = value;
    });
  }

  saveMood() {
    Navigator.pushNamed(context, "/add/activity", arguments: {
      'formData': TMoodModel(
          note: null,
          logDateTime: DateTimeField.combine(widget.date, widget.time),
          mMoodModel: widget.selectedMood)
    });
  }

  @override
  void initState() {
    super.initState();
    //_moodCircleBloc.add(GetMoodMetaEvent());
  }

  @override
  void dispose() {
    super.dispose();
    ResourceUtil.closeBloc(_moodCircleBloc);
  }
}
