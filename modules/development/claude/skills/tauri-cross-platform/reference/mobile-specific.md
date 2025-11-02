# Mobile-Specific APIs

Tauri features for mobile platforms (iOS, Android).

## Mobile Plugins

### Common Mobile Plugins

```toml
# src-tauri/Cargo.toml
[dependencies]
tauri-plugin-biometric = "0.1"
tauri-plugin-barcode-scanner = "0.1"
tauri-plugin-haptics = "0.1"
tauri-plugin-geolocation = "0.1"
```

```rust
use tauri_plugin_biometric::BiometricAuth;
use tauri_plugin_haptics::Haptics;

fn main() {
    tauri::Builder::default()
        .plugin(tauri_plugin_biometric::init())
        .plugin(tauri_plugin_haptics::init())
        .run(tauri::generate_context!())
        .expect("error while running tauri application");
}
```

## Permissions

### iOS Permissions (Info.plist)

```xml
<!-- src-tauri/gen/apple/Info.plist -->
<key>NSCameraUsageDescription</key>
<string>This app needs camera access</string>

<key>NSPhotoLibraryUsageDescription</key>
<string>This app needs photo library access</string>

<key>NSLocationWhenInUseUsageDescription</key>
<string>This app needs location access</string>

<key>NSMicrophoneUsageDescription</key>
<string>This app needs microphone access</string>
```

### Android Permissions (AndroidManifest.xml)

```xml
<!-- src-tauri/gen/android/app/src/main/AndroidManifest.xml -->
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.RECORD_AUDIO" />
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
```

### Runtime Permission Requests

```rust
#[tauri::command]
async fn request_camera_permission() -> Result<bool, String> {
    #[cfg(mobile)]
    {
        use tauri_plugin_permissions::PermissionsExt;

        let permission = tauri_plugin_permissions::Permission::Camera;
        let granted = request_permission(permission).await?;
        Ok(granted)
    }

    #[cfg(not(mobile))]
    Ok(true)  // Desktop doesn't need runtime permissions
}
```

## Biometric Authentication

```rust
use tauri_plugin_biometric::BiometricAuth;

#[tauri::command]
async fn authenticate_biometric(app: AppHandle) -> Result<bool, String> {
    let biometric = app.state::<BiometricAuth>();

    let available = biometric.is_available()
        .await
        .map_err(|e| e.to_string())?;

    if !available {
        return Err("Biometric not available".to_string());
    }

    let result = biometric.authenticate("Authenticate to continue")
        .await
        .map_err(|e| e.to_string())?;

    Ok(result)
}
```

```typescript
import { authenticate, isAvailable } from 'tauri-plugin-biometric-api'

if (await isAvailable()) {
    const authenticated = await authenticate({
        reason: 'Authenticate to access your account'
    })

    if (authenticated) {
        // Proceed
    }
}
```

## Haptic Feedback

```rust
use tauri_plugin_haptics::{Haptics, HapticFeedbackType};

#[tauri::command]
fn trigger_haptic(app: AppHandle) -> Result<(), String> {
    let haptics = app.state::<Haptics>();

    haptics.impact(HapticFeedbackType::Medium)
        .map_err(|e| e.to_string())
}
```

```typescript
import { impactFeedback, notificationFeedback, selectionFeedback } from 'tauri-plugin-haptics-api'

// Impact feedback
await impactFeedback('medium')  // 'light', 'medium', 'heavy'

// Notification feedback
await notificationFeedback('success')  // 'success', 'warning', 'error'

// Selection feedback
await selectionFeedback()
```

## App Lifecycle

```rust
use tauri::Manager;

fn main() {
    tauri::Builder::default()
        .setup(|app| {
            #[cfg(mobile)]
            {
                app.listen_global("app-pause", |_| {
                    println!("App went to background");
                });

                app.listen_global("app-resume", |_| {
                    println!("App came to foreground");
                });
            }

            Ok(())
        })
        .run(tauri::generate_context!())
        .expect("error while running tauri application");
}
```

```typescript
import { appWindow } from '@tauri-apps/api/window'

// Mobile lifecycle events
await appWindow.listen('tauri://pause', () => {
    console.log('App paused')
})

await appWindow.listen('tauri://resume', () => {
    console.log('App resumed')
})
```

## Deep Linking

### iOS (Info.plist)

```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleURLName</key>
        <string>com.myapp</string>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>myapp</string>
        </array>
    </dict>
</array>
```

### Android (AndroidManifest.xml)

```xml
<intent-filter>
    <action android:name="android.intent.action.VIEW" />
    <category android:name="android.intent.category.DEFAULT" />
    <category android:name="android.intent.category.BROWSABLE" />
    <data android:scheme="myapp" />
</intent-filter>
```

### Handle Deep Links

```rust
use tauri::Manager;

fn main() {
    tauri::Builder::default()
        .setup(|app| {
            app.listen_global("deep-link", |event| {
                if let Some(url) = event.payload() {
                    println!("Deep link opened: {}", url);
                    // Handle URL
                }
            });

            Ok(())
        })
        .run(tauri::generate_context!())
        .expect("error while running tauri application");
}
```

## Network Status

```rust
use tauri_plugin_network::NetworkStatus;

#[tauri::command]
fn get_network_status(app: AppHandle) -> Result<bool, String> {
    let network = app.state::<NetworkStatus>();

    Ok(network.is_connected())
}
```

## Camera & Photos

```rust
#[tauri::command]
async fn take_photo() -> Result<String, String> {
    #[cfg(mobile)]
    {
        use tauri_plugin_camera::Camera;

        let camera = Camera::new();
        let photo = camera.take_photo()
            .await
            .map_err(|e| e.to_string())?;

        Ok(photo.path)
    }

    #[cfg(not(mobile))]
    Err("Camera not available on desktop".to_string())
}
```

## Screen Orientation

```rust
#[tauri::command]
fn lock_orientation(orientation: String) -> Result<(), String> {
    #[cfg(mobile)]
    {
        use tauri_plugin_screen_orientation::ScreenOrientation;

        let orientation = match orientation.as_str() {
            "portrait" => ScreenOrientation::Portrait,
            "landscape" => ScreenOrientation::Landscape,
            _ => return Err("Invalid orientation".to_string()),
        };

        lock_screen_orientation(orientation)
            .map_err(|e| e.to_string())
    }

    #[cfg(not(mobile))]
    Ok(())
}
```

## Status Bar

```rust
#[tauri::command]
fn set_status_bar_style(style: String) -> Result<(), String> {
    #[cfg(target_os = "ios")]
    {
        use tauri_plugin_statusbar::StatusBar;

        let style = match style.as_str() {
            "light" => StatusBarStyle::Light,
            "dark" => StatusBarStyle::Dark,
            _ => return Err("Invalid style".to_string()),
        };

        StatusBar::set_style(style)
            .map_err(|e| e.to_string())
    }

    #[cfg(not(target_os = "ios"))]
    Ok(())
}
```

## Best Practices

1. **Request permissions before use** - Check and request at appropriate time
2. **Handle permission denied** - Graceful degradation
3. **Test lifecycle events** - Apps pause/resume frequently
4. **Use platform-specific code** - `#[cfg(mobile)]`, `#[cfg(target_os = "ios")]`
5. **Respect battery life** - Minimize background work
6. **Handle deep links** - For navigation from external sources
7. **Optimize for mobile** - Smaller bundles, less memory
8. **Test on real devices** - Simulators don't match real hardware
