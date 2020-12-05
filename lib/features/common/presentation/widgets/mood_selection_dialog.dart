import 'package:flutter/material.dart';
import 'package:mood_manager/features/metadata/domain/entities/m_mood.dart';
import 'package:mood_manager/features/mood_manager/presentation/widgets/radio_selection.dart';
import 'package:mood_manager/features/common/presentation/widgets/scroll_select.dart';

// ignore: must_be_immutable
class MoodSelectionPage extends StatefulWidget {
  List<MMood> moodList;
  List<MMood> subMoodList = [];
  MMood selectedMood;
  MMood selectedSubMood;
  final ValueChanged<MMood> saveCallback;
  MoodSelectionPage({
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
  State<StatefulWidget> createState() => _MoodSelectionPageState();
}

class _MoodSelectionPageState extends State<MoodSelectionPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: buildMoodSelection(context),
      backgroundColor: Colors.black.withOpacity(0.7),
    );
  }

  buildMoodSelection(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10),
      child: ListView(
        children: [
          SizedBox(
            height: (MediaQuery.of(context).size.height - 120) / 4,
          ),
          RadioSelection(
            moodList: widget.moodList,
            initialValue: widget.selectedMood,
            initialSubValue: widget.selectedSubMood,
            onChange: updateState,
            parentCircleColor: Colors.blueGrey[50],
            parentCircleRadius: 120,
            showLabel: false,
            showClear: true,
          ),
          SizedBox(
            height: 20,
          ),
          Container(
            padding: EdgeInsets.all(10.0),
            width: 100,
            height: 120,
            decoration: BoxDecoration(
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
                if (!(widget.selectedMood != null &&
                    widget.subMoodList.length > 0))
                  SizedBox(
                    height: 50,
                    child: Center(
                        child: Text(
                      'Tap on circle to select',
                      style: TextStyle(
                          fontSize: 18, color: Colors.black.withOpacity(0.5)),
                    )),
                  ),
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
      widget.selectedSubMood = value;
      if (value != null) {
        widget.subMoodList = [value, ...value.mMoodList];
      } else {
        widget.subMoodList = [];
      }
    });
  }
}
