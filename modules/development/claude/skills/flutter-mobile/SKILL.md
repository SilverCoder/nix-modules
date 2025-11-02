---
name: flutter-mobile
description: Flutter mobile development - widgets, state management, layouts, async patterns, platform integration (iOS/Android)
---

# Flutter Mobile Development

Build native mobile applications for iOS and Android using Flutter and Dart.

## When to Use

Use this skill when:
- Working with `.dart` files in Flutter projects
- Creating widgets and UI components
- Managing state (setState, Provider, Riverpod, BLoC)
- Building responsive layouts
- Handling async operations (Future, Stream)
- Integrating with platform-specific code
- Managing `pubspec.yaml` dependencies

Don't use for:
- Flutter web or desktop (mobile-focused)
- Pure Dart backend projects
- Non-Flutter mobile frameworks

## Quick Reference

### Widget Types

| Type | When | Rebuild |
|------|------|---------|
| StatelessWidget | Static UI, no state | Never |
| StatefulWidget | Mutable state | When setState() called |
| InheritedWidget | Share data down tree | When value changes |

### Common Widgets

| Widget | Purpose | Example |
|--------|---------|---------|
| Container | Box model | `Container(padding: EdgeInsets.all(8))` |
| Row/Column | Horizontal/Vertical layout | `Row(children: [...])` |
| ListView | Scrollable list | `ListView.builder(itemBuilder: ...)` |
| Stack | Overlapping widgets | `Stack(children: [...])` |
| Scaffold | Material page structure | `Scaffold(appBar: ..., body: ...)` |

### State Management

| Solution | Use Case | Complexity |
|----------|----------|------------|
| setState | Local widget state | Simple |
| InheritedWidget | Share data down tree | Medium |
| Provider | App-wide state | Medium |
| Riverpod | Type-safe Provider | Medium-High |
| BLoC | Complex business logic | High |

## Common Mistakes

### Widget Lifecycle

| Mistake | Why It Fails | Fix |
|---------|--------------|-----|
| setState after dispose | Widget unmounted | Check `mounted` before setState |
| Build method side effects | Called frequently | Move to initState/didChangeDependencies |
| Missing const constructors | Unnecessary rebuilds | Use `const` when possible |
| Forgetting keys in lists | Wrong widget updated | Use `Key` for list items |

### Async

| Mistake | Why It Fails | Fix |
|---------|--------------|-----|
| No error handling | Uncaught exceptions | Use try/catch or `.catchError()` |
| Not canceling streams | Memory leak | Cancel StreamSubscription in dispose |
| setState on disposed state | Widget unmounted | Check `mounted` or use FutureBuilder |

### Layout

| Mistake | Why It Fails | Fix |
|---------|--------------|-----|
| Unbounded constraints | RenderFlex overflow | Wrap with Expanded/Flexible |
| MediaQuery everywhere | Performance hit | Use LayoutBuilder or pass down |
| Not using ListView | Render all items | Use ListView.builder for long lists |

## Reference Documentation

Comprehensive guides in `reference/`:

1. **widget-composition.md** - Widget lifecycle, BuildContext, keys, composition patterns
2. **state-management.md** - setState, Provider, Riverpod, BLoC, decision trees
3. **layout-rendering.md** - Box constraints, responsive, Slivers, CustomPaint
4. **async-streams.md** - Future, Stream, builders, error handling
5. **platform-integration.md** - Platform channels, native code, packages

## Working Mode

When working with Flutter mobile:
1. **Fetch latest docs** from context7 before implementing:
   - Flutter: `/websites/main-api_flutter_dev` (main API, 27k+ examples)
2. Identify widget type needed (Stateless vs Stateful)
3. Choose state management approach based on scope
4. Use builders (ListView.builder) for dynamic lists
5. Handle async with FutureBuilder/StreamBuilder or async/await
6. Add keys to lists for correct widget identity
7. Test on both iOS and Android
8. Use const constructors for performance

**Note**: Reference docs below provide quick patterns. Always use context7 for latest widgets, packages, and platform APIs.
