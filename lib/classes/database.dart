import 'package:path_provider/path_provider.dart'; // Filesystem location
import 'dart:io'; // Used by File
import 'dart:convert'; // Used by Json
import 'journal.dart';

class DatabaseFileRoutines {
  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();

    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;

    return File('$path/local_persistence.json');
  }

  Future<String> readJournals() async {
    try {
      final file = await _localFile;

      if (!file.existsSync()) {
        print('File does not Exist: ${file.absolute}');
        await writeJournals('{"journals": []}');
      }

      String contents = await file.readAsString();

      return contents;
    } catch (e) {
      print("error readJournals: $e");
      return "";
    }
  }

  Future<File> writeJournals(String json) async {
    final file = await this._localFile;

    return file.writeAsString('$json');
  }

  Database databaseFromJson(String str) {
    final dataFromJson = json.decode(str);

    return Database.fromJson(dataFromJson);
  }

  String databaseToJson(Database data) {
    final dataToJson = data.toJson();

    return json.encode(dataToJson);
  }
}

class Database {
  List<Journal> journal;

  Database({
    this.journal,
  });

  factory Database.fromJson(Map<String, dynamic> json) => Database(
        journal: List<Journal>.from(
            json["journals"].map((x) => Journal.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "journals": List<dynamic>.from(journal.map((x) => x.toJson())),
      };
}
