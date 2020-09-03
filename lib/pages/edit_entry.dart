import 'package:flutter/material.dart';
import 'package:ch13_local_persistence_flutter/classes/database.dart';
import 'package:ch13_local_persistence_flutter/classes/journal.dart';
import 'package:intl/intl.dart';
import 'dart:math';

class EditEntry extends StatefulWidget {
  final bool add;
  final int index;
  final JournalEdit journalEdit;

  const EditEntry({Key key, this.add, this.index, this.journalEdit})
      : super(key: key);

  @override
  _EditEntryState createState() => _EditEntryState();
}

class _EditEntryState extends State<EditEntry> {
  JournalEdit _journalEdit;
  String _title;
  DateTime _selectedDate;
  TextEditingController _moodController = TextEditingController();
  TextEditingController _noteController = TextEditingController();
  FocusNode _moodFocus = FocusNode();
  FocusNode _noteFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    this._journalEdit =
        JournalEdit(action: 'Cancel', journal: widget.journalEdit.journal);
    this._title = widget.add ? 'Add' : 'Edit';
    this._journalEdit.journal = widget.journalEdit.journal;
    if (widget.add) {
      this._selectedDate = DateTime.now();
      this._moodController.text = "";
      this._noteController.text = "";
    } else {
      this._selectedDate = DateTime.parse(this._journalEdit.journal.date);
      this._moodController.text = this._journalEdit.journal.mood;
      this._noteController.text = this._journalEdit.journal.note;
    }
  }

  @override
  void dispose() {
    this._moodController.dispose();
    this._noteController.dispose();
    this._moodFocus.dispose();
    this._noteFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('$_title Entry'),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
          child: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            FlatButton(
                padding: EdgeInsets.all(0.0),
                onPressed: () async {
                  FocusScope.of(context).requestFocus(FocusNode());
                  DateTime _pickerDate = await _selectDate(this._selectedDate);
                  setState(() {
                    this._selectedDate = _pickerDate;
                  });
                },
                child: Row(
                  children: <Widget>[
                    Icon(
                      Icons.calendar_today,
                      size: 22.0,
                      color: Colors.black54,
                    ),
                    SizedBox(
                      width: 16.0,
                    ),
                    Text(
                      DateFormat.yMMMEd().format(this._selectedDate),
                      style: TextStyle(
                        color: Colors.black54,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Icon(
                      Icons.arrow_drop_down,
                      color: Colors.black54,
                    ),
                  ],
                )),
            TextField(
              controller: this._moodController,
              autofocus: true,
              textInputAction: TextInputAction.next,
              focusNode: this._moodFocus,
              textCapitalization: TextCapitalization.words,
              decoration: InputDecoration(
                labelText: 'Mood',
                icon: Icon(Icons.mood),
              ),
              onSubmitted: (submitted) {
                FocusScope.of(context).requestFocus(this._noteFocus);
              },
            ),
            TextField(
              controller: this._noteController,
              textInputAction: TextInputAction.newline,
              focusNode: this._noteFocus,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                labelText: 'Note',
                icon: Icon(Icons.subject),
              ),
              maxLines: null,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                FlatButton(
                  color: Colors.grey.shade100,
                  onPressed: () {
                    this._journalEdit.action = 'Cancel';
                    Navigator.pop(context, this._journalEdit);
                  },
                  child: Text(
                    'Cancel',
                  ),
                ),
                SizedBox(
                  width: 8.0,
                ),
                FlatButton(
                  onPressed: () {
                    this._journalEdit.action = 'Save';
                    String id = widget.add
                        ? Random().nextInt(9999999).toString()
                        : this._journalEdit.journal.id;
                    this._journalEdit.journal = Journal(
                      id: id,
                      date: this._selectedDate.toString(),
                      mood: this._moodController.text,
                      note: this._noteController.text,
                    );
                    Navigator.pop(context, this._journalEdit);
                  },
                  child: Text('Save'),
                  color: Colors.lightGreen.shade100,
                ),
              ],
            )
          ],
        ),
      )),
    );
  }

  Future<DateTime> _selectDate(DateTime selectedDate) async {
    DateTime initialDate = selectedDate;

    final DateTime pickedDate = await showDatePicker(
        context: context,
        initialDate: initialDate,
        firstDate: DateTime.now().subtract(Duration(days: 365)),
        lastDate: DateTime.now().add(Duration(days: 365)));

    if (pickedDate != null) {
      selectedDate = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          pickedDate.hour,
          pickedDate.minute,
          initialDate.second,
          initialDate.millisecond,
          initialDate.microsecond);
    }

    return selectedDate;
  }
}
