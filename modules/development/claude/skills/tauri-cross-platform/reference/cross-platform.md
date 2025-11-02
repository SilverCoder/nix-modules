# Cross-Platform Patterns

Conditional compilation, platform detection, and shared code patterns for Tauri apps.

## Conditional Compilation

### Platform-Specific Code

```rust
// Desktop only
#[cfg(desktop)]
fn desktop_feature() {
    // Windows, macOS, Linux
}

// Mobile only
#[cfg(mobile)]
fn mobile_feature() {
    // iOS, Android
}

// Specific OS
#[cfg(target_os = "windows")]
fn windows_only() {}

#[cfg(target_os = "macos")]
fn macos_only() {}

#[cfg(target_os = "linux")]
fn linux_only() {}

#[cfg(target_os = "ios")]
fn ios_only() {}

#[cfg(target_os = "android")]
fn android_only() {}
```

### Feature Flags

```toml
# src-tauri/Cargo.toml
[features]
default = []
desktop = []
mobile = []
```

```rust
#[cfg(feature = "desktop")]
use tauri_plugin_window;

#[cfg(feature = "mobile")]
use tauri_plugin_haptics;

#[tauri::command]
fn platform_specific_command() -> String {
    #[cfg(feature = "desktop")]
    return "Desktop version".to_string();

    #[cfg(feature = "mobile")]
    return "Mobile version".to_string();
}
```

## Runtime Platform Detection

### In Rust

```rust
use tauri::api::platform::current_exe;

#[tauri::command]
fn get_platform_info() -> PlatformInfo {
    PlatformInfo {
        os: std::env::consts::OS.to_string(),
        arch: std::env::consts::ARCH.to_string(),
        family: std::env::consts::FAMILY.to_string(),
        is_mobile: cfg!(mobile),
        is_desktop: cfg!(desktop),
    }
}
```

### In Frontend

```typescript
import { platform } from '@tauri-apps/api/os'

const platformName = await platform()
// 'linux', 'darwin', 'ios', 'android', 'win32'

const isMobile = platformName === 'ios' || platformName === 'android'
const isDesktop = !isMobile
```

## Path Handling

### Cross-Platform Paths

```rust
use std::path::PathBuf;
use tauri::api::path::app_data_dir;

#[tauri::command]
fn get_app_path(app: AppHandle) -> Result<String, String> {
    let app_data = app_data_dir(&app.config())
        .ok_or("Failed to get app data dir")?;

    // PathBuf handles platform differences
    let config_path = app_data.join("config.json");

    Ok(config_path.display().to_string())
}

// Paths on different platforms:
// Windows: C:\Users\Name\AppData\Roaming\com.app\config.json
// macOS:   /Users/Name/Library/Application Support/com.app/config.json
// Linux:   /home/name/.config/com.app/config.json
// iOS:     /var/mobile/Containers/Data/Application/.../Library/Application Support/com.app/config.json
// Android: /data/data/com.app/files/config.json
```

### Resource Paths

```rust
use tauri::Manager;

#[tauri::command]
fn load_resource(app: AppHandle, filename: String) -> Result<String, String> {
    let resource_path = app.path_resolver()
        .resolve_resource(filename)
        .ok_or("Failed to resolve resource")?;

    std::fs::read_to_string(resource_path)
        .map_err(|e| e.to_string())
}
```

## Configuration

### Platform-Specific Config

```json
// src-tauri/tauri.conf.json
{
  "tauri": {
    "bundle": {
      "identifier": "com.example.app",
      "targets": ["all"],
      "windows": {
        "certificateThumbprint": null,
        "digestAlgorithm": "sha256"
      },
      "macOS": {
        "frameworks": [],
        "minimumSystemVersion": "10.13"
      },
      "iOS": {
        "developmentTeam": "TEAM_ID"
      }
    }
  }
}
```

### Conditional Allowlist

```json
{
  "tauri": {
    "allowlist": {
      "fs": {
        "scope": {
          "windows": ["$APPDATA/*"],
          "macos": ["$HOME/Library/Application Support/*"],
          "linux": ["$HOME/.config/*"]
        }
      }
    }
  }
}
```

## UI Adaptations

### Responsive Layout

```typescript
import { appWindow } from '@tauri-apps/api/window'
import { platform } from '@tauri-apps/api/os'

const platformName = await platform()
const isMobile = platformName === 'ios' || platformName === 'android'

// Mobile: full-screen, touch-optimized
if (isMobile) {
    document.body.classList.add('mobile')
    // Larger touch targets, simplified navigation
}

// Desktop: windowed, mouse/keyboard optimized
else {
    document.body.classList.add('desktop')
    // Smaller UI elements, keyboard shortcuts
}
```

### Platform-Specific Features

