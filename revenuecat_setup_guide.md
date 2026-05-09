# RevenueCat Setup Guide for TajwidCoach

This guide details how to configure RevenueCat for the TajwidCoach premium subscription model.

## Prerequisites
- A RevenueCat account
- Google Play Console Developer account (for Android)
- Apple Developer account (for iOS)

## Setup Instructions

1. **Create Project in RevenueCat:**
   - Log in to your [RevenueCat Dashboard](https://app.revenuecat.com/)
   - Click "Add Project" and name it "TajwidCoach"

2. **Connect App Stores:**
   - Follow the platform-specific guides to connect your Play Store / App Store credentials.
   - For Android: You'll need an active service account JSON from Google Cloud Console.

3. **Create Products in App Stores:**
   Create the following subscription products in both Google Play Console and App Store Connect:
   - `tajwidcoach_premium_yearly` (Price: ₹199 / year)
   - `tajwidcoach_premium_family` (Price: ₹499 / year)
   - `tajwidcoach_premium_lifetime` (Price: ₹2,499 / one-time)
   - `tajwidcoach_sheikh_pro` (Price: ₹999 / year)

4. **Configure Products & Entitlements in RevenueCat:**
   - Go to **Project Settings > Products**
   - Import the products you just created in the app stores.
   - Go to **Project Settings > Entitlements**
   - Create a new entitlement named `premium`.
   - Attach the imported products to this entitlement.

5. **Update Flutter Code:**
   Open `lib/services/revenue_cat_service.dart` and ensure your specific RevenueCat API Keys are provided:
   
   ```dart
   // Add your public SDK keys here once generated from RevenueCat
   static const _appleApiKey = 'appl_api_key_here';
   static const _googleApiKey = 'goog_api_key_here';
   ```

6. **Testing:**
   - Use test user accounts in Google Play Console / Apple Sandbox to simulate purchases without real charges.
   - Check the RevenueCat dashboard to ensure purchases are registering correctly.
