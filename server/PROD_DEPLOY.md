# 🚀 Production Deployment Guide: Google Cloud Run

Google Cloud Run is the recommended way to host your Tajwid ML Backend. It is **serverless**, meaning you only pay when someone uses the app, and it automatically handles **HTTPS** for you.

## 1. Prerequisites
- [Google Cloud SDK](https://cloud.google.com/sdk/docs/install) installed on your computer.
- A Google Cloud Project (use the same one as your Firebase project).

## 2. One-Time Setup
Run these commands in your terminal once to prepare your project:

```bash
# Login to Google Cloud
gcloud auth login

# Set your project ID (find this in Firebase Console settings)
gcloud config set project [YOUR-PROJECT-ID]

# Enable required APIs
gcloud services enable run.googleapis.com containerregistry.googleapis.com
```

## 3. Deploy the Server
Whenever you want to update your server, run this command from the `server/` directory:

```bash
gcloud run deploy tajwid-backend --source . --platform managed --region us-central1 --allow-unauthenticated
```

### What This Command Does:
1. **Builds**: It sends your code to Google Cloud, which reads the `Dockerfile` and builds a secure "container" for your app.
2. **Deploys**: It starts the server on a secure, public URL provided by Google.
3. **HTTPS**: It automatically gives you a secure `https://...` address.

## 4. Update the Flutter App
Once the deployment finishes, you will see a URL like this:
`Service [tajwid-backend] has been deployed and is serving at https://tajwid-backend-xxxxx.a.run.app`

1. Copy that URL.
2. Open `lib/services/tajwid_api_service.dart`.
3. Update the `_baseUrl` to:
   ```dart
   static const String _baseUrl = 'https://tajwid-backend-xxxxx.a.run.app/v1';
   ```

## 🔐 Security Note
By useing `--allow-unauthenticated`, your API is public. For a real production app, we would add an **API Key** check or **Firebase Token Verification** in `main.py` to ensure only your app can call the ML model.
