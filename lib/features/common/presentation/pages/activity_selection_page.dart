import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mood_manager/features/common/presentation/widgets/choice_chip_group_selection.dart';
import 'package:mood_manager/features/common/presentation/widgets/empty_widget.dart';
import 'package:mood_manager/features/metadata/data/models/m_activity_parse.dart';
import 'package:mood_manager/features/metadata/data/models/m_activity_type_parse.dart';
import 'package:mood_manager/features/metadata/domain/entities/m_activity.dart';
import 'package:mood_manager/features/metadata/domain/entities/m_activity_type.dart';
import 'package:mood_manager/features/metadata/presentation/bloc/activity_bloc.dart';
import 'package:mood_manager/injection_container.dart';

// ignore: must_be_immutable
class ActivitySelectionPage extends StatefulWidget {
  List<MActivity> selectedActivityList;
  ValueChanged<List<MActivity>> onChange;

  ActivitySelectionPage({Key key, this.selectedActivityList, this.onChange})
      : super(key: key);
  @override
  State<StatefulWidget> createState() => _ActivitySelectionPageState();
}

class _ActivitySelectionPageState extends State<ActivitySelectionPage> {
  TextEditingController _textFieldController;
  ActivityBloc _activityListBloc;
  List<MActivity> activityList = [];
  List<MActivityType> activityTypeList = [];
  MActivityType newActivityGroupType;
  MActivity lastActivityAdded;
  bool searchMode = false;
  FocusNode _searchFocus = new FocusNode();

  @override
  void initState() {
    super.initState();
    _textFieldController = TextEditingController();
    _activityListBloc = sl<ActivityBloc>();
    _textFieldController.text = "";
    _activityListBloc.add(GetActivityListEvent());
    _activityListBloc.add(GetActivityTypeListEvent());
  }

