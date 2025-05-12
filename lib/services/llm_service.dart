import 'dart:convert';
import 'package:dart_openai/dart_openai.dart';
import '../models/event.dart';

class LLMService {
  // Initialize with your OpenAI API key
  static Future<void> init(String apiKey) async {
    OpenAI.apiKey = apiKey;
  }
  // Generate event activity suggestions based on event type and details
  static Future<List<EventActivity>> generateEventActivities(Event event) async {
    try {
      final prompt = _generatePromptForEventActivities(event);
      
      final chatCompletion = await OpenAI.instance.chat.create(
        model: "gpt-3.5-turbo",
        messages: [
          OpenAIChatCompletionChoiceMessageModel(
            role: OpenAIChatMessageRole.system,
            content: [
              OpenAIChatCompletionChoiceMessageContentItemModel.text(
                "You are an event planning assistant that generates detailed event schedules and activities. Respond with a JSON array of activities."
              )
            ],
          ),
          OpenAIChatCompletionChoiceMessageModel(
            role: OpenAIChatMessageRole.user, 
            content: [
              OpenAIChatCompletionChoiceMessageContentItemModel.text(prompt)
            ],
          ),
        ],
      );

      final contentItems = chatCompletion.choices.first.message.content;
      String content = '';
      
      if (contentItems != null) {
        // Extract text content from all items
        content = contentItems
            .where((item) => item.type == 'text')
            .map((item) => item.text)
            .join(' ');
      }
      
      // Parse the JSON response into a list of activities
      return _parseActivitiesFromResponse(content, event.date);
    } catch (e) {
      print('Error generating event activities: $e');
      // Return simulated activities when API fails
      return _getSimulatedActivities(event);
    }
  }

