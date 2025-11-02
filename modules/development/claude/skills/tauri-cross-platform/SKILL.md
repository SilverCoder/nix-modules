---
name: tauri-cross-platform
description: Tauri desktop + mobile development, Rust commands/IPC, async patterns, cross-platform APIs, bridge communication
---

# Tauri Cross-Platform Development

Build native applications for desktop (Windows, macOS, Linux) and mobile (iOS, Android) using Tauri, Rust, and web technologies.

## When to Use

Use this skill when:
- Working in `src-tauri/` directory
- Creating Rust commands (`#[tauri::command]`)
- Implementing IPC between frontend and Rust
- Using Tauri events for communication
- Managing windows, dialogs, system tray
- Handling platform-specific features
- Working with async Rust/Tokio
- Building for desktop or mobile targets

Don't use for:
- Pure frontend Tauri apps (use web-full-stack)
- Standalone Rust projects without Tauri
- Electron or other frameworks

## Quick Reference

### Commands

| Pattern | Rust | Frontend |
|---------|------|----------|
| Simple sync | `fn greet(name: String) -> String` | `await invoke('greet', { name })` |
| Async | `async fn fetch() -> Result<Data>` | `await invoke('fetch')` |
| With State | `fn read(state: State<AppState>)` | `await invoke('read')` |
| With Window | `fn close(window: Window)` | `await invoke('close')` |
| With Error | `fn save() -> Result<(), String>` | `try { await invoke('save') }` |

### Events

| Pattern | Purpose | Code |
|---------|---------|------|
| Emit to window | Send to specific window | `window.emit("event", payload)` |
| Emit globally | Send to all windows | `app.emit_all("event", payload)` |
| Listen (frontend) | Receive in frontend | `await listen("event", handler)` |
| Listen (Rust) | Receive in Rust | `app.listen("event", handler)` |

### Common APIs

| API | Use Case | Platform |
|-----|----------|----------|
| `dialog::open` | File picker | Desktop |
| `dialog::save` | Save file dialog | Desktop |
| `fs::read_text_file` | Read file | All |
| `fs::write_file` | Write file | All |
| `window::WindowBuilder` | Create window | Desktop |
| `notification::Notification` | System notification | All |
| `clipboard` | Copy/paste | All |
| `shell::open` | Open URL/file | All |

## Common Mistakes

### Commands

| Mistake | Why It Fails | Fix |
|---------|--------------|-----|
| Command not in allowlist | Security restriction | Add to `tauri.conf.json` allowlist |
| Forgot `async` on frontend | Command is async | `await invoke(...)` |
| Blocking in async command | Blocks Tokio runtime | Use `spawn_blocking` or async lib |
| Serialization error | Type mismatch | Ensure types match, derive Serialize/Deserialize |
| Missing `Result` return | Can't send errors | Return `Result<T, String>` |

### IPC & Events

| Mistake | Why It Fails | Fix |
|---------|--------------|-----|
| No event cleanup | Memory leak | `unlisten()` on component unmount |
| Wrong event target | Event not received | Use correct window/global emit |
| Serialization mismatch | Payload type mismatch | Match Rust and TS types |
| Missing error handling | Uncaught promise rejection | Try/catch around invoke |

### Async Rust

| Mistake | Why It Fails | Fix |
|---------|--------------|-----|
| `std::thread::sleep` in async | Blocks runtime | Use `tokio::time::sleep` |
| Sync IO in async | Blocks runtime | Use `tokio::fs` or `spawn_blocking` |
| No `.await` | Future not executed | Add `.await` |
| Mutex deadlock | Lock held across await | Use `tokio::sync::Mutex` |
| Channel blocking | Wrong channel type | Use `tokio::sync::mpsc` for async |

## Reference Documentation

Comprehensive guides in `reference/`:

1. **tauri-core.md** - Commands, IPC, events, windows, app lifecycle (all platforms)
2. **rust-async.md** - Tokio runtime, async/await, futures, channels, error handling
3. **desktop-specific.md** - System tray, native menus, file dialogs, updater, shortcuts
4. **mobile-specific.md** - Plugins, permissions, platform channels, biometrics, lifecycle
5. **bridge-patterns.md** - Frontend ↔ Rust communication, serialization, error propagation
6. **cross-platform.md** - Conditional compilation, platform detection, shared patterns

## Working Mode

When working with Tauri cross-platform:
1. **Fetch latest docs** from context7 before implementing:
   - Tauri: `/llmstxt/tauri_app_llms-full_txt` (comprehensive, Tauri 2.0 with mobile)
2. Identify if feature is desktop-only, mobile-only, or cross-platform
3. Create Rust command for backend logic
4. Add command to allowlist in `tauri.conf.json`
5. Implement frontend invoke with proper error handling
6. Use events for push updates from Rust → frontend
7. Handle async properly with Tokio patterns
8. Test on target platforms

**Note**: Reference docs below provide quick patterns. Always use context7 for latest mobile APIs, plugins, and platform-specific features.
