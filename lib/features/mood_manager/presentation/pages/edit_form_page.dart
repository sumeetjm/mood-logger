// import 'dart:async';
// import 'package:mood_manager/core/constants/app_constants.dart';
// import 'package:mood_manager/features/mood_manager/data/models/parse/t_activity_parse.dart';
// import 'package:mood_manager/features/mood_manager/data/models/parse/t_mood_parse.dart';
// import 'package:mood_manager/features/metadata/domain/entities/m_activity.dart';
// import 'package:mood_manager/features/metadata/domain/entities/m_activity_type.dart';
// import 'package:mood_manager/features/metadata/domain/entities/m_mood.dart';
// import 'package:mood_manager/features/mood_manager/domain/entities/t_activity.dart';
// import 'package:mood_manager/features/mood_manager/domain/entities/t_mood.dart';
// import 'package:mood_manager/features/mood_manager/presentation/bloc/activity_list_index.dart';
// import 'package:mood_manager/features/mood_manager/presentation/bloc/t_mood_index.dart';
// import 'package:mood_manager/features/mood_manager/presentation/bloc/mood_circle_index.dart';
// import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
// import 'package:mood_manager/features/mood_manager/presentation/widgets/activity_choice_chips.dart';
// import 'package:mood_manager/features/common/presentation/widgets/date_selector.dart';
// import 'package:mood_manager/features/common/presentation/widgets/empty_widget.dart';
// import 'package:mood_manager/features/common/presentation/widgets/scroll_select.dart';
// import 'package:mood_manager/features/common/presentation/widgets/time_picker.dart';
// import 'package:mood_manager/features/mood_manager/presentation/widgets/radio_selection.dart';
// import 'package:mood_manager/features/mood_manager/presentation/widgets/widgets.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';

// import '../../../../injection_container.dart';

// class EditFormPage extends StatefulWidget {
//   TMood originalTMood;
//   List<MMood> mMoodList;
//   List<MMood> subMoodList;
//   List<MActivityType> mActivityTypeList = [];
//   List<MActivity> originalMActivityList;
//   List<MActivityType> selectedMActivityTypeList = [];
//   //New form data
//   DateTime selectedDate;
//   TimeOfDay selectedTime;
//   MMood selectedMood;
//   MMood selectedSubMood;
//   int maxActivitySelected = 5;
//   Map<String, List<MActivity>> selectedMActivityListMapByType = Map();
//   String note;

//   Map<dynamic, dynamic> arguments;

//   EditFormPage({this.arguments}) {
//     if (arguments != null) {
//       originalTMood = arguments['formData'];
//       selectedDate = originalTMood.logDateTime;
//       selectedTime = TimeOfDay.fromDateTime(selectedDate);
//       selectedMood = originalTMood.mMood;
//       selectedSubMood = originalTMood.mMood;
//       note = originalTMood.note;
//       originalMActivityList = originalTMood.tActivityList
//           .map((tActivity) => tActivity.mActivity)
//           .toList();
//     }
//   }
//   @override
//   State<EditFormPage> createState() => _EditFormPageState();
// }

// class _EditFormPageState extends State<EditFormPage> {
//   MoodCircleBloc _moodCircleBloc;
//   ActivityListBloc _activityListBloc;
//   StreamSubscription<ActivityListState> activityListBlocListener;
//   StreamSubscription<TMoodState> tMoodBlocListener;
//   TMoodBloc _tMoodBloc;
//   TextEditingController textEditingController = TextEditingController();

