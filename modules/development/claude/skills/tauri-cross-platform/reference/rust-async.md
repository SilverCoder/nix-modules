# Rust Async Patterns Reference

Complete guide to async Rust, Tokio runtime, futures, channels, and async pitfalls in Tauri.

## Tokio Runtime

Tauri runs on Tokio runtime automatically. All async commands execute in this runtime.

### Async Command Basics

```rust
#[tauri::command]
async fn async_operation() -> Result<String, String> {
    // This runs on Tokio runtime
    tokio::time::sleep(tokio::time::Duration::from_secs(1)).await;
    Ok("Done".to_string())
}
```

### Spawning Tasks

```rust
use tokio::task;

#[tauri::command]
async fn background_task(app: AppHandle) -> Result<(), String> {
    task::spawn(async move {
        loop {
            tokio::time::sleep(tokio::time::Duration::from_secs(10)).await;
            app.emit_all("heartbeat", ()).unwrap();
        }
    });

    Ok(())
}
```

### Blocking Operations

```rust
// ❌ DON'T: Blocks the async runtime
#[tauri::command]
async fn bad_blocking() -> String {
    std::thread::sleep(std::time::Duration::from_secs(5));  // Blocks!
    "Done".to_string()
}

// ✅ DO: Use spawn_blocking for CPU-heavy or blocking IO
#[tauri::command]
async fn good_blocking() -> Result<String, String> {
    let result = task::spawn_blocking(|| {
        // Expensive computation
        std::thread::sleep(std::time::Duration::from_secs(5));
        "Done".to_string()
    })
    .await
    .map_err(|e| e.to_string())?;

    Ok(result)
}
```

## Async/Await

### Basic Async

```rust
async fn fetch_user(id: u64) -> Result<User, Error> {
    let response = reqwest::get(format!("https://api.example.com/users/{}", id))
        .await?;

    let user = response.json::<User>().await?;

    Ok(user)
}
```

### Sequential vs Parallel

```rust
// Sequential (slow)
async fn fetch_all_sequential() -> Result<(User, Posts), Error> {
    let user = fetch_user(1).await?;
    let posts = fetch_posts(1).await?;
    Ok((user, posts))
}

// Parallel (fast)
async fn fetch_all_parallel() -> Result<(User, Posts), Error> {
    let (user, posts) = tokio::try_join!(
        fetch_user(1),
        fetch_posts(1)
    )?;

    Ok((user, posts))
}

// Many parallel tasks
async fn fetch_many() -> Result<Vec<User>, Error> {
    let ids = vec![1, 2, 3, 4, 5];

    let futures: Vec<_> = ids.iter()
        .map(|id| fetch_user(*id))
        .collect();

    let users = futures::future::try_join_all(futures).await?;

    Ok(users)
}
```

### Error Handling

```rust
async fn with_error_handling() -> Result<Data, String> {
    let result = risky_operation()
        .await
        .map_err(|e| format!("Operation failed: {}", e))?;

    Ok(result)
}

// Multiple error types
use thiserror::Error;

#[derive(Error, Debug)]
enum AppError {
    #[error("Network error: {0}")]
    Network(#[from] reqwest::Error),

    #[error("Database error: {0}")]
    Database(String),

    #[error("Not found")]
    NotFound,
}

async fn with_custom_errors() -> Result<Data, AppError> {
    let response = reqwest::get("https://api.example.com")
        .await?;  // Automatically converted to AppError::Network

    let data = response.json::<Data>().await?;

    Ok(data)
}
```

## Channels

### MPSC (Multi-Producer, Single-Consumer)

```rust
use tokio::sync::mpsc;

#[tauri::command]
async fn start_worker(app: AppHandle) -> Result<(), String> {
    let (tx, mut rx) = mpsc::channel::<String>(32);

    // Spawn worker
    tokio::spawn(async move {
        while let Some(message) = rx.recv().await {
            println!("Received: {}", message);
            app.emit_all("worker-message", message).unwrap();
        }
    });

    // Store sender in state if needed
    app.state::<Mutex<mpsc::Sender<String>>>().lock().unwrap().clone();

    Ok(())
}
```

