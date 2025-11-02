# Bridge Communication Patterns

Patterns for frontend ↔ Rust communication, serialization, and error handling.

## Type Safety Across Bridge

### Shared Types

```rust
// src-tauri/src/types.rs
use serde::{Serialize, Deserialize};

#[derive(Debug, Serialize, Deserialize)]
pub struct User {
    pub id: u64,
    pub name: String,
    pub email: String,
}

#[derive(Debug, Serialize, Deserialize)]
pub struct CreateUserRequest {
    pub name: String,
    pub email: String,
}
```

```typescript
// src/types.ts
export interface User {
    id: number
    name: string
    email: string
}

export interface CreateUserRequest {
    name: string
    email: string
}
```

### Type Generation

Use `ts-rs` or `typeshare` to generate TypeScript types from Rust:

```rust
use serde::{Serialize, Deserialize};
use ts_rs::TS;

#[derive(Debug, Serialize, Deserialize, TS)]
#[ts(export)]
pub struct User {
    pub id: u64,
    pub name: String,
    pub email: String,
}
```

Generates `bindings/User.ts`:
```typescript
export interface User {
    id: number
    name: string
    email: string
}
```

## Command Patterns

### Request-Response

```rust
#[tauri::command]
async fn get_user(id: u64) -> Result<User, String> {
    database::get_user(id)
        .await
        .ok_or_else(|| "User not found".to_string())
}
```

```typescript
const user = await invoke<User>('get_user', { id: 123 })
```

### Fire-and-Forget

```rust
#[tauri::command]
fn log_event(event: String) {
    println!("Event: {}", event);
    // No return value needed
}
```

```typescript
invoke('log_event', { event: 'user_clicked_button' })
// Don't await, don't care about response
```

### Long-Running with Progress

```rust
#[tauri::command]
async fn process_large_file(app: AppHandle, path: String) -> Result<(), String> {
    let total_chunks = 100;

    for i in 0..total_chunks {
        // Process chunk
        tokio::time::sleep(tokio::time::Duration::from_millis(100)).await;

        // Emit progress
        app.emit_all("processing-progress", ProcessingProgress {
            current: i + 1,
            total: total_chunks,
            percent: ((i + 1) as f32 / total_chunks as f32 * 100.0) as u32,
        }).map_err(|e| e.to_string())?;
    }

    Ok(())
}
```

```typescript
const unlisten = await listen<ProcessingProgress>('processing-progress', (event) => {
    console.log(`Progress: ${event.payload.percent}%`)
    setProgress(event.payload.percent)
})

try {
    await invoke('process_large_file', { path: '/path/to/file' })
    console.log('Processing complete')
} finally {
    unlisten()
}
```

## Event Patterns

### Push Updates

```rust
// Background task pushing updates
tokio::spawn(async move {
    let mut interval = tokio::time::interval(tokio::time::Duration::from_secs(5));

    loop {
        interval.tick().await;

        let status = get_system_status();
        app.emit_all("system-status", status).unwrap();
    }
});
```

```typescript
await listen<SystemStatus>('system-status', (event) => {
    updateDashboard(event.payload)
})
```

### Bidirectional Communication

```rust
// Rust listens for frontend events
app.listen_global("user-command", move |event| {
    if let Some(command) = event.payload() {
        handle_command(command);

        // Respond via event
        app.emit_all("command-result", result).unwrap();
    }
});
```

```typescript
// Frontend sends command
await emit('user-command', { action: 'refresh' })

// Frontend listens for result
await listen('command-result', (event) => {
    console.log('Result:', event.payload)
})
```

## Error Handling

### Structured Errors

```rust
use serde::{Serialize, Deserialize};

#[derive(Debug, Serialize, Deserialize)]
pub struct AppError {
    pub code: String,
    pub message: String,
    pub details: Option<serde_json::Value>,
}

impl From<sqlx::Error> for AppError {
    fn from(err: sqlx::Error) -> Self {
        AppError {
            code: "DATABASE_ERROR".to_string(),
            message: err.to_string(),
            details: None,
        }
    }
}

#[tauri::command]
async fn risky_operation() -> Result<Data, AppError> {
    let data = database::query()
        .await?;  // Automatically converted to AppError

    Ok(data)
}
```

```typescript
interface AppError {
    code: string
    message: string
    details?: any
}

try {
    const data = await invoke<Data>('risky_operation')
} catch (error) {
    const appError = error as AppError
    switch (appError.code) {
        case 'DATABASE_ERROR':
            showDatabaseError(appError.message)
            break
        case 'NOT_FOUND':
            showNotFoundError()
            break
        default:
            showGenericError(appError.message)
    }
}
```

### Error Recovery

