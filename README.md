# Raksha

Raksha is a Flutter-based mobile application designed to help users in emergencies by notifying their emergency contacts and all users within a 5 km radius. The app sends the user's current location and provides an option to track background location (if opted) to assist others in need. It uses Firebase Authentication for secure sign-up and Firebase Realtime Database along with Floor DB for data storage.

---

## Table of Contents
1. [Features](#features)
2. [Getting Started](#getting-started)
   - [Prerequisites](#prerequisites)
   - [Installation](#installation)
3. [Usage](#usage)
4. [Contributing](#contributing)
5. [License](#license)

---

## Features
- **Emergency Alert**: Notify emergency contacts and nearby users within 5 km with the current location.
- **Background Location Tracking**: Optionally tracks user location in the background to assist others in emergencies.
- **Firebase Integration**: Secure sign-up and authentication with Firebase Authentication.
- **Local Database Support**: Uses Floor DB for offline data storage and management.
- **Notifications**: Sends alerts to users opted for emergency notifications.

---

## Getting Started

### Prerequisites
- Flutter SDK installed ([Installation Guide](https://docs.flutter.dev/get-started/install))
- Android Studio or Visual Studio Code with Flutter plugin
- Firebase account setup ([Firebase Console](https://console.firebase.google.com))

### Installation

1. **Clone the repository**:
   ```
   git clone https://github.com/TERRA2k5/Raksha.git
   ```
2. **Navigate to the project directory**:
    ```
   cd Raksha
    ```
3. **Install dependencies**:
    ```
    flutter pub get
    ```
4. **Configure Firebase**:
- Download the google-services.json file from Firebase Console and place it in the android/app directory.
- Follow FlutterFire Setup for detailed instructions.
5. **Run the application**:
    ```
    flutter run
    ```
---

## Usage

- Open the app and sign up using your email and password.

- Grant location and notification permissions.

- Add emergency contacts and medical details in the profile section.

- Tap the emergency alert button to notify contacts and nearby users.

- Enable background location tracking in settings if required.
---

## Contributing

Contributions are welcome! If you'd like to improve Raksha, please fork the repository and create a pull request. For major changes, open an issue first to discuss what you’d like to change.
## License

This project is under [MIT](https://choosealicense.com/licenses/mit/) License.

---
_Raksha - Your safety, our priority!_