### Oneshot Channel

```rust
use tokio::sync::oneshot;

async fn request_response() -> Result<String, String> {
    let (tx, rx) = oneshot::channel();

    tokio::spawn(async move {
        // Do work
        let result = compute_result();
        tx.send(result).unwrap();
    });

    rx.await.map_err(|e| e.to_string())
}
```

### Broadcast Channel

```rust
use tokio::sync::broadcast;

struct AppState {
    event_bus: broadcast::Sender<Event>,
}

#[tauri::command]
fn subscribe_events(state: State<AppState>) -> Result<(), String> {
    let mut rx = state.event_bus.subscribe();

    tokio::spawn(async move {
        while let Ok(event) = rx.recv().await {
            println!("Event: {:?}", event);
        }
    });

    Ok(())
}
```

## Synchronization

### Mutex

```rust
use tokio::sync::Mutex;
use std::sync::Arc;

struct AppState {
    data: Arc<Mutex<HashMap<String, String>>>,
}

#[tauri::command]
async fn update_data(state: State<'_, AppState>, key: String, value: String) -> Result<(), String> {
    let mut data = state.data.lock().await;
    data.insert(key, value);
    Ok(())
}

// ❌ DON'T: std::sync::Mutex in async
#[tauri::command]
async fn bad_mutex(state: State<'_, std::sync::Mutex<Data>>) -> Result<(), String> {
    let data = state.lock().unwrap();
    tokio::time::sleep(tokio::time::Duration::from_secs(1)).await;  // Holds lock across await!
    Ok(())
}

// ✅ DO: tokio::sync::Mutex for async
#[tauri::command]
async fn good_mutex(state: State<'_, tokio::sync::Mutex<Data>>) -> Result<(), String> {
    let data = state.lock().await;
    tokio::time::sleep(tokio::time::Duration::from_secs(1)).await;  // OK
    Ok(())
}
```

### RwLock

```rust
use tokio::sync::RwLock;

struct AppState {
    cache: Arc<RwLock<Cache>>,
}

#[tauri::command]
async fn read_cache(state: State<'_, AppState>, key: String) -> Result<Option<String>, String> {
    let cache = state.cache.read().await;
    Ok(cache.get(&key).cloned())
}

#[tauri::command]
async fn write_cache(state: State<'_, AppState>, key: String, value: String) -> Result<(), String> {
    let mut cache = state.cache.write().await;
    cache.insert(key, value);
    Ok(())
}
```

## Timeouts & Delays

```rust
use tokio::time::{timeout, Duration, sleep};

// Timeout
async fn with_timeout() -> Result<Data, String> {
    let result = timeout(
        Duration::from_secs(5),
        fetch_data()
    )
    .await
    .map_err(|_| "Timeout".to_string())?;

    result.map_err(|e| e.to_string())
}

// Delay
async fn with_delay() {
    sleep(Duration::from_secs(1)).await;
    println!("Delayed");
}

// Interval
use tokio::time::interval;

async fn periodic_task(app: AppHandle) {
    let mut interval = interval(Duration::from_secs(10));

    loop {
        interval.tick().await;
        app.emit_all("tick", ()).unwrap();
    }
}
```

## Streams

```rust
use tokio_stream::StreamExt;

async fn process_stream() -> Result<(), String> {
    let mut stream = tokio_stream::iter(vec![1, 2, 3, 4, 5]);

    while let Some(item) = stream.next().await {
        println!("Item: {}", item);
    }

    Ok(())
}

// File lines
use tokio::io::AsyncBufReadExt;

async fn read_lines(path: &str) -> Result<Vec<String>, String> {
    let file = tokio::fs::File::open(path)
        .await
        .map_err(|e| e.to_string())?;

    let reader = tokio::io::BufReader::new(file);
    let mut lines = reader.lines();

    let mut result = Vec::new();

    while let Some(line) = lines.next_line()
        .await
        .map_err(|e| e.to_string())? {
        result.push(line);
    }

    Ok(result)
}
```

