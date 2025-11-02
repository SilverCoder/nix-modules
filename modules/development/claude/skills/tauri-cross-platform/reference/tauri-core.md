# Tauri Core Reference

Complete reference for Tauri commands, IPC, events, and window management (cross-platform).

## Commands

### Basic Command

```rust
// src-tauri/src/main.rs or src-tauri/src/commands.rs
#[tauri::command]
fn greet(name: String) -> String {
    format!("Hello, {}!", name)
}

fn main() {
    tauri::Builder::default()
        .invoke_handler(tauri::generate_handler![greet])
        .run(tauri::generate_context!())
        .expect("error while running tauri application");
}
```

```typescript
// Frontend
import { invoke } from '@tauri-apps/api/tauri'

const greeting = await invoke<string>('greet', { name: 'World' })
```

### Async Command

```rust
#[tauri::command]
async fn fetch_data() -> Result<Vec<Data>, String> {
    let response = reqwest::get("https://api.example.com/data")
        .await
        .map_err(|e| e.to_string())?;

    let data = response.json::<Vec<Data>>()
        .await
        .map_err(|e| e.to_string())?;

    Ok(data)
}
```

```typescript
try {
    const data = await invoke<Data[]>('fetch_data')
    console.log(data)
} catch (error) {
    console.error('Error:', error)
}
```

### Command with State

```rust
use tauri::State;
use std::sync::Mutex;

struct AppState {
    counter: Mutex<i32>,
}

#[tauri::command]
fn increment(state: State<AppState>) -> Result<i32, String> {
    let mut counter = state.counter.lock()
        .map_err(|e| e.to_string())?;

    *counter += 1;
    Ok(*counter)
}

fn main() {
    tauri::Builder::default()
        .manage(AppState {
            counter: Mutex::new(0),
        })
        .invoke_handler(tauri::generate_handler![increment])
        .run(tauri::generate_context!())
        .expect("error while running tauri application");
}
```

### Command with Window

```rust
use tauri::Window;

#[tauri::command]
fn close_window(window: Window) {
    window.close().unwrap();
}

#[tauri::command]
fn window_title(window: Window) -> String {
    window.title().unwrap()
}
```

### Command with App Handle

```rust
use tauri::AppHandle;

#[tauri::command]
async fn create_new_window(app: AppHandle) -> Result<(), String> {
    tauri::WindowBuilder::new(
        &app,
        "new-window",
        tauri::WindowUrl::App("index.html".into())
    )
    .title("New Window")
    .build()
    .map_err(|e| e.to_string())?;

    Ok(())
}
```

## Command Allowlist

```json
// src-tauri/tauri.conf.json
{
  "tauri": {
    "allowlist": {
      "all": false,
      "fs": {
        "all": false,
        "readFile": true,
        "writeFile": true,
        "scope": ["$APPDATA/*", "$RESOURCE/*"]
      },
      "dialog": {
        "all": false,
        "open": true,
        "save": true
      },
      "shell": {
        "all": false,
        "open": true
      }
    }
  }
}
```

## Events

### Emitting Events (Rust)

```rust
use tauri::Manager;

#[tauri::command]
async fn download_file(app: AppHandle, url: String) -> Result<(), String> {
    // Emit progress events
    app.emit_all("download-progress", DownloadProgress {
        percent: 0,
        bytes: 0,
    }).map_err(|e| e.to_string())?;

    // Download logic...

    app.emit_all("download-progress", DownloadProgress {
        percent: 100,
        bytes: total_bytes,
    }).map_err(|e| e.to_string())?;

    Ok(())
}

// Emit to specific window
#[tauri::command]
fn notify_window(window: Window, message: String) -> Result<(), String> {
    window.emit("notification", message)
        .map_err(|e| e.to_string())
}
```

### Listening to Events (Frontend)

```typescript
import { listen } from '@tauri-apps/api/event'

// Listen to event
const unlisten = await listen<DownloadProgress>('download-progress', (event) => {
    console.log('Progress:', event.payload.percent)
})

// Clean up when component unmounts
unlisten()

// Listen once
import { once } from '@tauri-apps/api/event'

const payload = await once<string>('notification')
console.log(payload)
```

