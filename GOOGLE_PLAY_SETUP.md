# Digital Saver - Google Play Store Publishing Guide

## Overview

This guide walks you through publishing Digital Saver on the Google Play Store.

---

## Step 1: Create Google Play Developer Account

1. Go to: **https://play.google.com/console**
2. Click "Sign up" and create a developer account
3. Pay the **$25 USD** registration fee (one-time)
4. Complete your profile (name, email, phone, website)

---

## Step 2: Generate Signing Key (Java KeyStore)

You need a signing key to publish your app. Run this command:

```bash
keytool -genkey -v -keystore digital_saver_key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias digital_saver
```

**Important:** 
- Save this file securely! You'll need it for every update
- If you lose it, you CANNOT update your app
- Keep multiple backups

---

## Step 3: Configure App for Release

### Update `android/app/build.gradle`

Add signing configuration:

```gradle
android {
    signingConfigs {
        release {
            keyAlias 'digital_saver'
            keyPassword 'YOUR_KEY_PASSWORD'
            storeFile file('digital_saver_key.jks')
            storePassword 'YOUR_STORE_PASSWORD'
        }
    }
    buildTypes {
        release {
            signingConfig signingConfigs.release
            minifyEnabled true
            shrinkResources true
            proguardFiles getDefaultProguardFile('proguard-android-optimize.txt'), 'proguard-rules.pro'
        }
    }
}
```

### Update `android/app/src/main/AndroidManifest.xml`

Add these permissions for health features:

```xml
<uses-permission android:name="android.permission.BLUETOOTH" />
<uses-permission android:name="android.permission.BLUETOOTH_ADMIN" />
<uses-permission android:name="android.permission.BLUETOOTH_CONNECT" />
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
<uses-permission android:name="android.permission.SEND_SMS" />
<uses-permission android:name="android.permission.CALL_PHONE" />
<uses-permission android:name="android.permission.INTERNET" />
```

---

## Step 4: Create App Assets

### App Icon (Required)
- **Size:** 512x512 pixels (Google Play)
- **Format:** PNG or JPEG
- **Name:** `app_icon.png`

Also create these sizes for the app:
- mdpi: 48x48
- hdpi: 72x72
- xhdpi: 96x96
- xxhdpi: 144x144
- xxxhdpi: 192x192

### Feature Graphic (Required for Google Play)
- **Size:** 1024x500 pixels
- **Format:** PNG or JPEG

### Screenshots (Required)
You need at least 2 screenshots. Recommended sizes:
- **Phone:** 1080x1920 pixels
- **Tablet:** 1920x1080 pixels (or 7-inch tablet: 2048x2732)

---

## Step 5: Build Release APK

After configuring signing:

```bash
cd app
flutter build apk --release
```

The APK will be at: `build/app/outputs/flutter-apk/app-release.apk`

---

## Step 6: Upload to Google Play Console

1. Go to: **https://play.google.com/console**
2. Click **"Create app"**
3. Fill in:
   - **App name:** Digital Saver
   - **Default language:** Arabic (ar) or English
   - **App type:** App
   - **Free or Paid:** Free

4. Go to **"App content"** section:
   - Answer the questions about content rating
   - Select "Health & Fitness" category
   - Complete target audience questions

5. Go to **"Store presence"** > **"Store listing"**:
   - Add short description (80 characters max)
   - Add full description
   - Add app icon and screenshots
   - Add feature graphic
   - Add privacy policy URL (required!)

6. Go to **"Production"**:
   - Click "Create release"
   - Upload your signed APK
   - Add release notes
   - Click "Save" then "Review release"

7. **Submit for review**

---

## Step 7: Privacy Policy (Required)

You MUST have a privacy policy. Options:

### Option A: Use a Privacy Policy Generator
- Go to: https://www.privacypolicyonline.com/
- Create free privacy policy
- Host it on your website

### Option B: Create GitHub Pages Privacy Policy
1. Create `privacy_policy.html` in your repo
2. Enable GitHub Pages
3. Use that URL: `https://asserkdev.github.io/Digital-saver/privacy_policy.html`

### Privacy Policy Template

```html
<!DOCTYPE html>
<html>
<head>
    <title>Privacy Policy - Digital Saver</title>
</head>
<body>
    <h1>Privacy Policy</h1>
    <p>Last updated: [DATE]</p>
    
    <h2>Information We Collect</h2>
    <p>Digital Saver collects health data from compatible smartwatch devices including:
       heart rate, blood pressure, blood oxygen levels, and activity data.</p>
    
    <h2>How We Use Information</h2>
    <p>We use collected data solely for providing health monitoring services.
       Data is processed locally on your device and may be shared with emergency 
       contacts when you trigger an emergency alert.</p>
    
    <h2>Data Storage</h2>
    <p>Health data is stored locally on your device. We do not collect, store, 
       or transmit your personal health information to external servers.</p>
    
    <h2>Contact</h2>
    <p>For privacy concerns, contact us at: [YOUR_EMAIL]</p>
</body>
</html>
```

---

## Step 8: Wait for Review

- Google typically reviews apps within **1-3 days**
- You'll receive email when approved
- App goes live automatically after approval

---

## Important Notes

### Medical Disclaimer (Required in App)
Your app should include this disclaimer:

```
DISCLAIMER: Digital Saver is a wellness/health tracking application, 
NOT a certified medical device. Do not use for self-diagnosis or 
medical treatment. Consult healthcare professionals for medical advice.
Emergency features supplement but do not replace emergency services.
```

### Content Rating
- You'll need to complete a questionnaire about your app
- Select "Health & Fitness" as the category
- Answer honestly about content

### Age Restrictions
- If targeting children, additional requirements apply
- Consider if app is suitable for all ages or requires age verification

---

## Troubleshooting

### "App not compliant"
- Check all required permissions have justification
- Ensure privacy policy is accessible
- Complete all sections in Play Console

### Build fails
- Ensure Java JDK is installed: `java -version`
- Verify keytool is in PATH
- Check keystore password is correct

### Can't upload APK
- APK must be signed with release key
- Check minSdkVersion is appropriate
- Verify AndroidManifest permissions are valid

---

## Timeline

| Step | Time Required |
|------|---------------|
| Developer Account Setup | 1 day |
| App Configuration | 1-2 hours |
| Building APK | 10-15 minutes |
| Play Console Setup | 1-2 hours |
| Google Review | 1-3 days |
| **Total** | **~3-5 days** |

---

## Need Help?

If you encounter issues:
1. Check Flutter documentation: https://flutter.dev/docs
2. Check Google Play Console help: https://support.google.com/googleplay/android-developer/
3. Review error messages carefully

---

**Good luck with your submission! 🇪🇬**