  // Generate simulated activities based on event type when API fails
  static List<EventActivity> _getSimulatedActivities(Event event) {
    final List<EventActivity> activities = [];
    final DateTime eventDate = event.date;
    
    // Base time to start activities (adjust based on event type)
    DateTime baseTime = DateTime(
      eventDate.year,
      eventDate.month,
      eventDate.day,
      event.eventType.toLowerCase() == 'party' ? 18 : 9, // Start evening or morning
      0,
    );
    
    // Generate activities based on event type
    switch(event.eventType.toLowerCase()) {
      case 'party':
        activities.add(EventActivity(
          name: 'Guest Arrival',
          description: 'Welcome guests and offer initial drinks',
          startTime: baseTime,
          endTime: baseTime.add(const Duration(hours: 1)),
        ));
        
        activities.add(EventActivity(
          name: 'Main Activity',
          description: 'Games, dancing or main entertainment',
          startTime: baseTime.add(const Duration(hours: 1)),
          endTime: baseTime.add(const Duration(hours: 2, minutes: 30)),
        ));
        
        activities.add(EventActivity(
          name: 'Food Service',
          description: 'Serve main course and refreshments',
          startTime: baseTime.add(const Duration(hours: 2, minutes: 30)),
          endTime: baseTime.add(const Duration(hours: 3, minutes: 30)),
        ));
        
        activities.add(EventActivity(
          name: 'Special Moment',
          description: 'Cake cutting, toast, or special performance',
          startTime: baseTime.add(const Duration(hours: 3, minutes: 45)),
          endTime: baseTime.add(const Duration(hours: 4, minutes: 15)),
        ));
        
        activities.add(EventActivity(
          name: 'Farewell',
          description: 'Thank guests and distribute party favors',
          startTime: baseTime.add(const Duration(hours: 5)),
          endTime: baseTime.add(const Duration(hours: 5, minutes: 30)),
        ));
        break;
        
      case 'meeting':
        activities.add(EventActivity(
          name: 'Welcome and Introduction',
          description: 'Overview of meeting agenda and goals',
          startTime: baseTime,
          endTime: baseTime.add(const Duration(minutes: 15)),
        ));
        
        activities.add(EventActivity(
          name: 'Topic Discussion 1',
          description: 'Discussion of first major topic',
          startTime: baseTime.add(const Duration(minutes: 15)),
          endTime: baseTime.add(const Duration(minutes: 45)),
        ));
        
        activities.add(EventActivity(
          name: 'Break',
          description: 'Short refreshment break',
          startTime: baseTime.add(const Duration(minutes: 45)),
          endTime: baseTime.add(const Duration(hours: 1)),
        ));
        
        activities.add(EventActivity(
          name: 'Topic Discussion 2',
          description: 'Discussion of second major topic',
          startTime: baseTime.add(const Duration(hours: 1)),
          endTime: baseTime.add(const Duration(hours: 1, minutes: 30)),
        ));
        
        activities.add(EventActivity(
          name: 'Conclusion and Action Items',
          description: 'Summarize decisions and assign action items',
          startTime: baseTime.add(const Duration(hours: 1, minutes: 30)),
          endTime: baseTime.add(const Duration(hours: 1, minutes: 45)),
        ));
        break;
        
      case 'conference':
        activities.add(EventActivity(
          name: 'Registration',
          description: 'Check-in and welcome packet distribution',
          startTime: baseTime,
          endTime: baseTime.add(const Duration(hours: 1)),
        ));
        
        activities.add(EventActivity(
          name: 'Opening Keynote',
          description: 'Main conference theme and introduction',
          startTime: baseTime.add(const Duration(hours: 1)),
          endTime: baseTime.add(const Duration(hours: 2)),
        ));
        
        activities.add(EventActivity(
          name: 'Workshop Sessions',
          description: 'Parallel workshop tracks on various topics',
          startTime: baseTime.add(const Duration(hours: 2, minutes: 15)),
          endTime: baseTime.add(const Duration(hours: 4)),
        ));
        
        activities.add(EventActivity(
          name: 'Networking Lunch',
          description: 'Catered lunch with networking opportunities',
          startTime: baseTime.add(const Duration(hours: 4)),
          endTime: baseTime.add(const Duration(hours: 5)),
        ));
        
        activities.add(EventActivity(
          name: 'Closing Panel',
          description: 'Expert panel discussing industry trends',
          startTime: baseTime.add(const Duration(hours: 5, minutes: 15)),
          endTime: baseTime.add(const Duration(hours: 6, minutes: 15)),
        ));
        break;
        
      case 'birthday':
        activities.add(EventActivity(
          name: 'Guest Arrival',
          description: 'Welcome guests and initial socializing',
          startTime: baseTime,
          endTime: baseTime.add(const Duration(minutes: 45)),
        ));
        
        activities.add(EventActivity(
          name: 'Games & Activities',
          description: 'Fun games and entertainment for guests',
          startTime: baseTime.add(const Duration(minutes: 45)),
          endTime: baseTime.add(const Duration(hours: 1, minutes: 45)),
        ));
        
        activities.add(EventActivity(
          name: 'Cake Ceremony',
          description: 'Cake cutting and happy birthday song',
          startTime: baseTime.add(const Duration(hours: 1, minutes: 45)),
          endTime: baseTime.add(const Duration(hours: 2, minutes: 15)),
        ));
        
        activities.add(EventActivity(
          name: 'Food Service',
          description: 'Serve food and refreshments',
          startTime: baseTime.add(const Duration(hours: 2, minutes: 15)),
          endTime: baseTime.add(const Duration(hours: 3)),
        ));
        
        activities.add(EventActivity(
          name: 'Gift Opening',
          description: 'Opening presents and thank you',
          startTime: baseTime.add(const Duration(hours: 3)),
          endTime: baseTime.add(const Duration(hours: 3, minutes: 45)),
        ));
        break;
        
      default:
        activities.add(EventActivity(
          name: 'Welcome',
          description: 'Welcome participants to the event',
          startTime: baseTime,
          endTime: baseTime.add(const Duration(minutes: 30)),
        ));
        
        activities.add(EventActivity(
          name: 'Main Activity 1',
          description: 'First primary activity of the event',
          startTime: baseTime.add(const Duration(minutes: 30)),
          endTime: baseTime.add(const Duration(hours: 1, minutes: 30)),
        ));
        
        activities.add(EventActivity(
          name: 'Break',
          description: 'Refreshment and networking break',
          startTime: baseTime.add(const Duration(hours: 1, minutes: 30)),
          endTime: baseTime.add(const Duration(hours: 2)),
        ));
        
        activities.add(EventActivity(
          name: 'Main Activity 2',
          description: 'Second primary activity of the event',
          startTime: baseTime.add(const Duration(hours: 2)),
          endTime: baseTime.add(const Duration(hours: 3)),
        ));
        
        activities.add(EventActivity(
          name: 'Conclusion',
          description: 'Wrap up and closing remarks',
          startTime: baseTime.add(const Duration(hours: 3)),
          endTime: baseTime.add(const Duration(hours: 3, minutes: 30)),
        ));
    }
    
    return activities;
  }

