import 'package:flutter/material.dart';
import 'package:chips_choice/chips_choice.dart';
import 'package:mood_manager/features/metadata/domain/entities/m_activity.dart';
import 'package:mood_manager/features/metadata/domain/entities/m_activity_type.dart';

class ActivityChoiceChips extends StatefulWidget {
  final ValueChanged<MapEntry<String, List<MActivity>>> selectOptions;
  final Function save;
  final ValueChanged<String> updateNote;
  final int maxSelected;
  final List<MActivity> selected;
  final List<MActivityType> activityTypeList;
  final Map<String, List<MActivity>> initialValue;
  final Color color;

  ActivityChoiceChips(
      {Key key,
      this.selectOptions,
      this.updateNote,
      this.save,
      this.activityTypeList,
      this.maxSelected,
      this.selected,
      this.initialValue,
      this.color})
      : super(key: key);

  @override
  ActivityChoiceChipsState createState() => ActivityChoiceChipsState();
}

class ActivityChoiceChipsState extends State<ActivityChoiceChips> {
  ScrollController _scrollController = ScrollController();

  Widget buildCircleButton() {
    return RawMaterialButton(
      onPressed: widget.save,
      elevation: 2.0,
      fillColor: widget.color,
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
        Content(
            color: widget.color,
            title: 'Tell us about your activity',
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
                  fillColor: widget.color,
                  border: InputBorder.none,
                  hintText: 'Add Note...'),
            )),
        ...widget.activityTypeList
            .map((type) => Content(
                color: widget.color,
                title: type.activityTypeName,
                child: FormField<List<MActivity>>(
                    autovalidate: true,
                    initialValue: widget.initialValue[type.activityTypeCode],
                    builder: (state) {
                      return ChoiceChipsByType(
                          activityList: type.mActivityList,
                          mActivityTypeCode: type.activityTypeCode,
                          selectOptions: widget.selectOptions,
                          state: state,
                          maxReached:
                              widget.maxSelected == widget.selected.length,
                          selected: widget.selected,
                          color: widget.color);
                    })))
            .toList(),
        SizedBox(height: 20),
        buildCircleButton()
      ],
    ));
  }
}

class ChoiceChipsByType extends StatelessWidget {
  const ChoiceChipsByType(
      {Key key,
      @required this.state,
      @required this.mActivityTypeCode,
      @required this.selectOptions,
      @required this.activityList,
      this.maxReached = false,
      this.selected,
      this.color})
      : super(key: key);

  final FormFieldState state;
  final String mActivityTypeCode;
  final Function selectOptions;
  final List<MActivity> activityList;
  final List<MActivity> selected;
  final bool maxReached;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.centerLeft,
      child: ChipsChoice<MActivity>.multiple(
        value: state.value,
        options: ChipsChoiceOption.listFrom<MActivity, MActivity>(
          disabled: (index, item) => maxReached && !selected.contains(item),
          source: activityList,
          value: (i, v) => v,
          label: (i, v) => v.activityName,
        ),
        onChanged: (value) => {
          state.didChange(value),
          selectOptions(MapEntry(mActivityTypeCode, value))
        },
        isWrapped: true,
      ),
    );
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
  final Color color;

  Content({Key key, this.title, @required this.child, this.color})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ExpansionTile(
          initiallyExpanded: true,
          title: Text(
            title,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          children: <Widget>[
            Container(color: Colors.white, child: child),
          ],
        ),
        Divider(
          height: 0,
        )
      ],
    );
  }
}
