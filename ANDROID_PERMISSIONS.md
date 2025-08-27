# Android Permissions for Prayer Time Notifications

When the Android project is created for this app, the following permissions need to be added to `android/app/src/main/AndroidManifest.xml`:

```xml
<!-- Required for exact alarm scheduling (Android 13+) -->
<uses-permission android:name="android.permission.SCHEDULE_EXACT_ALARM" />
<uses-permission android:name="android.permission.USE_EXACT_ALARM" />

<!-- Required for notifications -->
<uses-permission android:name="android.permission.WAKE_LOCK" />
<uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED" />

<!-- For vibration -->
<uses-permission android:name="android.permission.VIBRATE" />
```

These permissions are essential for the prayer time notifications to work properly, especially the `SCHEDULE_EXACT_ALARM` permission which allows the app to trigger notifications at precise prayer times.

## Note
Add these permissions inside the `<manifest>` tag but outside the `<application>` tag in AndroidManifest.xml.