  // Parse the LLM response into EventActivity objects
  static List<EventActivity> _parseActivitiesFromResponse(String response, DateTime eventDate) {
    List<EventActivity> activities = [];
    
    try {
      // Clean up the response to extract only the JSON array part
      String jsonStr = response;
      if (response.contains('[') && response.contains(']')) {
        jsonStr = response.substring(
          response.indexOf('['),
          response.lastIndexOf(']') + 1,
        );
      }
      
      // Parse the JSON
      List<dynamic> jsonActivities = [];
      try {
        jsonActivities = jsonDecode(jsonStr) as List<dynamic>;
      } catch (e) {
        print('Error parsing JSON: $e');
        return activities;
      }
      
      // Convert to EventActivity objects
      for (var item in jsonActivities) {
        DateTime startTime = _parseTimeString(item['startTime'], eventDate);
        DateTime endTime = _parseTimeString(item['endTime'], eventDate);
        
        activities.add(
          EventActivity(
            name: item['name'],
            description: item['description'],
            startTime: startTime,
            endTime: endTime,
          ),
        );
      }
    } catch (e) {
      print('Error parsing activities: $e');
    }
    
    return activities;
  }

  // Helper to parse time strings from the LLM response
  static DateTime _parseTimeString(String timeStr, DateTime eventDate) {
    try {
      // Expected format: "HH:MM" or "HH:MM AM/PM"
      List<String> parts = timeStr.split(':');
      int hour = int.parse(parts[0]);
      
      String minutePart = parts[1];
      int minute = int.parse(minutePart.split(' ')[0]);
      
      // Check if AM/PM is specified
      bool isPM = minutePart.toLowerCase().contains('pm');
      if (isPM && hour < 12) hour += 12;
      if (!isPM && hour == 12) hour = 0;
      
      return DateTime(
        eventDate.year,
        eventDate.month,
        eventDate.day,
        hour,
        minute,
      );
    } catch (e) {
      // If parsing fails, return the event date
      return eventDate;
    }
  }

  // Generate prompt for the LLM
  static String _generatePromptForEventActivities(Event event) {
    return """
    Generate a detailed schedule of activities for a ${event.eventType} event with the following details:
    
    Title: ${event.title}
    Description: ${event.description}
    Date: ${event.date.toString().split(' ')[0]}
    Location: ${event.location}
    Number of attendees: ${event.expectedAttendees}
    
    Please provide a list of activities in the following JSON format:
    [
      {
        "name": "Activity name",
        "description": "Brief description",
        "startTime": "HH:MM",
        "endTime": "HH:MM"
      },
      ...
    ]
    
    Please provide at least 5 activities that would be appropriate for this type of event.
    Make sure the schedule is realistic and the activities flow well together.
    """;
  }

  // Generate event tips based on event type
  static Future<List<String>> generateEventTips(Event event) async {
    try {
      final prompt = """
      Provide 5 helpful tips for organizing a ${event.eventType} event with ${event.expectedAttendees} attendees at ${event.location}.
      The event is "${event.title}" and is described as: "${event.description}".
      Format the response as a JSON array of strings, each containing one tip.
      """;

      final chatCompletion = await OpenAI.instance.chat.create(
        model: "gpt-3.5-turbo",
        messages: [
          OpenAIChatCompletionChoiceMessageModel(
            role: OpenAIChatMessageRole.system,
            content: [
              OpenAIChatCompletionChoiceMessageContentItemModel.text(
                "You are an event planning assistant that provides practical tips for event organizers."
              )
            ],
          ),
          OpenAIChatCompletionChoiceMessageModel(
            role: OpenAIChatMessageRole.user, 
            content: [
              OpenAIChatCompletionChoiceMessageContentItemModel.text(prompt)
            ],
          ),
        ],
      );

      final contentItems = chatCompletion.choices.first.message.content;
      String content = '';
      
      if (contentItems != null) {
        // Extract text content from all items
        content = contentItems
            .where((item) => item.type == 'text')
            .map((item) => item.text)
            .join(' ');
      }
      
      // Parse the JSON response
      return _parseTipsFromResponse(content);
    } catch (e) {
      print('Error generating event tips: $e');
      // Return default tips when API fails
      return _getSimulatedTips(event);
    }
  }

