# Firebase Setup Guide for Smart Classroom Management App

This app uses **Firebase Authentication** ONLY for teacher login. After signing in, the app operates fully offline using Hive. Follow these steps to attach your Firebase project to this Flutter app.

## Prerequisites

1.  **Flutter SDK** installed and configured.
2.  A [Firebase account](https://console.firebase.google.com/).
3.  Ensure you have the Firebase CLI installed (`npm install -g firebase-tools`).

## Step 1: Create a Firebase Project

1.  Go to the [Firebase Console](https://console.firebase.google.com/).
2.  Click **Add project** (or create a project).
3.  Enter a name for your project (e.g., `SmartClassroomApp`).
4.  Disable Google Analytics (not needed for this app), then click **Create project**.

## Step 2: Configure FlutterFire CLI (Recommended)

The easiest way to configure Firebase with Flutter is using the `flutterfire_cli`.

1.  Open your terminal and login to Firebase:
    ```bash
    firebase login
    ```
2.  Activate the flutterfire CLI globally:
    ```bash
    dart pub global activate flutterfire_cli
    ```
3.  Navigate to your app's root folder (`Smart Classroom Management App`), and run:
    ```bash
    flutterfire configure
    ```
    *   Select the Firebase project you just created.
    *   Choose the platforms you want to support (typically **android** and **ios**).
    *   The CLI will automatically generate the `lib/firebase_options.dart` file and configure your native builds (e.g., `google-services.json`).

## Step 3: Enable Email/Password Authentication

1.  In the Firebase Console, open your new project.
2.  On the left sidebar, click **Authentication**, then click **Get Started**.
3.  Click on the **Sign-in method** tab.
4.  Click on **Email/Password**.
5.  Set the first toggle (Email/Password) to **Enable** and save.
6.  Go to the **Users** tab and click **Add user**.
7.  Enter an email/password that the teacher will use to login and click **Add User**.
    *   *Note: Ensure you remember these credentials to access the app.*

## Step 4: Update `main.dart` (If using flutterfire_cli)

If you generated `firebase_options.dart` through the CLI, make sure your `main.dart` initializes Firebase securely:

```dart
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // ... rest of your Hive and app initialization
}
```

## Step 5: Test the Application

1.  Get all typical flutter dependencies:
    ```bash
    flutter pub get
    ```
2.  Generate Hive models if needed (this app's code provides pre-generated models):
    ```bash
    dart run build_runner build --delete-conflicting-outputs
    ```
3.  Run your app:
    ```bash
    flutter run
    ```
4.  Login with the credentials you created in Step 3!

---
*The rest of the app relies safely on local device storage via Hive. Have fun managing your classroom!*
