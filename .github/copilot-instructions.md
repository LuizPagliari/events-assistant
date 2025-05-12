<!-- Use this file to provide workspace-specific custom instructions to Copilot. For more details, visit https://code.visualstudio.com/docs/copilot/copilot-customization#_use-a-githubcopilotinstructionsmd-file -->

# Event Assistant App

This project is a Flutter mobile application that helps in organizing events by suggesting schedules and activities based on event type using AI. The app integrates with OpenAI's language models to provide personalized event planning suggestions.

## Project Structure

- **lib/models/**: Data models for events and activities
- **lib/providers/**: State management using Provider
- **lib/screens/**: App screens (home, event form, event details)
- **lib/services/**: Services for interacting with OpenAI API
- **lib/widgets/**: Reusable UI components

## Key Features

1. Create and manage events with details (title, description, date, location, etc.)
2. Get AI-generated activity suggestions based on event type using the LLM service
3. Receive AI-powered tips for event organization
4. Track activities with a checklist

## Key Components

- **Event**: Main model representing an event with its details and associated activities
- **EventActivity**: Model representing an activity within an event
- **EventsProvider**: Provider for managing state and persistence of events
- **LLMService**: Service for interacting with OpenAI API to generate event suggestions
- **HomeScreen**: Main screen showing list of events
- **EventFormScreen**: Screen for creating and editing events
- **EventDetailsScreen**: Screen showing event details and AI-generated suggestions

## Key Interfaces

- When writing code for API integration, use the dart_openai package correctly with proper content models.
- For UI components, follow Material Design 3 guidelines with the theme defined in main.dart.
- For models, implement proper serialization/deserialization with toJson/fromJson methods.
- For providers, ensure proper state management with notifyListeners() calls when data changes.

## Best Practices

- Maintain a clean architecture with separation of concerns
- Use async/await for asynchronous operations
- Handle exceptions and provide fallback solutions
- Keep UI components modular and reusable
- Follow Flutter best practices for state management