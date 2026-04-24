# TajwidCoach ML Backend Setup

This directory contains a **FastAPI** template to help you set up a real ML backend for your Tajwid coached app.

## Prerequisites
- Python 3.9+
- Pip

## Getting Started

1. **Set up a Virtual Environment** (Recommended):
   ```bash
   python -m venv .venv
   ```

2. **Activate the Environment**:
   - Windows: `.venv\Scripts\activate`
   - macOS/Linux: `source .venv/bin/activate`

3. **Install Dependencies**:
   ```bash
   pip install -r requirements.txt
   ```

4. **Run the Server**:
   ```bash
   python main.py
   ```
   The server will start at `http://localhost:8000`.

## Connecting the App

1. Find your computer's **Local IP Address** (e.g., `192.168.1.5`).
2. Open `lib/services/tajwid_api_service.dart` in the Flutter project.
3. Update `_baseUrl` to:
   ```dart
   static const String _baseUrl = 'http://192.168.1.5:8000/v1';
   ```
   *Note: Use `http://10.0.2.2:8000/v1` if you are testing on an Android Emulator.*

## 🧪 How to Test

### 1. Interactive API Docs (Easiest)
FastAPI automatically generates a testing dashboard for you.
1. Open your browser to: **`http://localhost:8000/docs`**
2. Click on the **POST /v1/analyze** endpoint.
3. Click **"Try it out"**.
4. Upload any `.wav` or `.mp3` file, enter `1:1` for `ayah_ref`, and click **Execute**.
5. You will see the AI's transcription and score in the response body!

### 2. Test from the Flutter App
- **Android Emulator**: Use `http://10.0.2.2:8000/v1`
- **iOS Simulator**: Use `http://localhost:8000/v1`
- **Physical Phone**: Use your computer's local IP (e.g., `http://192.168.1.5:8000/v1`)
