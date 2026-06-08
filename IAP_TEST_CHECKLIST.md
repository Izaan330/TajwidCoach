# IAP Smoke Test Checklist

## Prerequisites

1. **Replace API keys** in `lib/services/revenue_cat_service.dart`:
   - `_appleApiKey` → real App Store Connect key (starts with `appl_`)
   - `_googleApiKey` → real Play Console key (starts with `goog_`)
   - Currently set to `test_...` keys which bypass RevenueCat entirely

2. **Sandbox setup**:
   - **iOS**: Create sandbox tester in App Store Connect → Users → Sandbox Testers. Sign out of real Apple ID on device, sign in with sandbox account.
   - **Android**: Add tester Gmail in Play Console → Settings → License testing. Device's primary account must be the tester.

3. **RevenueCat dashboard**:
   - Project must be in **Test Store mode**
   - Entitlements configured (name must match `"Quran Pro: Tajwid AI"` — see `premium_provider.dart:376`)
   - Products configured matching plan IDs: `yearly`, `monthly`, `family_yearly`, `lifetime`, `monthly_2`

4. **Product IDs in App Store Connect / Play Console** must match `PremiumProvider.plans` IDs exactly.

---

## Test Steps (run on real device, not emulator)

### Step 1: Fresh Launch
- [ ] Uninstall app completely
- [ ] Install and launch
- [ ] Sign in / create account
- [ ] Navigate to paywall
- [ ] **Console check**: Should see `RevenueCat: Initializing with API keys...` and `RevenueCat: isConfigured = true`

### Step 2: Purchase Flow
- [ ] Tap "Continue with Premium" (or selected plan)
- [ ] **Console check**: `RevenueCat: Attempting purchase for plan "yearly"`
- [ ] **Console check**: `RevenueCat: Current offering = ...` and available packages listed
- [ ] Confirm Apple/Google payment sheet appears
- [ ] Complete purchase with sandbox account
- [ ] **Console check**: `RevenueCat: Purchase successful. Entitlements: ...`
- [ ] **Console check**: `PremiumProvider: Premium ACTIVE — tier=PremiumTier.premium, planId=yearly`
- [ ] Paywall should dismiss, premium features unlocked

### Step 3: Verify Premium State
- [ ] Close and reopen paywall — should auto-dismiss (line 61 of paywall_screen.dart checks `premium.isPremium`)
- [ ] Premium-gated features accessible (advanced AI, all Qaris, Hifz tools, etc.)
- [ ] Free user limits no longer enforced

### Step 4: Force-Quit + Relaunch
- [ ] Force-quit the app
- [ ] Relaunch
- [ ] **Console check**: `RevenueCat: CustomerInfo fetched. Entitlements: ...`
- [ ] Premium should still be active (confirms `getCustomerInfo` cache)

### Step 5: Restore Purchases
- [ ] Uninstall app completely
- [ ] Reinstall and sign in with same account
- [ ] Open paywall → tap "Restore Purchases"
- [ ] **Console check**: `RevenueCat: Restoring purchases...`
- [ ] **Console check**: `RevenueCat: Restore complete. Entitlements: ...`
- [ ] Premium should be recovered

### Step 6: Cancelled Purchase
- [ ] Open paywall → tap purchase
- [ ] Cancel/dismiss the payment sheet
- [ ] **Console check**: `RevenueCat: Purchase cancelled by user`
- [ ] App should not crash, remain on free tier

### Step 7: RevenueCat Dashboard Verification
- [ ] Go to app.revenuecat.com → your project → Customers
- [ ] Find test user by `appUserID`
- [ ] Check Entitlements shows `"Quran Pro: Tajwid AI"` as active with correct product ID
- [ ] Check Chart/Events tab for purchase event

### Step 8: Upgrade/Downgrade (if applicable)
- [ ] Subscribe to "Premium" (yearly)
- [ ] Then subscribe to "Family" (yearly) — should upgrade
- [ ] Verify entitlement reflects new plan

---

## Entitlement Key: `"Quran Pro: Tajwid AI"`

Defined in `lib/providers/premium_provider.dart:376`. This **must** match the entitlement identifier in your RevenueCat dashboard exactly (case-sensitive).

## Plan IDs

| Plan ID | Tier | Price |
|---------|------|-------|
| `yearly` | Premium | ₹199/yr |
| `monthly` | Premium | (monthly) |
| `family_yearly` | Family | ₹499/yr |
| `lifetime` | Lifetime | $29 one-time |
| `monthly_2` | Sheikh Pro | ₹999/mo |