//   _EditFormPageState() {
//     this._moodCircleBloc = sl<MoodCircleBloc>();
//     this._activityListBloc = sl<ActivityListBloc>();
//   }
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Edit'),
//       ),
//       body: SingleChildScrollView(
//         child: Column(
//           children: <Widget>[
//             DateSelector(
//                 initialDate: widget.selectedDate,
//                 selectDate: (DateTime date) {
//                   setState(() {
//                     widget.selectedDate = date;
//                   });
//                 }),
//             TimePicker(
//               selectedTime: widget.selectedTime,
//               selectTime: (TimeOfDay time) {
//                 setState(() {
//                   widget.selectedTime = time;
//                 });
//               },
//             ),
//             Text(
//               'how are you ?'.toUpperCase(),
//               style: TextStyle(
//                 fontSize: 20,
//               ),
//             ),
//             buildMoodCircle(context),
//             SizedBox(
//               height: 20,
//             ),
//             Container(
//               color: Colors.white,
//               child: TextField(
//                 controller: textEditingController,
//                 keyboardType: TextInputType.multiline,
//                 maxLines: null,
//                 onChanged: (text) {
//                   updateNote(text);
//                 },
//                 style: TextStyle(
//                   color: Colors.blueGrey,
//                   fontSize: 18,
//                 ),
//                 decoration: InputDecoration(
//                     contentPadding: EdgeInsets.all(15),
//                     fillColor: Colors.blueGrey,
//                     border: InputBorder.none,
//                     hintText: 'Add Note...'),
//               ),
//             ),
//             ...buildActivityList(),
//             SizedBox(height: 20),
//           ],
//         ),
//       ),
//       floatingActionButton: Visibility(
//         visible: true,
//         child: FloatingActionButton(
//           onPressed: saveMood,
//           child: Icon(Icons.check),
//         ),
//       ),
//     );
//   }

