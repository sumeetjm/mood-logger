import 'dart:async';

import 'package:chips_choice/chips_choice.dart';
import 'package:mood_manager/features/mood_manager/data/models/m_activity_model.dart';
import 'package:mood_manager/features/mood_manager/data/models/t_activity_model.dart';
import 'package:mood_manager/features/mood_manager/data/models/m_activity_type_model.dart';
import 'package:mood_manager/features/mood_manager/data/models/t_mood_model.dart';
import 'package:mood_manager/features/mood_manager/domain/entities/m_activity.dart';
import 'package:mood_manager/features/mood_manager/domain/entities/m_activity_type.dart';
import 'package:mood_manager/features/mood_manager/domain/entities/m_mood.dart';
import 'package:mood_manager/features/mood_manager/domain/entities/t_activity.dart';
import 'package:mood_manager/features/mood_manager/presentation/bloc/activity_list_index.dart';
import 'package:mood_manager/features/mood_manager/presentation/bloc/t_mood_index.dart';
import 'package:mood_manager/features/mood_manager/presentation/bloc/mood_circle_index.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:mood_manager/features/mood_manager/data/models/m_mood_model.dart';
import 'package:mood_manager/features/mood_manager/presentation/widgets/activity_choice_chips.dart';
import 'package:mood_manager/features/mood_manager/presentation/widgets/date_selector.dart';
import 'package:mood_manager/features/mood_manager/presentation/widgets/empty_widget.dart';
import 'package:mood_manager/features/mood_manager/presentation/widgets/time_picker.dart';
import 'package:mood_manager/features/mood_manager/presentation/widgets/radio_selection.dart';
import 'package:mood_manager/features/mood_manager/presentation/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../injection_container.dart';

class EditFormPage extends StatefulWidget {
  TMoodModel originalTMood;
  List<MMood> mMoodList;
  Map<String, List<MActivity>> mActivityListGroupByType = Map();
  Map<String, MActivityType> mActivityTypeMapByCode = Map();
  List<MActivity> originalTActivityList;

  //New form data
  DateTime selectedDate;
  TimeOfDay selectedTime;
  MMood selectedMood;
  Map<String, List<MActivity>> selectedMActivityListGroupByType = Map();
  String note;

  Map<dynamic, dynamic> arguments;

  EditFormPage(this.arguments) {
    if (arguments != null) {
      originalTMood = arguments['formData'];
      selectedDate = originalTMood.logDateTime;
      selectedTime = TimeOfDay.fromDateTime(selectedDate);
      selectedMood = originalTMood.mMood;
      note = originalTMood.note;
      originalTActivityList =
          [].map((tActivity) => tActivity.mActivity as MActivityModel).toList();
    }
  }
  @override
  State<EditFormPage> createState() => _EditFormPageState();
}

class _EditFormPageState extends State<EditFormPage> {
  MoodCircleBloc _moodCircleBloc;
  ActivityListBloc _activityListBloc;
  StreamSubscription<ActivityListState> activityListBlocListener;
  StreamSubscription<TMoodState> transActionBlocListener;
  TMoodBloc _transActionBloc;
  TextEditingController textEditingController = TextEditingController();

