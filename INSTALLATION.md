# PetPal Installation Guide

This guide will walk you through the process of setting up the PetPal application on your local machine for development and testing.

## 1. Prerequisites

Before you begin, ensure you have the following installed on your system:

*   **Flutter SDK:** [Install Flutter](https://docs.flutter.dev/get-started/install)
*   **Git:** [Install Git](https://git-scm.com/downloads)
*   **An IDE:**
    *   [Visual Studio Code](https://code.visualstudio.com/) with the [Flutter extension](https://marketplace.visualstudio.com/items?itemName=Dart-Code.flutter).
    *   [Android Studio](https://developer.android.com/studio) with the [Flutter plugin](https://docs.flutter.dev/get-started/editor?tab=androidstudio).
*   **An Android Emulator or a physical Android device.**

## 2. Backend Configuration

PetPal uses Supabase for its backend (database, storage) and Firebase for push notifications. You will need to create projects for both services.

### 2.1. Supabase Setup

1.  **Create a Supabase Project:**
    *   Go to [supabase.com](https://supabase.com/) and create a new project.
    *   Once your project is created, navigate to **Settings > API**.
    *   You will need the **Project URL** and the **Project API keys** (the `anon` `public` key) for the next steps.

2.  **Create Storage Bucket:**
    *   In your Supabase project, go to the **Storage** section.
    *   Create a new bucket and name it `pet_profile`.
    *   Make the bucket **public**. For detailed instructions, you can refer to the `docs/CREATE_SUPABASE_BUCKET.md` file in this repository.

### 2.2. Firebase Setup

1.  **Create a Firebase Project:**
    *   Go to the [Firebase Console](https://console.firebase.google.com/) and create a new project.

2.  **Configure for Android:**
    *   Inside your Firebase project, add a new Android app.
    *   The package name must be `com.example.flutter_application_1`. You can find this in the `android/app/build.gradle` file (look for `applicationId`).
    *   Follow the setup steps to register the app.
    *   Download the `google-services.json` file. You will need this in the local setup.

## 3. Local Setup

1.  **Clone the Repository:**
    ```bash
    git clone <repository_url>
    cd PET-PAL
    ```

2.  **Add Supabase Credentials:**
    *   Create a new file at `lib/constants.dart`.
    *   Add your Supabase URL and anon key to this file like so:

    ```dart
    // lib/constants.dart

    const String supabaseUrl = 'YOUR_SUPABASE_URL';
    const String supabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY';
    ```

    *   Replace `YOUR_SUPABASE_URL` and `YOUR_SUPABASE_ANON_KEY` with the credentials from your Supabase project.

3.  **Update `main.dart`:**
    *   Open `lib/main.dart`.
    *   Import the new `constants.dart` file:
        ```dart
        import 'package:flutter_application_1/constants.dart';
        ```
    *   Find the `Supabase.initialize` call and replace the hardcoded values with the constants from your new file:

        ```dart
        // Before
        await Supabase.initialize(
          url: 'https://xfmusoxrdhuzmaxffwyq.supabase.co',
          anonKey:
              'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InhmbXVzb3hyZGh1em1heGZmd3lxIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTcwNzYyNzcsImV4cCI6MjA3MjY1MjI3N30.-VQ7z2fDpHnzBTgO1b9AhxzLwNRyO6fmzmoiM59a1Dk',
        );

        // After
        await Supabase.initialize(
          url: supabaseUrl,
          anonKey: supabaseAnonKey,
        );
        ```

4.  **Add Firebase Configuration:**
    *   Take the `google-services.json` file you downloaded from Firebase and place it in the `android/app/` directory of the project, replacing the existing one.

5.  **Install Dependencies:**
    *   Open a terminal in the project root and run:
    ```bash
    flutter pub get
    ```

## 4. Running the Application

1.  **Ensure you have a device running:**
    *   Start your Android Emulator or connect a physical device and ensure it's recognized by Flutter (`flutter devices`).
2.  **Run the app:**
    ```bash
    flutter run
    ```

The app should now build and run on your selected device.
