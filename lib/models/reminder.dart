class Reminder {
  final dynamic id; // id can be int or String depending on Supabase
  final String title;
  final String description;
  final DateTime dateTime;
  final String status; // 'pending', 'completed', 'missed', 'past'
  final String? petId;

  Reminder({
    required this.id,
    required this.title,
    required this.description,
    required this.dateTime,
    this.status = 'pending',
    this.petId,
  });

  factory Reminder.fromJson(Map<String, dynamic> json) {
    return Reminder(
      id: json['id'],
      title: json['title'] as String? ?? 'Untitled Reminder',
      description: json['description'] as String? ?? 'No description',
      dateTime: DateTime.parse(json['date_time'] as String? ?? DateTime.now().toIso8601String()),
      status: json['status'] as String? ?? 'pending',
      petId: json['pet_id'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'date_time': dateTime.toIso8601String(),
      'status': status,
      'pet_id': petId,
    };
  }
}