### Emitting Events (Frontend)

```typescript
import { emit } from '@tauri-apps/api/event'

// Emit event that Rust can listen to
await emit('user-action', { action: 'click', target: 'button' })
```

### Listening to Events (Rust)

```rust
use tauri::Manager;

fn main() {
    tauri::Builder::default()
        .setup(|app| {
            let app_handle = app.handle();

            app.listen_global("user-action", move |event| {
                if let Some(payload) = event.payload() {
                    println!("User action: {}", payload);
                }
            });

            Ok(())
        })
        .run(tauri::generate_context!())
        .expect("error while running tauri application");
}
```

## Window Management

### Creating Windows

```rust
use tauri::{Manager, WindowBuilder, WindowUrl};

#[tauri::command]
fn create_settings_window(app: AppHandle) -> Result<(), String> {
    let window = WindowBuilder::new(
        &app,
        "settings",  // Window label
        WindowUrl::App("settings.html".into())
    )
    .title("Settings")
    .inner_size(800.0, 600.0)
    .resizable(true)
    .decorations(true)
    .center()
    .build()
    .map_err(|e| e.to_string())?;

    Ok(())
}
```

### Window Configuration

```rust
WindowBuilder::new(&app, "label", url)
    .title("My Window")
    .inner_size(800.0, 600.0)
    .min_inner_size(400.0, 300.0)
    .max_inner_size(1920.0, 1080.0)
    .resizable(true)
    .fullscreen(false)
    .decorations(true)
    .transparent(false)
    .always_on_top(false)
    .center()
    .position(100.0, 100.0)
    .visible(true)
    .skip_taskbar(false)
    .build()?;
```

### Accessing Windows

```rust
use tauri::Manager;

// Get window by label
if let Some(window) = app.get_window("main") {
    window.set_title("New Title").unwrap();
}

// Get all windows
let windows = app.windows();
for (label, window) in windows {
    println!("Window: {}", label);
}

// From command
#[tauri::command]
fn manipulate_window(window: Window) {
    window.set_title("Updated").unwrap();
    window.center().unwrap();
}
```

### Window Methods

```rust
// Visibility
window.show().unwrap();
window.hide().unwrap();
window.is_visible().unwrap();

// Size & Position
window.set_size(tauri::Size::Physical(PhysicalSize { width: 800, height: 600 })).unwrap();
window.inner_size().unwrap();
window.outer_size().unwrap();
window.set_position(tauri::Position::Physical(PhysicalPosition { x: 100, y: 100 })).unwrap();
window.center().unwrap();

// State
window.set_fullscreen(true).unwrap();
window.is_fullscreen().unwrap();
window.set_minimized(true).unwrap();
window.set_maximized(true).unwrap();
window.is_maximized().unwrap();

// Focus
window.set_focus().unwrap();
window.is_focused().unwrap();

// Title & Icon
window.set_title("New Title").unwrap();
window.set_icon(icon).unwrap();

// Close
window.close().unwrap();
```

### Window Events (Frontend)

```typescript
import { appWindow } from '@tauri-apps/api/window'

// Listen to window events
const unlisten = await appWindow.onCloseRequested(async (event) => {
    const confirmed = await confirm('Are you sure?')
    if (!confirmed) {
        event.preventDefault()
    }
})

// Other events
await appWindow.onFocusChanged((focused) => {
    console.log('Focus changed:', focused)
})

await appWindow.onResized((size) => {
    console.log('Resized:', size)
})

await appWindow.onMoved((position) => {
    console.log('Moved:', position)
})
```

## App Lifecycle

### Setup Hook

```rust
use tauri::Manager;

fn main() {
    tauri::Builder::default()
        .setup(|app| {
            let app_handle = app.handle();

            // Initialize state
            // Setup event listeners
            // Create windows

            Ok(())
        })
        .run(tauri::generate_context!())
        .expect("error while running tauri application");
}
```

### On Page Load

