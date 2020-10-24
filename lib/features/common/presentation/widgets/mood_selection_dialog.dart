import 'package:flutter/material.dart';
import 'package:mood_manager/features/metadata/domain/entities/m_mood.dart';
import 'package:mood_manager/features/mood_manager/presentation/widgets/radio_selection.dart';
import 'package:mood_manager/features/common/presentation/widgets/scroll_select.dart';

class MoodSelectionDialog extends StatefulWidget {
  List<MMood> moodList;
  List<MMood> subMoodList = [];
  MMood selectedMood;
  MMood selectedSubMood;
  final ValueChanged<MMood> saveCallback;
  MoodSelectionDialog({
    @required this.moodList,
    @required this.saveCallback,
    @required this.selectedMood,
  }) {
    this.selectedSubMood = selectedMood;
    if (this.selectedSubMood != null) {
      final mood = moodList.firstWhere((element) =>
          [element, ...element.mMoodList].contains(this.selectedSubMood));
      this.subMoodList = [mood, ...mood.mMoodList];
      selectedMood = mood;
    }
  }

  @override
  State<StatefulWidget> createState() => _MoodSelectionDialogState();
}

class _MoodSelectionDialogState extends State<MoodSelectionDialog> {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      elevation: 0.0,
      backgroundColor: Colors.transparent,
      child: dialogContent2(context),
    );
  }

  /*dialogContent(BuildContext context) {
    return Stack(
      children: <Widget>[
        Container(
          padding: EdgeInsets.only(
            top: 66.0 + 16.0,
            bottom: 16.0,
            left: 16.0,
            right: 16.0,
          ),
          margin: EdgeInsets.only(top: 66.0),
          decoration: new BoxDecoration(
            color: Colors.white,
            shape: BoxShape.rectangle,
            borderRadius: BorderRadius.circular(16.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 10.0,
                offset: const Offset(0.0, 10.0),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min, // To make the card compact
            children: <Widget>[
              Text(
                title,
                style: TextStyle(
                  fontSize: 24.0,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 16.0),
              Text(
                description,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16.0,
                ),
              ),
              SizedBox(height: 24.0),
              Align(
                alignment: Alignment.bottomRight,
                child: FlatButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // To close the dialog
                  },
                  child: Text(buttonText),
                ),
              ),
            ],
          ),
        ),
        Positioned(
          left: 16.0,
          right: 16.0,
          child: CircleAvatar(
            backgroundColor: Colors.blueAccent,
            radius: 66.0,
          ),
        ),
      ],
    );
  }*/

  dialogContent2(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 120),
      child: ListView(
        children: [
          RadioSelection(
            moodList: widget.moodList,
            initialValue: widget.selectedMood,
            initialSubValue: widget.selectedSubMood,
            onChange: updateState,
            parentCircleColor: Colors.blueGrey[50],
            parentCircleRadius: 120,
            showLabel: false,
          ),
          SizedBox(
            height: 20,
          ),
          Container(
            padding: EdgeInsets.all(10.0),
            width: 100,
            height: widget.selectedMood != null && widget.subMoodList.length > 0
                ? 120
                : 70,
            decoration: new BoxDecoration(
              color: Colors.white,
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.circular(16.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10.0,
                  offset: const Offset(0.0, 10.0),
                ),
              ],
            ),
            child: Column(
              children: [
                if (widget.selectedMood != null &&
                    widget.subMoodList.length > 0)
                  ScrollSelect<MMood>(
                      scrollDirection: ScrollDirection.horizontal,
                      onChanged: (mMood) {
                        setState(() {
                          widget.selectedSubMood = mMood;
                        });
                      },
                      options: ScrollSelectOption.listFrom<MMood, MMood>(
                          source: widget.subMoodList,
                          value: (i, v) => v,
                          label: (i, v) => v.moodName.toUpperCase(),
                          color: (i, v) => v.color),
                      initialValue: widget.selectedSubMood,
                      itemFontSize: 18,
                      height: 50,
                      itemExtent: 125,
                      backgroundColor: Colors.white.withOpacity(0.0)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                        icon: Icon(
                          Icons.close,
                          color: Colors.grey,
                        ),
                        onPressed: () {
                          Navigator.of(context).pop();
                        }),
                    SizedBox(
                      width: 80,
                    ),
                    IconButton(
                        icon: Icon(
                          Icons.check,
                        ),
                        onPressed: () {
                          widget.saveCallback(widget.selectedSubMood);
                          Navigator.of(context).pop();
                        })
                  ],
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  updateState(value) {
    setState(() {
      widget.selectedMood = value;
      widget.subMoodList = [value, ...value.mMoodList];
      widget.selectedSubMood = value;
    });
  }
}