  _EditFormPageState() {
    this._moodCircleBloc = sl<MoodCircleBloc>();
    this._activityListBloc = sl<ActivityListBloc>();
    this._transActionBloc = sl<TMoodBloc>();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Edit"),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            DateSelector(
                initialDate: widget.selectedDate,
                selectDate: (DateTime date) {
                  setState(() {
                    widget.selectedDate = date;
                  });
                }),
            TimePicker(
              selectedTime: widget.selectedTime,
              selectTime: (TimeOfDay time) {
                setState(() {
                  widget.selectedTime = time;
                });
              },
            ),
            Text(
              'how are you ?'.toUpperCase(),
              style: TextStyle(
                fontSize: 20,
              ),
            ),
            buildMoodCircle(context),
            SizedBox(
              height: 20,
            ),
            Content(
                child: TextField(
              controller: textEditingController,
              keyboardType: TextInputType.multiline,
              maxLines: null,
              onChanged: (text) {
                updateNote(text);
              },
              style: TextStyle(
                color: Colors.blueGrey,
                fontSize: 18,
              ),
              decoration: InputDecoration(
                  contentPadding: EdgeInsets.all(15),
                  fillColor: Colors.blueGrey,
                  border: InputBorder.none,
                  hintText: 'Add Note...'),
            )),
            ...buildActivityList(),
            SizedBox(height: 20),
          ],
        ),
      ),
      floatingActionButton: new Visibility(
        visible: true,
        child: new FloatingActionButton(
          onPressed: saveMood,
          child: new Icon(Icons.check),
        ),
      ),
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
                    widget.mMoodList = state.moodList;
                    return RadioSelection(
                      //moodList: widget.mMoodList,
                      initialValue: widget.selectedMood,
                      onChange: this.onChange,
                      parentCircleColor: Colors.blueGrey[50],
                      parentCircleRadius: 100,
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

  List<Widget> buildActivityList() {
    return widget.mActivityTypeMapByCode.keys
        .map((typeCode) => Content(
              title: widget.mActivityTypeMapByCode[typeCode].name,
              child: FormField<List<MActivity>>(
                autovalidate: true,
                initialValue: widget.selectedMActivityListGroupByType[typeCode],
                builder: (state) {
                  return Column(
                    children: <Widget>[
                      Container(
                        alignment: Alignment.centerLeft,
                        child: ChipsChoice<MActivity>.multiple(
                          value: state.value,
                          options: ChipsChoiceOption.listFrom<MActivityModel,
                              MActivity>(
                            source: widget.mActivityListGroupByType[typeCode],
                            value: (i, v) => v,
                            label: (i, v) => v.name,
                          ),
                          onChanged: (value) => {
                            state.didChange(value),
                            setActivityList(MapEntry(typeCode, value))
                          },
                          itemConfig: ChipsChoiceItemConfig(
                            selectedColor: Colors.green,
                            selectedBrightness: Brightness.dark,
                            unselectedColor: Colors.black,
                            unselectedBorderOpacity: .3,
                          ),
                          isWrapped: true,
                        ),
                      ),
                      Container(
                          padding: EdgeInsets.fromLTRB(15, 0, 15, 15),
                          alignment: Alignment.centerLeft,
                          child: Text(
                            state.errorText ??
                                state.value.length.toString() + '/5 selected',
                            style: TextStyle(
                                color: state.hasError
                                    ? Colors.redAccent
                                    : Colors.green),
                          ))
                    ],
                  );
                },
              ),
            ))
        .toList();
  }

  onChange(value) {
    setState(() {
      widget.selectedMood = value;
    });
  }

  saveMood() {
    final selectedMActivityList = widget.selectedMActivityListGroupByType.values
        .expand((item) => item)
        .toList();
    final deselectedActivityList = widget.originalTActivityList
        .where((mActivity) => !selectedMActivityList.contains(mActivity))
        .toList();
    final existingActivityMap = Map.fromEntries(
        [].map((e) => MapEntry(e.mActivity, e.transActivityId)));

    final finalSaveActivityList = List<TActivity>();
    finalSaveActivityList
        .addAll(selectedMActivityList.map((activity) => TActivityModel(
              transActivityId: existingActivityMap[activity],
              mActivityModel: activity,
            )));
    finalSaveActivityList.addAll(deselectedActivityList.map((activity) =>
        TActivityModel(
            transActivityId: existingActivityMap[activity],
            mActivityModel: activity,
            isActive: false)));
    final saveData = TMoodModel(
        logDateTime:
            DateTimeField.combine(widget.selectedDate, widget.selectedTime),
        transMoodId: widget.originalTMood.id,
        mMood: widget.selectedMood,
        note: widget.note);
    _transActionBloc.add(SaveTMoodEvent(saveData, finalSaveActivityList));
  }

  setActivityList(MapEntry<String, List<MActivity>> mapEntry) {
    setState(() {
      widget.selectedMActivityListGroupByType[mapEntry.key] = mapEntry.value;
    });
  }

  @override
  void initState() {
    super.initState();
    _moodCircleBloc.add(GetMoodMetaEvent());
    _activityListBloc.add(GetActivityMetaEvent());
    activityListBlocListener = _activityListBloc.listen((state) {
      /*if (state is ActivityListLoaded) {
        setState(() {
          widget.mActivityListGroupByType = state.mActivityList;
          widget.mActivityTypeMapByCode = Map.fromEntries(widget
              .mActivityListGroupByType.values
              .expand((mActivityList) => mActivityList)
              //.map((mActivity) => mActivity.mActivityType)
              .toSet()
              .map((mActivity) =>
                  MapEntry(mActivity.code, mActivity as MActivityTypeModel)));

          widget.mActivityListGroupByType.keys.forEach((typeCode) {
            setActivityList(MapEntry(
                typeCode,
                widget.mActivityListGroupByType[typeCode]
                    .where((element) =>
                        widget.originalTActivityList.contains(element))
                    .toList()));
          });
        });
      }*/
    });
    transActionBlocListener = _transActionBloc.listen((state) {
      if (state is TMoodSaved) {
        Navigator.of(context).pushNamedAndRemoveUntil(
            '/trans-list', (route) => false,
            arguments: {'lastSaved': state.tMood});
      }
    });
    textEditingController.value = TextEditingValue(
      text: widget.originalTMood.note,
      selection: TextSelection.fromPosition(
        TextPosition(offset: widget.note.length),
      ),
    );
  }

  updateNote(value) {
    widget.note = value;
  }

  @override
  void dispose() {
    super.dispose();
    if (_moodCircleBloc != null) {
      _moodCircleBloc.close();
    }
    if (_activityListBloc != null) {
      _activityListBloc.close();
    }
    if (activityListBlocListener != null) {
      activityListBlocListener.cancel();
    }
    if (transActionBlocListener != null) {
      transActionBlocListener.cancel();
    }
    if (textEditingController != null) {
      textEditingController.dispose();
    }
  }
}
