# Firebase Setup Guide for TajwidCoach

This guide outlines the steps needed to connect the TajwidCoach Flutter app to your Firebase project.

## Prerequisites
- A Google account
- Firebase CLI installed (`npm install -g firebase-tools`)
- FlutterFire CLI installed (`dart pub global activate flutterfire_cli`)

## Setup Instructions

1. **Create Firebase Project:**
   - Go to [Firebase Console](https://console.firebase.google.com/)
   - Click "Add Project"
   - Name it "TajwidCoach"
   - Enable Google Analytics (Recommended for RevenueCat integration later)

2. **Configure Flutter App:**
   Open a terminal in the root of your `TajwidCoach` project and run:
   ```bash
   flutterfire configure
   ```
   Select your freshly created "TajwidCoach" project and let it configure Android (and iOS if using a Mac).
   *Note: This will automatically generate the `google-services.json` file for Android and update `lib/firebase_options.dart`.*

3. **Enable Authentication:**
   - In the Firebase Console, go to **Build > Authentication**
   - Click "Get Started"
   - Go to the "Sign-in method" tab
   - Enable **Phone** authentication

4. **Enable Firestore Database:**
   - Go to **Build > Firestore Database**
   - Click "Create database"
   - Choose a location
   - Start in **Test mode** (or update your security rules later)

### Sample Firestore Rules (For Production):
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    match /sheikhs/{sheikhId} {
      allow read: if true;
      allow write: if request.auth != null && request.auth.uid == sheikhId;
    }
  }
}
```

5. **Enable Firebase Storage (Optional, for Audio Uploads):**
   - Go to **Build > Storage**
   - Click "Get started"
   - Choose a location

Once these steps are completed, the mock data in the app can be gradually replaced with actual Firebase backend calls.