//   BlocProvider<MoodCircleBloc> buildMoodCircle(BuildContext context) {
//     return BlocProvider<MoodCircleBloc>(
//       create: (_) => _moodCircleBloc,
//       child: Center(
//         child: Padding(
//           padding: const EdgeInsets.all(10),
//           child: Column(
//             children: <Widget>[
//               BlocBuilder<MoodCircleBloc, MoodCircleState>(
//                 builder: (context, state) {
//                   if (state is MoodCircleEmpty || state is MoodCircleLoading) {
//                     return LoadingWidget();
//                   } else if (state is MoodCircleLoaded) {
//                     widget.mMoodList = state.moodList;
//                     if (widget.mMoodList
//                         .every((element) => element != widget.selectedMood)) {
//                       widget.selectedMood = widget.mMoodList.singleWhere(
//                           (element) => element.mMoodList
//                               .contains(widget.originalTMood.mMood));
//                     }
//                     widget.subMoodList = [
//                       widget.selectedMood,
//                       ...widget.selectedMood.mMoodList
//                     ];
//                     return Column(
//                       children: [
//                         RadioSelection(
//                           moodList: widget.mMoodList,
//                           initialValue: widget.selectedMood,
//                           onChange: this.onChange,
//                           parentCircleColor: Colors.blueGrey[50],
//                           parentCircleRadius: 100,
//                           initialSubValue: widget.selectedSubMood,
//                           showLabel: false,
//                         ),
//                         SizedBox(
//                           height: 20,
//                         ),
//                         ScrollSelect<MMood>(
//                             scrollDirection: ScrollDirection.horizontal,
//                             onChanged: (mMood) {
//                               setState(() {
//                                 widget.selectedSubMood = mMood;
//                               });
//                             },
//                             options: ScrollSelectOption.listFrom<MMood, MMood>(
//                                 source: widget.subMoodList,
//                                 value: (i, v) => v,
//                                 label: (i, v) => v.moodName.toUpperCase(),
//                                 color: (i, v) => v.color),
//                             initialValue: widget.selectedSubMood,
//                             itemFontSize: 18,
//                             height: 50,
//                             itemExtent: 150,
//                             backgroundColor: Colors.white.withOpacity(0.0)),
//                       ],
//                     );
//                   } else if (state is MoodCircleError) {
//                     return MessageDisplay(
//                       message: state.message,
//                     );
//                   }
//                   return EmptyWidget();
//                 },
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   List<Widget> buildActivityList() {
//     return widget.mActivityTypeList
//         .map((type) => Padding(
//               padding: const EdgeInsets.fromLTRB(8.0, 0, 8.0, 0),
//               child: Content(
//                 color: Theme.of(context).primaryColor,
//                 title: type.activityTypeName,
//                 child: FormField<List<MActivity>>(
//                   autovalidate: true,
//                   initialValue: widget.selectedMActivityListMapByType[
//                           type.activityTypeCode] ??
//                       [],
//                   builder: (state) {
//                     final selected = widget
//                         .selectedMActivityListMapByType.values
//                         .expand((item) => item)
//                         .toList();
//                     return ChoiceChipsByType(
//                         color: Theme.of(context).primaryColor,
//                         //activityList: type.mActivityList,
//                         mActivityTypeCode: type.activityTypeCode,
//                         selectOptions: setActivityList,
//                         state: state,
//                         maxReached:
//                             widget.maxActivitySelected == selected.length,
//                         selected: selected);
//                   },
//                 ),
//               ),
//             ))
//         .toList();
//   }

//   onChange(value) {
//     setState(() {
//       widget.selectedMood = value;
//       widget.subMoodList = [value, ...value.mMoodList];
//       widget.selectedSubMood = value;
//     });
//   }

//   saveMood() {
//     final selectedMActivityList = widget.selectedMActivityListMapByType.values
//         .expand((item) => item)
//         .toList();
//     final deselectedActivityList = widget.originalMActivityList
//         .where((mActivity) => !selectedMActivityList.contains(mActivity))
//         .toList();
//     final existingActivityMap = Map.fromEntries(
//         [].map((e) => MapEntry(e.mActivity, e.transActivityId)));

//     final finalSaveActivityList = List<TActivity>();
//     finalSaveActivityList
//         .addAll(selectedMActivityList.map((activity) => TActivityParse(
//               transActivityId: existingActivityMap[activity],
//               mActivity: activity,
//             )));
//     finalSaveActivityList.addAll(deselectedActivityList.map((activity) =>
//         TActivityParse(
//             transActivityId: existingActivityMap[activity],
//             mActivity: activity,
//             isActive: false)));

//     final saveData = TMoodParse(
//         logDateTime:
//             DateTimeField.combine(widget.selectedDate, widget.selectedTime),
//         transMoodId: widget.originalTMood.id,
//         mMood: widget.selectedSubMood,
//         note: widget.note,
//         tActivityList: finalSaveActivityList);
//     _tMoodBloc.add(SaveTMoodEvent(saveData, AppConstants.ACTION['UPDATE']));
//   }

//   setActivityList(MapEntry<String, List<MActivity>> mapEntry) {
//     setState(() {
//       widget.selectedMActivityListMapByType[mapEntry.key] = mapEntry.value;
//     });
//   }

//   @override
//   void initState() {
//     super.initState();
//     _tMoodBloc = BlocProvider.of<TMoodBloc>(context);
//     _moodCircleBloc.add(GetMMoodListEvent());
//     _activityListBloc.add(GetMActivityTypeListEvent());
//     activityListBlocListener = _activityListBloc.listen((state) {
//       if (state is ActivityTypeListLoaded) {
//         setState(() {
//           widget.mActivityTypeList = state.mActivityTypeList;
//           widget.originalMActivityList.forEach((element) {
//             // final type = widget.mActivityTypeList.singleWhere((mActivityType) =>
//             //     mActivityType.mActivityList
//             //         .any((mActivity) => mActivity == element));
//             if (widget.selectedMActivityListMapByType
//                 .containsKey(type.activityTypeCode)) {
//               widget.selectedMActivityListMapByType[type.activityTypeCode]
//                   .add(element);
//             } else {
//               widget.selectedMActivityListMapByType[type.activityTypeCode] = [
//                 element
//               ];
//             }
//           });
//         });
//       }
//     });
//     tMoodBlocListener = _tMoodBloc.listen((state) {
//       if (state is TMoodSaved) {
//         Navigator.of(context).popUntil((route) => route.isFirst);
//       }
//     });
//     textEditingController.value = TextEditingValue(
//       text: widget.originalTMood.note,
//       selection: TextSelection.fromPosition(
//         TextPosition(offset: widget.note.length),
//       ),
//     );
//   }

//   updateNote(value) {
//     widget.note = value;
//   }

//   @override
//   void dispose() {
//     super.dispose();
//     if (_moodCircleBloc != null) {
//       _moodCircleBloc.close();
//     }
//     if (_activityListBloc != null) {
//       _activityListBloc.close();
//     }
//     if (activityListBlocListener != null) {
//       activityListBlocListener.cancel();
//     }
//     if (tMoodBlocListener != null) {
//       tMoodBlocListener.cancel();
//     }
//     if (textEditingController != null) {
//       textEditingController.dispose();
//     }
//   }
// }