```rust
#[tauri::command]
fn show_context_menu(window: Window) -> Result<(), String> {
    #[cfg(desktop)]
    {
        // Desktop: use native menu
        window.menu().show_context_menu();
    }

    #[cfg(mobile)]
    {
        // Mobile: use action sheet
        window.emit("show-action-sheet", ())
            .map_err(|e| e.to_string())?;
    }

    Ok(())
}
```

## Build Configuration

### Cargo.toml

```toml
[target.'cfg(target_os = "windows")'.dependencies]
windows = "0.48"

[target.'cfg(target_os = "macos")'.dependencies]
cocoa = "0.24"

[target.'cfg(target_os = "linux")'.dependencies]
gtk = "0.16"

[target.'cfg(target_os = "android")'.dependencies]
jni = "0.21"
```

### Build Scripts

```rust
// build.rs
fn main() {
    if cfg!(target_os = "windows") {
        // Windows-specific build steps
        println!("cargo:rustc-link-lib=user32");
    }

    if cfg!(target_os = "macos") {
        // macOS-specific build steps
        println!("cargo:rustc-link-lib=framework=Cocoa");
    }
}
```

## Shared Code Patterns

### Platform Abstraction

```rust
// Define trait for platform-specific behavior
trait PlatformNotifications {
    fn show(&self, title: &str, body: &str) -> Result<(), String>;
}

// Desktop implementation
#[cfg(desktop)]
struct DesktopNotifications;

#[cfg(desktop)]
impl PlatformNotifications for DesktopNotifications {
    fn show(&self, title: &str, body: &str) -> Result<(), String> {
        tauri::api::notification::Notification::new("com.app")
            .title(title)
            .body(body)
            .show()
            .map_err(|e| e.to_string())
    }
}

// Mobile implementation
#[cfg(mobile)]
struct MobileNotifications;

#[cfg(mobile)]
impl PlatformNotifications for MobileNotifications {
    fn show(&self, title: &str, body: &str) -> Result<(), String> {
        // Use mobile plugin
        mobile_notification_plugin::show(title, body)
    }
}

// Factory function
fn get_notifications() -> Box<dyn PlatformNotifications> {
    #[cfg(desktop)]
    return Box::new(DesktopNotifications);

    #[cfg(mobile)]
    return Box::new(MobileNotifications);
}

#[tauri::command]
fn show_notification(title: String, body: String) -> Result<(), String> {
    get_notifications().show(&title, &body)
}
```

## Testing Across Platforms

### Platform-Specific Tests

```rust
#[cfg(test)]
mod tests {
    #[test]
    #[cfg(target_os = "windows")]
    fn test_windows_specific() {
        // Only runs on Windows
    }

    #[test]
    #[cfg(desktop)]
    fn test_desktop_feature() {
        // Runs on all desktop platforms
    }

    #[test]
    #[cfg(mobile)]
    fn test_mobile_feature() {
        // Runs on iOS and Android
    }
}
```

## Common Patterns

### File System Access

```rust
#[tauri::command]
async fn save_file(app: AppHandle, content: String) -> Result<(), String> {
    let path = {
        #[cfg(desktop)]
        {
            // Desktop: use file picker
            use tauri::api::dialog::FileDialogBuilder;
            let (tx, rx) = std::sync::mpsc::channel();

            FileDialogBuilder::new()
                .save_file(move |path| {
                    tx.send(path).unwrap();
                });

            rx.recv().unwrap().ok_or("No file selected")?
        }

        #[cfg(mobile)]
        {
            // Mobile: use app documents directory
            let docs = app.path_resolver()
                .app_data_dir()
                .ok_or("Failed to get documents dir")?;

            docs.join("saved_file.txt")
        }
    };

    tokio::fs::write(path, content)
        .await
        .map_err(|e| e.to_string())
}
```

### Window Management

```rust
#[tauri::command]
fn create_window(app: AppHandle) -> Result<(), String> {
    #[cfg(desktop)]
    {
        tauri::WindowBuilder::new(
            &app,
            "new-window",
            tauri::WindowUrl::App("index.html".into())
        )
        .inner_size(800.0, 600.0)
        .build()
        .map_err(|e| e.to_string())?;
    }

    #[cfg(mobile)]
    {
        // Mobile: navigate instead (single window)
        app.emit_all("navigate", "/new-page")
            .map_err(|e| e.to_string())?;
    }

    Ok(())
}
```

## Best Practices

1. **Use cfg attributes** - Compile-time platform checks are zero-cost
2. **Abstract platform differences** - Traits for platform-specific behavior
3. **Test on all targets** - Don't assume cross-platform code works everywhere
4. **PathBuf for paths** - Handles platform differences automatically
5. **Feature flags for major differences** - Desktop vs mobile features
6. **Runtime detection for UI** - Adapt UI based on platform
7. **Separate mobile/desktop UX** - Don't force desktop patterns on mobile
8. **Use Tauri path APIs** - They handle platform specifics correctly