  // Generate simulated tips based on event type when API fails
  static List<String> _getSimulatedTips(Event event) {
    final Map<String, List<String>> tipsByType = {
      'party': [
        "Create a detailed guest list with RSVPs to accurately plan for food and space.",
        "Prepare a playlist in advance that matches the party mood and audience.",
        "Set up different activity zones to keep guests engaged throughout the event.",
        "Consider dietary restrictions when planning the menu.",
        "Have a contingency plan for weather if any part of the event is outdoors."
      ],
      'meeting': [
        "Distribute a clear agenda at least 24 hours before the meeting.",
        "Assign a timekeeper to ensure discussions stay on track.",
        "Prepare any technical equipment and test it before participants arrive.",
        "Create action items with assigned responsibilities at the end of the meeting.",
        "Follow up with meeting notes within 24 hours after the meeting concludes."
      ],
      'conference': [
        "Send detailed information packets to all attendees a week before the event.",
        "Ensure good signage and directions to help attendees navigate the venue.",
        "Schedule regular breaks between sessions to prevent fatigue.",
        "Have technical support readily available for presentation issues.",
        "Create opportunities for networking and interaction between attendees."
      ],
      'birthday': [
        "Confirm all vendor arrangements a few days before the celebration.",
        "Create a timeline for key moments like cake cutting to ensure nothing is missed.",
        "Consider having activities suitable for all age groups if guests vary in age.",
        "Take photos throughout the event to capture special moments.",
        "Have a designated person to help the birthday person manage gifts and cards."
      ],
      'wedding': [
        "Create a seating chart to minimize confusion and facilitate social interaction.",
        "Have an emergency kit with supplies for last-minute fixes.",
        "Delegate responsibilities to trusted friends or family members on the day.",
        "Consider hiring a professional coordinator for the day of the event.",
        "Plan transportation between venues if ceremony and reception are in different locations."
      ],
    };
    
    final String typeKey = event.eventType.toLowerCase();
    if (tipsByType.containsKey(typeKey)) {
      return tipsByType[typeKey]!;
    }
    
    // Default generic tips if event type not found
    return [
      "Create a detailed timeline for your ${event.eventType} event.",
      "Assign specific responsibilities to team members for smoother execution.",
      "Communicate regularly with all stakeholders involved in planning.",
      "Have a contingency plan for unexpected situations.",
      "Document everything for future reference and improvement."
    ];
  }

  // Parse tips from LLM response
  static List<String> _parseTipsFromResponse(String response) {
    List<String> tips = [];
    
    try {
      // Clean up the response to extract only the JSON array part
      String jsonStr = response;
      if (response.contains('[') && response.contains(']')) {
        jsonStr = response.substring(
          response.indexOf('['),
          response.lastIndexOf(']') + 1,
        );
      }
      
      // Parse the JSON
      List<dynamic> jsonTips = [];
      try {
        jsonTips = jsonDecode(jsonStr) as List<dynamic>;
        
        // Convert to strings
        for (var tip in jsonTips) {
          tips.add(tip.toString());
        }
      } catch (e) {
        print('Error parsing tips JSON: $e');
      }
    } catch (e) {
      print('Error parsing tips: $e');
    }
    
    // If parsing fails or returns empty, provide default tips
    if (tips.isEmpty) {
      tips = [
        "Create a detailed timeline for your event.",
        "Assign specific responsibilities to team members.",
        "Communicate regularly with all stakeholders.",
        "Have a contingency plan for unpredictable situations.",
        "Document everything for future reference."
      ];
    }
    
    return tips;
  }
}