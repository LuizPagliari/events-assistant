import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/event.dart';
import '../providers/events_provider.dart';
import '../utils/date_utils.dart';

class ActivityCard extends StatelessWidget {
  final EventActivity activity;
  final String eventId;
  final bool isEditable;

  const ActivityCard({
    Key? key,
    required this.activity,
    required this.eventId,
    this.isEditable = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final timeRange = EventDateUtils.formatTimeRange(
      activity.startTime, 
      activity.endTime
    );

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    activity.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                if (isEditable)
                  Checkbox(
                    value: activity.isCompleted,
                    onChanged: (value) => _updateActivityStatus(context, value),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Text(activity.description),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.access_time, size: 14, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  timeRange,
                  style: const TextStyle(color: Colors.grey),
                ),
                const Spacer(),
                if (isEditable)
                  IconButton(
                    icon: const Icon(Icons.delete, size: 20),
                    color: Colors.red.shade300,
                    onPressed: () => _deleteActivity(context),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _updateActivityStatus(BuildContext context, bool? value) {
    if (value != null) {
      final updatedActivity = EventActivity(
        id: activity.id,
        name: activity.name,
        description: activity.description,
        startTime: activity.startTime,
        endTime: activity.endTime,
        isCompleted: value,
      );
      
      Provider.of<EventsProvider>(context, listen: false)
          .updateEventActivity(eventId, updatedActivity);
    }
  }

  void _deleteActivity(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Activity'),
        content: const Text('Are you sure you want to delete this activity?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Provider.of<EventsProvider>(context, listen: false)
                  .deleteEventActivity(eventId, activity.id);
              Navigator.of(ctx).pop();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}