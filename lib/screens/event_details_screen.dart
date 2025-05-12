import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/event.dart';
import '../providers/events_provider.dart';
import '../services/llm_service.dart';
import '../widgets/activity_card.dart';
import '../utils/date_utils.dart';
import 'event_form_screen.dart';

class EventDetailsScreen extends StatefulWidget {
  final String eventId;
  const EventDetailsScreen({Key? key, required this.eventId}) : super(key: key);

  @override
  State<EventDetailsScreen> createState() => _EventDetailsScreenState();
}

class _EventDetailsScreenState extends State<EventDetailsScreen> {
  bool _isLoading = false;
  List<String> _eventTips = [];
  
  @override
  void initState() {
    super.initState();
    _loadEventTips();
  }

  Future<void> _loadEventTips() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final eventsProvider = Provider.of<EventsProvider>(context, listen: false);
      final event = eventsProvider.getEventById(widget.eventId);
      
      if (event != null) {
        final tips = await LLMService.generateEventTips(event);
        setState(() {
          _eventTips = tips;
        });
      }
    } catch (e) {
      print('Error loading event tips: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  Future<void> _generateActivities(BuildContext context, Event event) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final activities = await LLMService.generateEventActivities(event);
      
      if (activities.isNotEmpty) {
        final eventsProvider = Provider.of<EventsProvider>(context, listen: false);
        
        // Add each generated activity to the event
        for (final activity in activities) {
          await eventsProvider.addActivityToEvent(event.id, activity);
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Activities generated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to generate activities. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print('Error generating activities: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('An error occurred. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Consumer<EventsProvider>(
      builder: (ctx, eventsProvider, _) {
        final event = eventsProvider.getEventById(widget.eventId);
        
        if (event == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Event Details')),
            body: const Center(child: Text('Event not found')),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('Event Details'),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (ctx) => EventFormScreen(event: event),
                    ),
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () => _showDeleteConfirmationDialog(context, event),
              ),
            ],
          ),
          body: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildEventHeader(context, event),
                      const SizedBox(height: 24),
                      _buildEventDetails(event),
                      const SizedBox(height: 24),
                      _buildEventTipsSection(),
                      const SizedBox(height: 24),
                      _buildActivitiesSection(context, event),
                    ],
                  ),
                ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _generateActivities(context, event),
            icon: const Icon(Icons.auto_awesome),
            label: const Text('Generate Activities'),
          ),
        );
      },
    );
  }

  Widget _buildEventHeader(BuildContext context, Event event) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          event.title,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Chip(
              label: Text(event.eventType),
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
            ),
            const SizedBox(width: 8),
            Chip(
              label: Text('${event.expectedAttendees} attendees'),
              backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
            ),
          ],
        ),
      ],
    );
  }
  Widget _buildEventDetails(Event event) {
    final String formattedDate = EventDateUtils.formatDetailDate(event.date);

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Event Details',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const Divider(),
            const SizedBox(height: 8),
            _buildInfoRow(Icons.description, 'Description', event.description),
            const SizedBox(height: 16),
            _buildInfoRow(Icons.calendar_today, 'Date', formattedDate),
            const SizedBox(height: 16),
            _buildInfoRow(Icons.location_on, 'Location', event.location),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildEventTipsSection() {
    if (_eventTips.isEmpty) {
      return Container();
    }

    return Card(
      elevation: 2,
      color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.lightbulb,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'AI-Generated Tips',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
            const Divider(),
            const SizedBox(height: 8),
            ..._eventTips.map((tip) => _buildTipItem(tip)).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildTipItem(String tip) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check_circle, size: 18, color: Colors.green),
          const SizedBox(width: 8),
          Expanded(
            child: Text(tip),
          ),
        ],
      ),
    );
  }
  Widget _buildActivitiesSection(BuildContext context, Event event) {
    if (event.activities.isEmpty) {
      return Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'No Activities Yet',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Use the "Generate Activities" button to create suggested activities for your event.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Icon(
                Icons.auto_awesome,
                size: 48,
                color: Colors.grey[400],
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Event Activities',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                Text(
                  '${event.activities.length} activities',
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
            const Divider(),
            const SizedBox(height: 8),
            ...event.activities.map((activity) => _buildActivityItem(context, event, activity)).toList(),
          ],
        ),
      ),
    );
  }
  Widget _buildActivityItem(BuildContext context, Event event, EventActivity activity) {
    return ActivityCard(
      activity: activity,
      eventId: event.id,
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context, Event event) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Event'),
        content: const Text('Are you sure you want to delete this event?'),
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
                  .deleteEvent(event.id);
              Navigator.of(ctx).pop();
              Navigator.of(context).pop();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}