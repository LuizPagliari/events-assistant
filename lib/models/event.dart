import 'package:uuid/uuid.dart';

class Event {
  final String id;
  final String title;
  final String description;
  final DateTime date;
  final String location;
  final String eventType;
  final int expectedAttendees;
  final List<EventActivity> activities;

  Event({
    String? id,
    required this.title,
    required this.description,
    required this.date,
    required this.location,
    required this.eventType,
    required this.expectedAttendees,
    List<EventActivity>? activities,
  })  : id = id ?? const Uuid().v4(),
        activities = activities ?? [];

  // Create a copy of this event with modified properties
  Event copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? date,
    String? location,
    String? eventType,
    int? expectedAttendees,
    List<EventActivity>? activities,
  }) {
    return Event(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      date: date ?? this.date,
      location: location ?? this.location,
      eventType: eventType ?? this.eventType,
      expectedAttendees: expectedAttendees ?? this.expectedAttendees,
      activities: activities ?? this.activities,
    );
  }

  // Convert Event to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'date': date.toIso8601String(),
      'location': location,
      'eventType': eventType,
      'expectedAttendees': expectedAttendees,
      'activities': activities.map((activity) => activity.toJson()).toList(),
    };
  }

  // Create Event from JSON
  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      date: DateTime.parse(json['date']),
      location: json['location'],
      eventType: json['eventType'],
      expectedAttendees: json['expectedAttendees'],
      activities: (json['activities'] as List)
          .map((activityJson) => EventActivity.fromJson(activityJson))
          .toList(),
    );
  }
}

class EventActivity {
  final String id;
  final String name;
  final String description;
  final DateTime startTime;
  final DateTime endTime;
  final bool isCompleted;

  EventActivity({
    String? id,
    required this.name,
    required this.description,
    required this.startTime,
    required this.endTime,
    this.isCompleted = false,
  }) : id = id ?? const Uuid().v4();

  // Create a copy of this activity with modified properties
  EventActivity copyWith({
    String? id,
    String? name,
    String? description,
    DateTime? startTime,
    DateTime? endTime,
    bool? isCompleted,
  }) {
    return EventActivity(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  // Convert EventActivity to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'isCompleted': isCompleted,
    };
  }

  // Create EventActivity from JSON
  factory EventActivity.fromJson(Map<String, dynamic> json) {
    return EventActivity(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      startTime: DateTime.parse(json['startTime']),
      endTime: DateTime.parse(json['endTime']),
      isCompleted: json['isCompleted'] ?? false,
    );
  }
}