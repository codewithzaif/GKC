# Society Management App

A Flutter application for society fund tracking and management.

## Features

- **Fund Management**: Track income and expenses for the society
- **Member Management**: Keep track of society members, their payment status, and contact information
- **Visual Map**: View house locations on a map with color coding for paid/unpaid members
- **Dashboard**: Overview of society funds and member payment status

## Getting Started

### Prerequisites

- Flutter SDK
- Android Studio / VS Code
- Google Maps API Key (for map functionality)

### Installation

1. Clone the repository
2. Navigate to the project directory
3. Run `flutter pub get` to install dependencies
4. Set up your Google Maps API key:
   - Add your API key in `android/app/src/main/AndroidManifest.xml`
   - Add your API key in `ios/Runner/AppDelegate.swift`
5. Run `flutter run` to start the application

## Usage

### Fund Management
- Add new income or expense entries
- View transaction history
- Track fund balance

### Member Management
- Add new members with their details
- Update payment status
- View member information

### Map View
- See the location of all houses in the society
- Green markers indicate paid members
- Red markers indicate unpaid members

## Dependencies

- shared_preferences: Local storage
- uuid: Generating unique IDs
- google_maps_flutter: Map visualization
- intl: Date and number formatting 