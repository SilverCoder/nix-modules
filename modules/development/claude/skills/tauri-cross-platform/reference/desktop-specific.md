# Desktop-Specific APIs

Tauri features available on desktop platforms (Windows, macOS, Linux).

## System Tray

```rust
use tauri::{CustomMenuItem, SystemTray, SystemTrayMenu, SystemTrayEvent, Manager};

fn main() {
    let tray_menu = SystemTrayMenu::new()
        .add_item(CustomMenuItem::new("show".to_string(), "Show"))
        .add_item(CustomMenuItem::new("hide".to_string(), "Hide"))
        .add_native_item(SystemTrayMenuItem::Separator)
        .add_item(CustomMenuItem::new("quit".to_string(), "Quit"));

    let system_tray = SystemTray::new().with_menu(tray_menu);

    tauri::Builder::default()
        .system_tray(system_tray)
        .on_system_tray_event(|app, event| match event {
            SystemTrayEvent::MenuItemClick { id, .. } => {
                match id.as_str() {
                    "show" => {
                        let window = app.get_window("main").unwrap();
                        window.show().unwrap();
                        window.set_focus().unwrap();
                    }
                    "hide" => {
                        app.get_window("main").unwrap().hide().unwrap();
                    }
                    "quit" => {
                        std::process::exit(0);
                    }
                    _ => {}
                }
            }
            _ => {}
        })
        .run(tauri::generate_context!())
        .expect("error while running tauri application");
}
```

## Native Menus

```rust
use tauri::{Menu, MenuItem, Submenu, CustomMenuItem};

fn main() {
    let menu = Menu::new()
        .add_submenu(Submenu::new(
            "File",
            Menu::new()
                .add_item(CustomMenuItem::new("new", "New"))
                .add_item(CustomMenuItem::new("open", "Open"))
                .add_native_item(MenuItem::Separator)
                .add_item(CustomMenuItem::new("quit", "Quit")),
        ))
        .add_submenu(Submenu::new(
            "Edit",
            Menu::new()
                .add_native_item(MenuItem::Undo)
                .add_native_item(MenuItem::Redo)
                .add_native_item(MenuItem::Separator)
                .add_native_item(MenuItem::Cut)
                .add_native_item(MenuItem::Copy)
                .add_native_item(MenuItem::Paste),
        ));

    tauri::Builder::default()
        .menu(menu)
        .on_menu_event(|event| {
            match event.menu_item_id() {
                "new" => {
                    println!("New file");
                }
                "open" => {
                    println!("Open file");
                }
                "quit" => {
                    std::process::exit(0);
                }
                _ => {}
            }
        })
        .run(tauri::generate_context!())
        .expect("error while running tauri application");
}
```

## File Dialogs

```rust
use tauri::api::dialog::{FileDialogBuilder, MessageDialogBuilder, MessageDialogKind};

#[tauri::command]
async fn open_file_dialog() -> Result<Option<String>, String> {
    let (tx, rx) = std::sync::mpsc::channel();

    FileDialogBuilder::new()
        .add_filter("Text", &["txt", "md"])
        .add_filter("Images", &["png", "jpg"])
        .pick_file(move |path| {
            tx.send(path.map(|p| p.display().to_string())).unwrap();
        });

    rx.recv().map_err(|e| e.to_string())
}

#[tauri::command]
async fn save_file_dialog() -> Result<Option<String>, String> {
    let (tx, rx) = std::sync::mpsc::channel();

    FileDialogBuilder::new()
        .set_file_name("document.txt")
        .save_file(move |path| {
            tx.send(path.map(|p| p.display().to_string())).unwrap();
        });

    rx.recv().map_err(|e| e.to_string())
}

#[tauri::command]
async fn pick_folder() -> Result<Option<String>, String> {
    let (tx, rx) = std::sync::mpsc::channel();

    FileDialogBuilder::new()
        .pick_folder(move |path| {
            tx.send(path.map(|p| p.display().to_string())).unwrap();
        });

    rx.recv().map_err(|e| e.to_string())
}

#[tauri::command]
async fn confirm_dialog(message: String) -> Result<bool, String> {
    let (tx, rx) = std::sync::mpsc::channel();

    MessageDialogBuilder::new("Confirm", message)
        .kind(MessageDialogKind::Info)
        .buttons(tauri::api::dialog::MessageDialogButtons::OkCancel)
        .show(move |result| {
            tx.send(result).unwrap();
        });

    rx.recv().map_err(|e| e.to_string())
}
```

