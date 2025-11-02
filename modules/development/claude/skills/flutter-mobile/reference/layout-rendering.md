# Layout & Rendering Reference

Box constraints, responsive layouts, Slivers, and custom painting.

## Box Constraints

```dart
// Constraints flow down, sizes flow up
// Parent passes constraints → child picks size → parent positions child

// Types of constraints:
// - Tight: min == max (must be exact size)
// - Loose: min == 0 (child chooses up to max)
// - Unbounded: max == infinity
```

## Common Layouts

```dart
// Row & Column
Row(
  mainAxisAlignment: MainAxisAlignment.spaceBetween,
  crossAxisAlignment: CrossAxisAlignment.center,
  children: [Widget1(), Widget2()],
)

// Stack (overlapping)
Stack(
  alignment: Alignment.center,
  children: [Background(), Foreground()],
)

// Flexible & Expanded
Row(
  children: [
    Flexible(flex: 1, child: Widget1()),
    Expanded(flex: 2, child: Widget2()),  // Expanded = Flexible(fit: FlexFit.tight)
  ],
)

// Container
Container(
  padding: EdgeInsets.all(16),
  margin: EdgeInsets.symmetric(vertical: 8),
  decoration: BoxDecoration(
    color: Colors.blue,
    borderRadius: BorderRadius.circular(8),
  ),
  child: Text('Hello'),
)
```

## Responsive Design

```dart
// MediaQuery
final size = MediaQuery.of(context).size;
final isLarge = size.width > 600;

// LayoutBuilder
LayoutBuilder(
  builder: (context, constraints) {
    if (constraints.maxWidth > 600) {
      return WideLayout();
    }
    return NarrowLayout();
  },
)

// OrientationBuilder
OrientationBuilder(
  builder: (context, orientation) {
    return orientation == Orientation.portrait
        ? PortraitLayout()
        : LandscapeLayout();
  },
)
```

## Slivers (Advanced Scrolling)

```dart
CustomScrollView(
  slivers: [
    SliverAppBar(
      floating: true,
      expandedHeight: 200,
      flexibleSpace: FlexibleSpaceBar(title: Text('Title')),
    ),
    SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) => ListTile(title: Text('Item $index')),
        childCount: 20,
      ),
    ),
    SliverGrid(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
      ),
      delegate: SliverChildBuilderDelegate(
        (context, index) => Card(child: Text('$index')),
        childCount: 10,
      ),
    ),
  ],
)
```

## ListView Patterns

```dart
// Builder (efficient for long lists)
ListView.builder(
  itemCount: items.length,
  itemBuilder: (context, index) {
    return ListTile(title: Text(items[index]));
  },
)

// Separated
ListView.separated(
  itemCount: items.length,
  itemBuilder: (context, index) => ListTile(title: Text(items[index])),
  separatorBuilder: (context, index) => Divider(),
)
```