  Widget titleWidget() {
    if (searchMode) {
      return TextField(
        focusNode: _searchFocus,
        decoration: InputDecoration(
          hintText: 'Search',
          hintStyle: TextStyle(color: Colors.white),
        ),
        style: TextStyle(color: Colors.white),
        cursorColor: Colors.white,
        cursorHeight: 20,
        onChanged: (value) {
          var searchValue = (value ?? '').trim();
          if (searchValue.length == 0) {
            _activityListBloc.add(GetActivityListEvent());
          } else if (searchValue.length >= 3) {
            _activityListBloc.add(SearchActivityListEvent(searchText: value));
          }
        },
      );
    }
    return Text('Select Activity');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: titleWidget(),
        actions: [
          IconButton(
              icon: Icon(Icons.search_rounded),
              onPressed: () {
                setState(() {
                  searchMode = true;
                  _searchFocus.requestFocus();
                });
              }),
          IconButton(
              icon: Icon(Icons.done_rounded),
              onPressed: () {
                Navigator.of(context).pop();
                widget.onChange(widget.selectedActivityList);
              }),
          IconButton(
              icon: Icon(Icons.add_rounded),
              onPressed: () {
                _displayDialog(context);
              })
        ],
      ),
      body: BlocConsumer<ActivityBloc, ActivityState>(
        cubit: _activityListBloc,
        listener: (context, state) {
          if (state is ActivityListLoaded) {
            activityList = state.activityList;
          } else if (state is ActivityAdded) {
            lastActivityAdded = state.activity;
            activityList.add(lastActivityAdded);
            if (!activityTypeList
                .any((element) => element == lastActivityAdded.mActivityType)) {
              activityTypeList.add(lastActivityAdded.mActivityType);
            }
          } else if (state is ActivityTypeListLoaded) {
            activityTypeList = state.activityTypeList;
          } else if (state is ActivityListLoading ||
              state is ActivityLoading) {}
        },
        buildWhen: (previous, current) => previous != current,
        builder: (context, state) {
          if (activityList.isEmpty || activityTypeList.isEmpty) {
            return EmptyWidget();
          } else {
            if (state is ActivityLoading) {
              return EmptyWidget();
            } else {
              return buildChoiceChipGroupSelection();
            }
          }
        },
      ),
    );
  }

  buildChoiceChipGroupSelection() {
    return ChoiceChipGroupSelection(
      maxSelection: 3,
      choiceChipOptions:
          ChoiceChipGroupSelectionOption.listFrom<MActivity, MActivity>(
              source: activityList,
              value: (index, item) => item,
              label: (index, item) => item.activityName,
              group: (index, item) => item.mActivityType),
      groupLabel: (group) => group.activityTypeName,
      initialValue: widget.selectedActivityList,
      onChange: (activityList) {
        setState(() {
          widget.selectedActivityList = List.from(activityList);
        });
      },
      groupList: activityTypeList,
    );
  }

  _displayDialog(BuildContext context) async {
    return showDialog(
        context: context,
        builder: (context) {
          bool isNewGroup = newActivityGroupType != null &&
              newActivityGroupType.activityTypeName == "";
          return StatefulBuilder(
            builder: (context, setState) {
              final List<Widget> items = activityTypeList.map((type) {
                return DropdownMenuItem<MActivityType>(
                    value: type,
                    child: Text(
                      type.activityTypeName,
                    ));
              }).toList();
              return AlertDialog(
                title: Text('Add Activity'),
                content: Container(
                  height: 160,
                  child: Column(
                    children: [
                      TextField(
                        controller: _textFieldController,
                        decoration: InputDecoration(
                          hintText: "eg.family",
                        ),
                      ),
                      DropdownButtonFormField<MActivityType>(
                        value: newActivityGroupType,
                        icon: Padding(
                          padding: const EdgeInsets.fromLTRB(0, 0, 12.0, 0),
                          child: Icon(Icons.keyboard_arrow_down),
                        ),
                        items: [
                          ...items,
                          DropdownMenuItem<MActivityType>(
                              value: MActivityTypeParse(
                                activityTypeCode: "",
                                activityTypeName: "",
                              ),
                              child: Text(
                                "New",
                              ))
                        ],
                        onChanged: (value) {
                          newActivityGroupType = value;
                          setState(() {
                            isNewGroup =
                                newActivityGroupType.activityTypeName == "";
                          });
                        },
                        decoration: InputDecoration(
                          errorStyle: TextStyle(fontSize: 12),
                          enabledBorder: InputBorder.none,
                          fillColor: Colors.lightBlueAccent,
                          labelText: 'Type',
                          labelStyle: TextStyle(
                              color: Theme.of(context).primaryColor,
                              fontSize: 16),
                        ),
                      ),
                      if (isNewGroup)
                        TextField(
                            decoration: InputDecoration(
                              hintText: 'eg. sleep',
                            ),
                            onChanged: (value) {
                              newActivityGroupType.activityTypeName = value;
                              newActivityGroupType.activityTypeCode =
                                  value.replaceAll(RegExp(r"\s+"), "");
                            })
                    ],
                  ),
                ),
                actions: <Widget>[
                  new FlatButton(
                    child: new Text('SUBMIT'),
                    onPressed: () {
                      if (_textFieldController.text.isNotEmpty &&
                          newActivityGroupType != null &&
                          newActivityGroupType.activityTypeName.isNotEmpty) {
                        addActivity();
                        Navigator.pop(context);
                      }
                    },
                  )
                ],
              );
            },
          );
        });
  }

  @override
  void dispose() {
    _activityListBloc.close();
    super.dispose();
  }

  addActivity() {
    final String newActivityName = _textFieldController.text;
    _activityListBloc.add(AddActivityEvent(
        activity: MActivityParse(
      activityName: newActivityName,
      activityCode: newActivityName.replaceAll(" ", ""),
      mActivityType: newActivityGroupType,
    )));
    resetAddActivity();
  }

  resetAddActivity() {
    _textFieldController.text = "";
    newActivityGroupType = null;
  }
}