## Global Shortcuts

```rust
use tauri::{Manager, GlobalShortcutManager};

fn main() {
    tauri::Builder::default()
        .setup(|app| {
            let app_handle = app.handle();

            app.global_shortcut_manager()
                .register("CommandOrControl+Shift+C", move || {
                    if let Some(window) = app_handle.get_window("main") {
                        window.show().unwrap();
                        window.set_focus().unwrap();
                    }
                })
                .unwrap();

            Ok(())
        })
        .run(tauri::generate_context!())
        .expect("error while running tauri application");
}
```

## Clipboard

```rust
use tauri::ClipboardManager;

#[tauri::command]
fn copy_to_clipboard(app: AppHandle, text: String) -> Result<(), String> {
    app.clipboard_manager()
        .write_text(text)
        .map_err(|e| e.to_string())
}

#[tauri::command]
fn read_clipboard(app: AppHandle) -> Result<String, String> {
    app.clipboard_manager()
        .read_text()
        .map_err(|e| e.to_string())
}
```

## Shell / Open External

```typescript
import { open } from '@tauri-apps/api/shell'

// Open URL in default browser
await open('https://example.com')

// Open file with default app
await open('/path/to/file.pdf')

// Open with specific app
await open('/path/to/image.png', 'Preview')
```

## App Updater

```rust
use tauri::updater::UpdaterBuilder;

fn main() {
    tauri::Builder::default()
        .setup(|app| {
            let handle = app.handle();

            tauri::async_runtime::spawn(async move {
                let updater = UpdaterBuilder::new().build().unwrap();

                match updater.check().await {
                    Ok(Some(update)) => {
                        println!("Update available: {}", update.version);
                        update.download_and_install().await.unwrap();
                    }
                    Ok(None) => println!("No update available"),
                    Err(e) => eprintln!("Error checking for updates: {}", e),
                }
            });

            Ok(())
        })
        .run(tauri::generate_context!())
        .expect("error while running tauri application");
}
```

```typescript
// Frontend updater
import { checkUpdate, installUpdate } from '@tauri-apps/api/updater'
import { relaunch } from '@tauri-apps/api/process'

const update = await checkUpdate()

if (update.shouldUpdate) {
    console.log(`Update to ${update.manifest.version} available`)

    await installUpdate()
    await relaunch()
}
```

## Notifications

```rust
use tauri::api::notification::Notification;

#[tauri::command]
fn show_notification(app: AppHandle, title: String, body: String) -> Result<(), String> {
    Notification::new(&app.config().tauri.bundle.identifier)
        .title(title)
        .body(body)
        .show()
        .map_err(|e| e.to_string())
}
```

```typescript
import { sendNotification } from '@tauri-apps/api/notification'

await sendNotification({
    title: 'Hello',
    body: 'This is a notification'
})
```

## Process

```typescript
import { exit, relaunch } from '@tauri-apps/api/process'

// Exit app
await exit(0)

// Restart app
await relaunch()
```

## Best Practices

1. **System tray for background apps** - Keep app running in tray
2. **Native menus for desktop feel** - Use platform conventions
3. **File dialogs for UX** - Better than custom UI
4. **Global shortcuts sparingly** - Don't conflict with system
5. **Check updater permissions** - Requires allowlist configuration
6. **Test on all desktop platforms** - Behavior differs
