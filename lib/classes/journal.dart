class Journal {
  String id;
  String date;
  String mood;
  String note;

  Journal({this.id, this.date, this.mood, this.note});

  factory Journal.fromJson(Map<String, dynamic> json) => Journal(
        id: json["id"],
        date: json["date"],
        mood: json["mood"],
        note: json["note"],
      );

  Map<String, dynamic> toJson() => {
        "id": this.id,
        "date": this.date,
        "mood": this.mood,
        "note": this.note,
      };
}

class JournalEdit {
  String action;
  Journal journal;

  JournalEdit({this.action, this.journal});
}