## Common Pitfalls

### 1. Blocking in Async

```rust
// ❌ Blocks runtime
async fn bad() {
    std::thread::sleep(std::time::Duration::from_secs(1));  // NO!
    std::fs::read_to_string("file.txt").unwrap();           // NO!
}

// ✅ Use async alternatives
async fn good() {
    tokio::time::sleep(tokio::time::Duration::from_secs(1)).await;
    tokio::fs::read_to_string("file.txt").await.unwrap();
}

// ✅ Or spawn_blocking
async fn good_blocking() {
    tokio::task::spawn_blocking(|| {
        std::thread::sleep(std::time::Duration::from_secs(1));
        std::fs::read_to_string("file.txt").unwrap()
    })
    .await
    .unwrap();
}
```

### 2. Forgetting .await

```rust
// ❌ Future not executed
async fn bad() {
    let future = async_operation();  // Future created but not awaited!
}

// ✅ Await the future
async fn good() {
    let result = async_operation().await;
}
```

### 3. Mutex Deadlock

```rust
// ❌ Deadlock potential
async fn bad(state: State<'_, Mutex<Data>>) {
    let data1 = state.lock().unwrap();
    do_something().await;  // Still holds lock!
    let data2 = state.lock().unwrap();  // Deadlock if same mutex
}

// ✅ Drop lock before await
async fn good(state: State<'_, Mutex<Data>>) {
    {
        let data = state.lock().unwrap();
        // Use data
    }  // Lock dropped

    do_something().await;
}

// ✅ Or use tokio::sync::Mutex
async fn better(state: State<'_, tokio::sync::Mutex<Data>>) {
    let data = state.lock().await;
    do_something().await;  // OK with tokio::sync::Mutex
}
```

### 4. Not Cancelling Tasks

```rust
// ❌ Task runs forever
#[tauri::command]
async fn start_background() {
    tokio::spawn(async {
        loop {
            tokio::time::sleep(tokio::time::Duration::from_secs(1)).await;
        }
    });
}

// ✅ Store handle, allow cancellation
use tokio::task::JoinHandle;

struct AppState {
    task_handle: Mutex<Option<JoinHandle<()>>>,
}

#[tauri::command]
async fn start_background(state: State<'_, AppState>) {
    let handle = tokio::spawn(async {
        loop {
            tokio::time::sleep(tokio::time::Duration::from_secs(1)).await;
        }
    });

    *state.task_handle.lock().unwrap() = Some(handle);
}

#[tauri::command]
async fn stop_background(state: State<'_, AppState>) {
    if let Some(handle) = state.task_handle.lock().unwrap().take() {
        handle.abort();
    }
}
```

### 5. Wrong Channel Type

```rust
// ❌ Blocking channel in async
use std::sync::mpsc;

async fn bad() {
    let (tx, rx) = mpsc::channel();  // Blocks!
    tx.send("data").unwrap();
}

// ✅ Async channel
use tokio::sync::mpsc;

async fn good() {
    let (tx, mut rx) = mpsc::channel(32);
    tx.send("data").await.unwrap();
}
```

## Best Practices

1. **Use tokio variants** - `tokio::time::sleep`, `tokio::fs`, `tokio::sync::Mutex`
2. **spawn_blocking for CPU work** - Don't block async runtime
3. **Await futures** - Don't forget `.await`
4. **Drop locks before await** - Or use `tokio::sync::Mutex`
5. **Handle task cancellation** - Store `JoinHandle`, call `.abort()`
6. **Use timeouts** - Prevent hanging forever
7. **Parallel when possible** - Use `tokio::join!` or `try_join!`
8. **Match error types** - Use `thiserror` for custom errors
9. **Clean up resources** - Cancel tasks, close channels
10. **Test async code** - Use `#[tokio::test]`