```rust
fn main() {
    tauri::Builder::default()
        .on_page_load(|window, payload| {
            println!("Page loaded: {:?}", payload.url());
        })
        .run(tauri::generate_context!())
        .expect("error while running tauri application");
}
```

### On Window Event

```rust
fn main() {
    tauri::Builder::default()
        .on_window_event(|event| match event.event() {
            tauri::WindowEvent::CloseRequested { api, .. } => {
                println!("Window close requested");
                // api.prevent_close(); // Prevent closing
            }
            tauri::WindowEvent::Focused(focused) => {
                println!("Focus changed: {}", focused);
            }
            tauri::WindowEvent::Resized(size) => {
                println!("Window resized: {:?}", size);
            }
            _ => {}
        })
        .run(tauri::generate_context!())
        .expect("error while running tauri application");
}
```

## File System

### Reading Files

```rust
use tauri::api::path::app_data_dir;
use std::fs;

#[tauri::command]
async fn read_config(app: AppHandle) -> Result<String, String> {
    let app_data = app_data_dir(&app.config())
        .ok_or("Failed to get app data dir")?;

    let config_path = app_data.join("config.json");

    fs::read_to_string(config_path)
        .map_err(|e| e.to_string())
}
```

### Writing Files

```rust
#[tauri::command]
async fn write_config(app: AppHandle, content: String) -> Result<(), String> {
    let app_data = app_data_dir(&app.config())
        .ok_or("Failed to get app data dir")?;

    fs::create_dir_all(&app_data)
        .map_err(|e| e.to_string())?;

    let config_path = app_data.join("config.json");

    fs::write(config_path, content)
        .map_err(|e| e.to_string())
}
```

### Frontend File System

```typescript
import { readTextFile, writeTextFile, BaseDirectory } from '@tauri-apps/api/fs'

// Read file
const content = await readTextFile('config.json', { dir: BaseDirectory.AppData })

// Write file
await writeTextFile('config.json', JSON.stringify(data), { dir: BaseDirectory.AppData })
```

## Error Handling

### Command Errors

```rust
// String errors
#[tauri::command]
fn might_fail() -> Result<Data, String> {
    do_something().map_err(|e| e.to_string())
}

// Custom error types
use serde::{Serialize, Deserialize};

#[derive(Debug, Serialize, Deserialize)]
struct AppError {
    message: String,
    code: i32,
}

#[tauri::command]
fn might_fail_custom() -> Result<Data, AppError> {
    do_something().map_err(|e| AppError {
        message: e.to_string(),
        code: 500,
    })
}
```

```typescript
// Frontend error handling
try {
    const data = await invoke('might_fail')
} catch (error) {
    console.error('Command failed:', error)
}

// Type-safe errors
interface AppError {
    message: string
    code: number
}

try {
    await invoke('might_fail_custom')
} catch (error) {
    const appError = error as AppError
    console.error(`Error ${appError.code}: ${appError.message}`)
}
```

## Path Resolution

```rust
use tauri::api::path::*;

// Special directories
let app_config = app_config_dir(&config);      // Config directory
let app_data = app_data_dir(&config);          // App data directory
let app_local_data = app_local_data_dir(&config);
let app_cache = app_cache_dir(&config);
let app_log = app_log_dir(&config);

let home = home_dir();
let document = document_dir();
let download = download_dir();
let desktop = desktop_dir();
let picture = picture_dir();
let video = video_dir();
let audio = audio_dir();

// Resource directory (bundled assets)
let resource = resource_dir(&app.package_info(), &app.env());
let resource_path = resource.join("data").join("file.txt");
```

## Best Practices

1. **Always use Result** - Return `Result<T, String>` from commands
2. **Validate inputs** - Never trust frontend data
3. **Add to allowlist** - Commands must be in `tauri.conf.json`
4. **Clean up event listeners** - Call `unlisten()` in cleanup
5. **Use State for shared data** - Not global variables
6. **Async for IO** - Don't block Tokio runtime
7. **Type frontend calls** - Use TypeScript types
8. **Handle errors** - Try/catch around invoke()
9. **Label windows uniquely** - Avoid conflicts
10. **Test cross-platform** - Paths, APIs differ by OS
