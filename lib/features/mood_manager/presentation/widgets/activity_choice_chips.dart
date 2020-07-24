import 'package:flutter/material.dart';
import 'package:chips_choice/chips_choice.dart';
import 'package:mood_manager/features/mood_manager/data/models/m_activity_model.dart';
import 'package:mood_manager/features/mood_manager/data/models/m_activity_type_model.dart';
import 'package:mood_manager/features/mood_manager/presentation/widgets/empty_widget.dart';

class ActivityChoiceChips extends StatefulWidget {
  final Map<String, List<MActivityModel>> groupedActivityList;
  final ValueChanged<MapEntry<String, List<MActivityModel>>> selectOptions;
  final Function save;
  final ValueChanged<String> updateNote;
  Map<String, MActivityTypeModel> activityTypeByCode;

  ActivityChoiceChips(
      {Key key,
      this.groupedActivityList,
      this.selectOptions,
      this.updateNote,
      this.save})
      : super(key: key) {
    this.activityTypeByCode = Map.fromEntries(groupedActivityList.values
        .expand((element) => element)
        .toList()
        .map((e) => e.mActivityType)
        .toSet()
        .map((e) => MapEntry(e.code, e as MActivityTypeModel)));
  }

  @override
  ActivityChoiceChipsState createState() => ActivityChoiceChipsState();
}

class ActivityChoiceChipsState extends State<ActivityChoiceChips> {
  List<MActivityModel> tags = [];
  ScrollController _scrollController = ScrollController();

  Widget buildCircleButton() {
    return RawMaterialButton(
      onPressed: widget.save,
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

  scrollToBottom() {
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      curve: Curves.easeOut,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
        child: ListView(
      physics: AlwaysScrollableScrollPhysics(),
      controller: _scrollController,
      shrinkWrap: true,
      padding: EdgeInsets.all(5),
      children: [
        ...widget.groupedActivityList.keys
            .map((type) => Content(
                  title: widget.activityTypeByCode[type].name,
                  child: FormField<List<MActivityModel>>(
                    autovalidate: true,
                    initialValue: tags,
                    builder: (state) {
                      return Column(
                        children: <Widget>[
                          Container(
                            alignment: Alignment.centerLeft,
                            child: ChipsChoice<MActivityModel>.multiple(
                              value: state.value,
                              options: ChipsChoiceOption.listFrom<
                                  MActivityModel, MActivityModel>(
                                source: widget.groupedActivityList[type],
                                value: (i, v) => v,
                                label: (i, v) => v.name,
                              ),
                              onChanged: (value) => {
                                state.didChange(value),
                                widget.selectOptions(MapEntry(type, value))
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
                                    state.value.length.toString() +
                                        '/5 selected',
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
            .toList(),
        Content(
            child: TextField(
          keyboardType: TextInputType.multiline,
          maxLines: null,
          onChanged: (text) {
            widget.updateNote(text);
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
        SizedBox(height: 20),
        buildCircleButton()
      ],
    ));
  }
}

class CustomChip extends StatelessWidget {
  final String label;
  final bool selected;
  final Function(bool selected) onSelect;

  CustomChip(this.label, this.selected, this.onSelect, {Key key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      height: 100,
      width: 70,
      margin: EdgeInsets.symmetric(
        vertical: 15,
        horizontal: 5,
      ),
      duration: Duration(milliseconds: 300),
      decoration: BoxDecoration(
        color: selected ? Colors.green : Colors.transparent,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: selected ? Colors.green : Colors.grey,
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: () => onSelect(!selected),
        child: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            Visibility(
                visible: selected,
                child: Icon(
                  Icons.check_circle_outline,
                  color: Colors.white,
                  size: 32,
                )),
            Positioned(
              left: 9,
              right: 9,
              bottom: 7,
              child: Container(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: selected ? Colors.white : Colors.black45,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Content extends StatelessWidget {
  final String title;
  final Widget child;

  Content({
    Key key,
    this.title,
    @required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget text = EmptyWidget();
    if (this.title != null) {
      text = Container(
          width: double.infinity,
          padding: EdgeInsets.all(15),
          color: Colors.blueGrey[50],
          child: Text(
            title,
            style: TextStyle(
                fontSize: 20,
                color: Colors.blueGrey,
                fontWeight: FontWeight.bold),
          ));
    }

    return Card(
      elevation: 2,
      margin: EdgeInsets.all(5),
      clipBehavior: Clip.antiAliasWithSaveLayer,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          text,
          child,
        ],
      ),
    );
  }
}
