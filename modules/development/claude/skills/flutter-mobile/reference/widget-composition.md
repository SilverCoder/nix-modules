# Widget Composition Reference

Core widget patterns, lifecycle, and composition for Flutter.

## Widget Basics

### StatelessWidget

```dart
class MyWidget extends StatelessWidget {
  final String title;

  const MyWidget({Key? key, required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(title);
  }
}
```

### StatefulWidget

```dart
class Counter extends StatefulWidget {
  const Counter({Key? key}) : super(key: key);

  @override
  State<Counter> createState() => _CounterState();
}

class _CounterState extends State<Counter> {
  int _count = 0;

  @override
  void initState() {
    super.initState();
    // Initialize, fetch data, setup listeners
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Called when InheritedWidget changes
  }

  @override
  void didUpdateWidget(Counter oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Called when parent rebuilds with new config
  }

  @override
  void dispose() {
    // Cancel subscriptions, dispose controllers
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        if (mounted) {  // Check before setState
          setState(() {
            _count++;
          });
        }
      },
      child: Text('Count: $_count'),
    );
  }
}
```

## BuildContext

```dart
// Theme access
final theme = Theme.of(context);
final textTheme = theme.textTheme;

// MediaQuery
final size = MediaQuery.of(context).size;
final padding = MediaQuery.of(context).padding;

// Navigator
Navigator.of(context).push(...);
Navigator.of(context).pop();

// Scaffold
Scaffold.of(context).showSnackBar(...);

// InheritedWidget
final provider = Provider.of<MyProvider>(context);
```

## Keys

```dart
// ValueKey - based on value
ListView(
  children: items.map((item) =>
    ItemWidget(key: ValueKey(item.id), item: item)
  ).toList(),
)

// ObjectKey - based on object identity
ObjectKey(myObject)

// UniqueKey - always unique
UniqueKey()

// GlobalKey - access widget/state from anywhere
final key = GlobalKey<FormState>();
Form(key: key, ...)
key.currentState?.validate();
```

## Composition Patterns

### Builder Pattern

```dart
Builder(
  builder: (context) {
    // New context with Scaffold ancestor
    return ElevatedButton(
      onPressed: () {
        Scaffold.of(context).showSnackBar(...);
      },
    );
  },
)
```

### LayoutBuilder

```dart
LayoutBuilder(
  builder: (context, constraints) {
    if (constraints.maxWidth > 600) {
      return WideLayout();
    } else {
      return NarrowLayout();
    }
  },
)
```

### Custom Widgets

```dart
class Card extends StatelessWidget {
  final Widget child;
  final Color? color;

  const Card({
    Key? key,
    required this.child,
    this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: color ?? Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [BoxShadow(blurRadius: 4, color: Colors.black12)],
      ),
      padding: EdgeInsets.all(16),
      child: child,
    );
  }
}
```

## Performance

```dart
// ❌ Creates new widget every build
Widget build(BuildContext context) {
  return MyWidget(child: Text('Hello'));
}

// ✅ Use const
Widget build(BuildContext context) {
  return const MyWidget(child: Text('Hello'));
}

// ✅ Extract to final if dynamic
final widget = Text(dynamicValue);
Widget build(BuildContext context) {
  return MyWidget(child: widget);
}
```
