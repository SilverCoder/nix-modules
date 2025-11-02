# Platform Integration Reference

Platform channels, native code integration, and packages.

## Platform Channels (Method Channel)

### Dart Side

```dart
import 'package:flutter/services.dart';

class BatteryLevel {
  static const platform = MethodChannel('com.example.app/battery');

  Future<int> getBatteryLevel() async {
    try {
      final int result = await platform.invokeMethod('getBatteryLevel');
      return result;
    } on PlatformException catch (e) {
      print("Failed to get battery level: '${e.message}'");
      return -1;
    }
  }
}
```

### iOS (Swift)

```swift
// AppDelegate.swift
import UIKit
import Flutter

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
    let batteryChannel = FlutterMethodChannel(name: "com.example.app/battery",
                                              binaryMessenger: controller.binaryMessenger)
    batteryChannel.setMethodCallHandler({
      (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
      if call.method == "getBatteryLevel" {
        self.receiveBatteryLevel(result: result)
      } else {
        result(FlutterMethodNotImplemented)
      }
    })

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  private func receiveBatteryLevel(result: FlutterResult) {
    let device = UIDevice.current
    device.isBatteryMonitoringEnabled = true
    let batteryLevel = Int(device.batteryLevel * 100)
    result(batteryLevel)
  }
}
```

### Android (Kotlin)

```kotlin
// MainActivity.kt
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
  private val CHANNEL = "com.example.app/battery"

  override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
    super.configureFlutterEngine(flutterEngine)
    MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler {
      call, result ->
      if (call.method == "getBatteryLevel") {
        val batteryLevel = getBatteryLevel()
        if (batteryLevel != -1) {
          result.success(batteryLevel)
        } else {
          result.error("UNAVAILABLE", "Battery level not available.", null)
        }
      } else {
        result.notImplemented()
      }
    }
  }

  private fun getBatteryLevel(): Int {
    val batteryLevel: Int
    val batteryManager = getSystemService(Context.BATTERY_SERVICE) as BatteryManager
    batteryLevel = batteryManager.getIntProperty(BatteryManager.BATTERY_PROPERTY_CAPACITY)
    return batteryLevel
  }
}
```

## Event Channel (Streaming)

```dart
import 'package:flutter/services.dart';

class AccelerometerData {
  static const eventChannel = EventChannel('com.example.app/accelerometer');

  Stream<List<double>> get accelerometerStream {
    return eventChannel.receiveBroadcastStream().map((dynamic event) {
      return List<double>.from(event);
    });
  }
}
```

## Common Packages

```yaml
# pubspec.yaml
dependencies:
  # HTTP
  http: ^1.1.0
  dio: ^5.3.3

  # State Management
  provider: ^6.0.5
  riverpod: ^2.4.0
  flutter_bloc: ^8.1.3

  # Storage
  shared_preferences: ^2.2.2
  sqflite: ^2.3.0
  hive: ^2.2.3

  # Firebase
  firebase_core: ^2.24.0
  firebase_auth: ^4.15.0
  cloud_firestore: ^4.13.0

  # Navigation
  go_router: ^12.0.0

  # UI
  flutter_svg: ^2.0.9
  cached_network_image: ^3.3.0
```

## Platform-Specific Code

```dart
import 'dart:io' show Platform;

if (Platform.isAndroid) {
  // Android-specific code
} else if (Platform.isIOS) {
  // iOS-specific code
}
```

## Permissions

```yaml
# ios/Runner/Info.plist
<key>NSCameraUsageDescription</key>
<string>We need camera access</string>

<key>NSPhotoLibraryUsageDescription</key>
<string>We need photo library access</string>
```

```xml
<!-- android/app/src/main/AndroidManifest.xml -->
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
```

```dart
// Request permission
import 'package:permission_handler/permission_handler.dart';

final status = await Permission.camera.request();
if (status.isGranted) {
  // Use camera
}
```
