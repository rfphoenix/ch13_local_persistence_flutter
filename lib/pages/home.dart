import 'package:flutter/material.dart';
import 'package:ch13_local_persistence_flutter/classes/journal.dart';
import 'package:ch13_local_persistence_flutter/pages/edit_entry.dart';
import 'package:ch13_local_persistence_flutter/classes/database.dart';
import 'package:intl/intl.dart';

class Home extends StatefulWidget {
  const Home({Key key, @required this.title}) : super(key: key);
  final String title;

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  Database _database;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: FutureBuilder(
          initialData: [],
          future: _loadJournals(),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            return !snapshot.hasData
                ? Center(
                    child: CircularProgressIndicator(),
                  )
                : _buildListViewSeparated(snapshot);
          }),
      bottomNavigationBar: BottomAppBar(
        shape: CircularNotchedRectangle(),
        child: Padding(padding: const EdgeInsets.all(24.0)),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
          tooltip: 'Add Journal Entry',
          child: Icon(Icons.add),
          onPressed: () {
            this._addOrEditJournal(add: true, index: -1, journal: Journal());
          }),
    );
  }

  Future<List<Journal>> _loadJournals() async {
    await DatabaseFileRoutines().readJournals().then((journalsJson) {
      this._database = DatabaseFileRoutines().databaseFromJson(journalsJson);
      this
          ._database
          .journal
          .sort((comp1, comp2) => comp2.date.compareTo(comp1.date));
    });

    return this._database.journal;
  }

  void _addOrEditJournal({bool add, int index, Journal journal}) async {
    JournalEdit journalEdit = JournalEdit(action: '', journal: journal);

    journalEdit = await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => EditEntry(
                add: add,
                index: index,
                journalEdit: journalEdit,
              ),
          fullscreenDialog: true),
    );
    switch (journalEdit.action) {
      case 'Save':
        if (add) {
          setState(() {
            this._database.journal.add(journalEdit.journal);
          });
        } else {
          setState(() {
            this._database.journal[index] = journalEdit.journal;
          });
        }
        DatabaseFileRoutines().writeJournals(
            DatabaseFileRoutines().databaseToJson(this._database));
        break;
      case 'Cancel':
        break;
      default:
        break;
    }
  }

  Widget _buildListViewSeparated(AsyncSnapshot snapshot) {
    return ListView.separated(
        itemBuilder: (BuildContext context, int index) {
          String titleDate = DateFormat.yMMMd()
              .format(DateTime.parse(snapshot.data[index].date));
          String subtitle =
              snapshot.data[index].mood + "\n" + snapshot.data[index].note;
          return Dismissible(
            key: Key(snapshot.data[index].id),
            background: Container(
              color: Colors.red,
              alignment: Alignment.centerLeft,
              padding: EdgeInsets.only(left: 16.0),
              child: Icon(
                Icons.delete,
                color: Colors.white,
              ),
            ),
            secondaryBackground: Container(
              color: Colors.red,
              alignment: Alignment.centerRight,
              padding: EdgeInsets.only(right: 16.0),
              child: Icon(
                Icons.delete,
                color: Colors.white,
              ),
            ),
            child: ListTile(
              leading: Column(
                children: <Widget>[
                  Text(
                    DateFormat.d()
                        .format(DateTime.parse(snapshot.data[index].date)),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 32.0,
                      color: Colors.blue,
                    ),
                  ),
                  Text(DateFormat.E()
                      .format(DateTime.parse(snapshot.data[index].date))),
                ],
              ),
              title: Text(
                titleDate,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(subtitle),
              onTap: () {
                this._addOrEditJournal(
                  add: false,
                  index: index,
                  journal: snapshot.data[index],
                );
              },
            ),
            onDismissed: (direction) {
              setState(() {
                this._database.journal.removeAt(index);
              });
              DatabaseFileRoutines().writeJournals(
                  DatabaseFileRoutines().databaseToJson(this._database));
            },
          );
        },
        separatorBuilder: (BuildContext context, int index) {
          return Divider(
            color: Colors.grey,
          );
        },
        itemCount: snapshot.data.length);
  }
}
