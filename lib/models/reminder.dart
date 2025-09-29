class Reminder {
  final String title;
  final String description;
  final DateTime dateTime;

  Reminder({
    required this.title,
    required this.description,
    required this.dateTime,
  });

  factory Reminder.fromJson(Map<String, dynamic> json) {
    return Reminder(
      title: json['title'] as String,
      description: json['description'] as String,
      dateTime: DateTime.parse(json['date_time'] as String),
    );
  }
}
