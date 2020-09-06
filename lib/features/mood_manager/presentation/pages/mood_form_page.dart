import 'dart:developer';

import 'package:chips_choice/chips_choice.dart';
import 'package:flutter/cupertino.dart';
import 'package:mood_manager/core/util/resource_util.dart';
import 'package:mood_manager/features/mood_manager/data/models/parse/t_mood_parse.dart';
import 'package:mood_manager/features/mood_manager/domain/entities/m_mood.dart';
import 'package:mood_manager/features/mood_manager/presentation/bloc/mood_circle_index.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:mood_manager/features/mood_manager/presentation/widgets/activity_choice_chips.dart';
import 'package:mood_manager/features/mood_manager/presentation/widgets/date_selector.dart';
import 'package:mood_manager/features/mood_manager/presentation/widgets/empty_widget.dart';
import 'package:mood_manager/features/mood_manager/presentation/widgets/scroll_select.dart';
import 'package:mood_manager/features/mood_manager/presentation/widgets/time_picker.dart';
import 'package:mood_manager/features/mood_manager/presentation/widgets/radio_selection.dart';
import 'package:mood_manager/features/mood_manager/presentation/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:tinycolor/tinycolor.dart';

import '../../../../injection_container.dart';

class MoodFormPage extends StatefulWidget {
  DateTime date = DateTime.now();
  TimeOfDay time = TimeOfDay.now();
  List<MMood> moodList;
  List<MMood> subMoodList = [];
  MMood selectedMood;
  MMood selectedSubMood;
  Map<String, dynamic> arguments;
  MoodFormPage({this.arguments});
  @override
  State<MoodFormPage> createState() => _MoodFormPageState();
}

class _MoodFormPageState extends State<MoodFormPage> {
  MoodCircleBloc _moodCircleBloc;
  FixedExtentScrollController _scrollController;

  _MoodFormPageState() {
    this._moodCircleBloc = sl<MoodCircleBloc>();
  }
  @override
  Widget build(BuildContext context) {
    final content = Column(
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
        buildMoodCircle(context),
        SizedBox(
          height: 20,
        ),
      ],
    );
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Entry'),
      ),
      body: content,
      floatingActionButton: Visibility(
        visible: widget.selectedMood != null,
        child: FloatingActionButton(
          onPressed: saveMood,
          tooltip: 'Increment',
          child: Icon(Icons.check),
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
      fillColor: Theme.of(context).buttonColor,
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
                    //debugger(when:false);
                    widget.moodList = state.moodList;
                    return Column(
                      children: [
                        RadioSelection(
                          moodList: widget.moodList,
                          initialValue: widget.selectedMood,
                          initialSubValue: widget.selectedSubMood,
                          onChange: updateState,
                          parentCircleColor: Colors.blueGrey[50],
                          parentCircleRadius: 175,
                        ),
                        SizedBox(
                          height: 30,
                        ),
                        if (widget.selectedMood != null &&
                            widget.subMoodList.length > 0)
                          ScrollSelect<MMood>(
                              scrollDirection: ScrollDirection.horizontal,
                              onChanged: (mMood) {
                                setState(() {
                                  //debugger(when:false);
                                  widget.selectedSubMood = mMood;
                                });
                              },
                              options:
                                  ScrollSelectOption.listFrom<MMood, MMood>(
                                      source: widget.subMoodList,
                                      value: (i, v) => v,
                                      label: (i, v) => v.name.toUpperCase(),
                                      color: (i, v) => v.color),
                              initialValue: widget.selectedSubMood,
                              itemFontSize: 18,
                              height: 50,
                              itemExtent: 150,
                              backgroundColor: Colors.white.withOpacity(0.0))
                      ],
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
      //debugger(when:false);
      widget.selectedMood = value;
      widget.subMoodList = [value, ...value.mMoodList];
      widget.selectedSubMood = value;
    });
  }

  saveMood() {
    Navigator.pushNamed(context, '/add/activity', arguments: {
      'formData': TMoodParse(
          note: null,
          logDateTime: DateTimeField.combine(widget.date, widget.time),
          mMood: widget.selectedSubMood)
    });
  }

  @override
  void initState() {
    super.initState();
    widget.date = widget.arguments['selectedDate'] ?? DateTime.now();
    widget.time = TimeOfDay.fromDateTime(widget.date);
    _moodCircleBloc.add(GetMMoodListEvent());
    _scrollController = FixedExtentScrollController();
  }

  @override
  void dispose() {
    super.dispose();
    ResourceUtil.closeBloc(_moodCircleBloc);
  }
}
