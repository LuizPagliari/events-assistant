import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/event.dart';

class EventsProvider with ChangeNotifier {
  List<Event> _events = [];
  final String _storageKey = 'events';

  List<Event> get events => [..._events];

  EventsProvider() {
    _loadEvents();
  }

  // Load events from SharedPreferences
  Future<void> _loadEvents() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey(_storageKey)) {
      final String? eventsJson = prefs.getString(_storageKey);
      if (eventsJson != null) {
        final List<dynamic> decodedList = jsonDecode(eventsJson);
        _events = decodedList
            .map((item) => Event.fromJson(item))
            .toList();
        notifyListeners();
      }
    }
  }

  // Save events to SharedPreferences
  Future<void> _saveEvents() async {
    final prefs = await SharedPreferences.getInstance();
    final String encodedData = jsonEncode(_events.map((e) => e.toJson()).toList());
    await prefs.setString(_storageKey, encodedData);
  }

  // Add a new event
  Future<void> addEvent(Event event) async {
    _events.add(event);
    notifyListeners();
    await _saveEvents();
  }

  // Update an existing event
  Future<void> updateEvent(Event updatedEvent) async {
    final eventIndex = _events.indexWhere((event) => event.id == updatedEvent.id);
    if (eventIndex >= 0) {
      _events[eventIndex] = updatedEvent;
      notifyListeners();
      await _saveEvents();
    }
  }

  // Delete an event
  Future<void> deleteEvent(String id) async {
    _events.removeWhere((event) => event.id == id);
    notifyListeners();
    await _saveEvents();
  }

  // Get a specific event by ID
  Event? getEventById(String id) {
    try {
      return _events.firstWhere((event) => event.id == id);
    } catch (e) {
      return null;
    }
  }

  // Add an activity to an event
  Future<void> addActivityToEvent(String eventId, EventActivity activity) async {
    final eventIndex = _events.indexWhere((event) => event.id == eventId);
    if (eventIndex >= 0) {
      _events[eventIndex].activities.add(activity);
      notifyListeners();
      await _saveEvents();
    }
  }

  // Update an activity in an event
  Future<void> updateEventActivity(
      String eventId, EventActivity updatedActivity) async {
    final eventIndex = _events.indexWhere((event) => event.id == eventId);
    if (eventIndex >= 0) {
      final activityIndex = _events[eventIndex].activities
          .indexWhere((activity) => activity.id == updatedActivity.id);
      if (activityIndex >= 0) {
        _events[eventIndex].activities[activityIndex] = updatedActivity;
        notifyListeners();
        await _saveEvents();
      }
    }
  }

  // Delete an activity from an event
  Future<void> deleteEventActivity(String eventId, String activityId) async {
    final eventIndex = _events.indexWhere((event) => event.id == eventId);
    if (eventIndex >= 0) {
      _events[eventIndex].activities.removeWhere((activity) => activity.id == activityId);
      notifyListeners();
      await _saveEvents();
    }
  }
}