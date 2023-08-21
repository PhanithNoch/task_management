class Task {
  int? id;
  String? title;
  int? isDone;
  String? date;

  Task({this.id, this.title, this.isDone, this.date});

  Task.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    isDone = json['isDone'];
    date = json['date'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['title'] = this.title;
    data['isDone'] = this.isDone;
    data['date'] = this.date;
    return data;
  }
}
