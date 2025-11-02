# Async & Streams Reference

Future, Stream, async/await patterns, and error handling.

## Future

```dart
// Basic async/await
Future<String> fetchData() async {
  final response = await http.get(Uri.parse('https://api.example.com'));
  return response.body;
}

// Error handling
try {
  final data = await fetchData();
} catch (e) {
  print('Error: $e');
}

// .then/.catchError
fetchData()
  .then((data) => print(data))
  .catchError((error) => print(error));

// Wait for multiple
final results = await Future.wait([
  fetchUser(),
  fetchPosts(),
]);
```

## FutureBuilder

```dart
FutureBuilder<User>(
  future: fetchUser(),
  builder: (context, snapshot) {
    if (snapshot.hasError) {
      return Text('Error: ${snapshot.error}');
    }

    if (snapshot.connectionState == ConnectionState.waiting) {
      return CircularProgressIndicator();
    }

    return UserCard(user: snapshot.data!);
  },
)
```

## Stream

```dart
// Create stream
Stream<int> countStream() async* {
  for (int i = 0; i < 10; i++) {
    await Future.delayed(Duration(seconds: 1));
    yield i;
  }
}

// Listen
final subscription = countStream().listen(
  (value) => print(value),
  onError: (error) => print('Error: $error'),
  onDone: () => print('Done'),
);

// Cancel
subscription.cancel();

// StreamController
final controller = StreamController<String>();
controller.stream.listen((data) => print(data));
controller.add('Hello');
controller.close();
```

## StreamBuilder

```dart
Stream Builder<int>(
  stream: countStream(),
  builder: (context, snapshot) {
    if (snapshot.hasError) {
      return Text('Error: ${snapshot.error}');
    }

    if (!snapshot.hasData) {
      return CircularProgressIndicator();
    }

    return Text('Count: ${snapshot.data}');
  },
)
```

## Common Patterns

```dart
// Avoid setState on disposed widget
Future<void> loadData() async {
  final data = await fetchData();
  if (mounted) {  // Check before setState
    setState(() {
      _data = data;
    });
  }
}

// Or use FutureBuilder
FutureBuilder(
  future: fetchData(),
  builder: (context, snapshot) {
    // No setState needed
    return snapshot.hasData
        ? DataView(snapshot.data!)
        : CircularProgressIndicator();
  },
)

// Dispose streams
StreamSubscription? _subscription;

@override
void initState() {
  super.initState();
  _subscription = stream.listen((data) {
    setState(() => _data = data);
  });
}

@override
void dispose() {
  _subscription?.cancel();
  super.dispose();
}
```
