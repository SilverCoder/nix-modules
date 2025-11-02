# State Management Reference

Flutter state management patterns: setState, Provider, Riverpod, BLoC.

## setState (Local State)

```dart
class _CounterState extends State<Counter> {
  int _count = 0;

  void _increment() {
    setState(() {
      _count++;  // Triggers rebuild
    });
  }

  @override
  Widget build(BuildContext context) {
    return Text('$_count');
  }
}
```

## Provider

```dart
// Define model
class Counter with ChangeNotifier {
  int _count = 0;
  int get count => _count;

  void increment() {
    _count++;
    notifyListeners();
  }
}

// Provide
ChangeNotifierProvider(
  create: (_) => Counter(),
  child: MyApp(),
)

// Consume
class CounterDisplay extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final counter = context.watch<Counter>();
    return Text('${counter.count}');
  }
}

// Consume without rebuild
context.read<Counter>().increment();
```

## Riverpod

```dart
// Define provider
final counterProvider = StateNotifierProvider<CounterNotifier, int>((ref) {
  return CounterNotifier();
});

class CounterNotifier extends StateNotifier<int> {
  CounterNotifier() : super(0);

  void increment() => state++;
}

// Provide
ProviderScope(
  child: MyApp(),
)

// Consume
class CounterDisplay extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final count = ref.watch(counterProvider);
    return Text('$count');
  }
}
```

## BLoC

```dart
// Events
abstract class CounterEvent {}
class IncrementEvent extends CounterEvent {}

// States
class CounterState {
  final int count;
  CounterState(this.count);
}

// BLoC
class CounterBloc extends Bloc<CounterEvent, CounterState> {
  CounterBloc() : super(CounterState(0)) {
    on<IncrementEvent>((event, emit) {
      emit(CounterState(state.count + 1));
    });
  }
}

// Provide
BlocProvider(
  create: (_) => CounterBloc(),
  child: MyApp(),
)

// Consume
BlocBuilder<CounterBloc, CounterState>(
  builder: (context, state) {
    return Text('${state.count}');
  },
)

// Dispatch
context.read<CounterBloc>().add(IncrementEvent());
```

## Decision Tree

- **Local widget state?** → useState
- **Share between few widgets?** → InheritedWidget or lift state
- **App-wide simple state?** → Provider
- **Type-safe app state?** → Riverpod
- **Complex business logic?** → BLoC