```rust
#[tauri::command]
async fn fetch_with_retry(url: String) -> Result<Data, String> {
    let mut attempts = 0;
    let max_attempts = 3;

    loop {
        attempts += 1;

        match reqwest::get(&url).await {
            Ok(response) => {
                return response.json::<Data>()
                    .await
                    .map_err(|e| e.to_string());
            }
            Err(e) if attempts < max_attempts => {
                tokio::time::sleep(tokio::time::Duration::from_secs(1)).await;
                continue;
            }
            Err(e) => {
                return Err(format!("Failed after {} attempts: {}", attempts, e));
            }
        }
    }
}
```

## Serialization Patterns

### Complex Types

```rust
use serde::{Serialize, Deserialize};
use chrono::{DateTime, Utc};

#[derive(Debug, Serialize, Deserialize)]
pub struct Post {
    pub id: u64,
    pub title: String,
    #[serde(with = "chrono::serde::ts_seconds")]
    pub created_at: DateTime<Utc>,
    pub tags: Vec<String>,
    pub metadata: serde_json::Value,
}
```

### Enums

```rust
#[derive(Debug, Serialize, Deserialize)]
#[serde(tag = "type")]
pub enum Message {
    Text { content: String },
    Image { url: String, caption: Option<String> },
    Video { url: String, duration: u32 },
}
```

```typescript
type Message =
    | { type: 'Text', content: string }
    | { type: 'Image', url: string, caption?: string }
    | { type: 'Video', url: string, duration: number }

const message = await invoke<Message>('get_message', { id: 123 })

switch (message.type) {
    case 'Text':
        console.log(message.content)  // Type-safe!
        break
    case 'Image':
        console.log(message.url, message.caption)
        break
    case 'Video':
        console.log(message.url, message.duration)
        break
}
```

## State Management

### Shared State

```rust
use std::sync::Mutex;
use tauri::State;

pub struct AppState {
    pub user: Mutex<Option<User>>,
    pub settings: Mutex<Settings>,
}

#[tauri::command]
fn set_user(state: State<AppState>, user: User) -> Result<(), String> {
    *state.user.lock().unwrap() = Some(user);
    Ok(())
}

#[tauri::command]
fn get_user(state: State<AppState>) -> Result<Option<User>, String> {
    Ok(state.user.lock().unwrap().clone())
}

fn main() {
    tauri::Builder::default()
        .manage(AppState {
            user: Mutex::new(None),
            settings: Mutex::new(Settings::default()),
        })
        .run(tauri::generate_context!())
        .expect("error while running tauri application");
}
```

### State Sync

```rust
#[tauri::command]
fn update_settings(
    app: AppHandle,
    state: State<AppState>,
    settings: Settings
) -> Result<(), String> {
    *state.settings.lock().unwrap() = settings.clone();

    // Notify all windows
    app.emit_all("settings-changed", settings)
        .map_err(|e| e.to_string())?;

    Ok(())
}
```

```typescript
// Window A updates settings
await invoke('update_settings', { settings: newSettings })

// Window B gets notified
await listen<Settings>('settings-changed', (event) => {
    applySettings(event.payload)
})
```

## Performance Patterns

### Batching

```rust
#[tauri::command]
async fn process_batch(items: Vec<Item>) -> Result<Vec<ProcessedItem>, String> {
    let results = futures::future::join_all(
        items.iter().map(|item| process_item(item))
    ).await;

    results.into_iter().collect::<Result<Vec<_>, _>>()
}
```

```typescript
// Instead of:
for (const item of items) {
    await invoke('process_item', { item })  // Slow: multiple IPC calls
}

// Do:
const results = await invoke<ProcessedItem[]>('process_batch', { items })  // Fast: one IPC call
```

### Streaming Large Data

```rust
#[tauri::command]
async fn stream_large_data(app: AppHandle) -> Result<(), String> {
    let chunks = load_data_in_chunks();

    for chunk in chunks {
        app.emit_all("data-chunk", chunk)
            .map_err(|e| e.to_string())?;

        tokio::task::yield_now().await;  // Don't block
    }

    app.emit_all("data-complete", ())
        .map_err(|e| e.to_string())?;

    Ok(())
}
```

```typescript
const data: any[] = []

const unlisten = await listen('data-chunk', (event) => {
    data.push(...event.payload)
    updateUI(data)
})

const unlistenComplete = await listen('data-complete', () => {
    console.log('All data received')
    unlisten()
    unlistenComplete()
})

await invoke('stream_large_data')
```

## Best Practices

1. **Type safety first** - Generate types or keep manual types in sync
2. **Structured errors** - Use error codes, not just strings
3. **Batch operations** - Minimize IPC overhead
4. **Use events for push** - Don't poll from frontend
5. **Validate inputs in Rust** - Never trust frontend data
6. **Handle serialization errors** - Types might mismatch
7. **Version your APIs** - Plan for changes
8. **Document bridge contracts** - What each command expects/returns
