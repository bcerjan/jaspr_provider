import 'package:jaspr/jaspr.dart';

import 'provider.dart';

/// {@macro provider.valuelistenableprovider}
class ValueListenableProvider<T> extends StatelessComponent {
  /// {@template provider.valuelistenableprovider}
  /// Listens to a [ValueListenable] and exposes its current value.
  ///
  /// This is useful for testing purposes, to easily simular a provider update:
  ///
  /// ```dart
  /// test('example', () async {
  ///   // Create a ValueNotifier that tests will use to drive the application
  ///   final counter = ValueNotifier(0);
  ///
  ///   // Mount the application using ValueListenableProvider
  ///   await tester.pumpComponent(
  ///     ValueListenableProvider<int>.value(
  ///       value: counter,
  ///       child: MyApp(),
  ///     ),
  ///   );
  ///
  ///   // Tests can now simulate a provider update by updating the notifier
  ///   // then calling tester.pump()
  ///   counter.value++;
  ///   await tester.pump();
  /// });
  /// ```
  /// {@endtemplate}
  ValueListenableProvider.value({
    Key? key,
    required ValueListenable<T> value,
    UpdateShouldNotify<T>? updateShouldNotify,
    this.child,
  })  : _valueListenable = value,
        _updateShouldNotify = updateShouldNotify,
        super(key: key);

  final ValueListenable<T> _valueListenable;
  final UpdateShouldNotify<T>? _updateShouldNotify;

  /// Component which will be passed to the [build].
  final Component? child;

  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield ValueListenableBuilder<T>(
      valueListenable: _valueListenable,
      builder: (context, value, _) sync* {
        yield Provider<T>.value(
          value: value,
          updateShouldNotify: _updateShouldNotify,
          child: child,
        );
      },
    );
  }
}

/// Builds a [Component] when given a concrete value of a [ValueListenable<T>].
///
/// If the `child` parameter provided to the [ValueListenableBuilder] is not
/// null, the same `child` component is passed back to this [ValueComponentBuilder]
/// and should typically be incorporated in the returned component tree.
///
/// See also:
///
///  * [ValueListenableBuilder], a component which invokes this builder each time
///    a [ValueListenable] changes value.
typedef ValueComponentBuilder<T> = Iterable<Component> Function(
    BuildContext context, T value, Component? child);

/// A component whose content stays synced with a [ValueListenable].
///
/// Given a [ValueListenable<T>] and a [builder] which builds components from
/// concrete values of `T`, this class will automatically register itself as a
/// listener of the [ValueListenable] and call the [builder] with updated values
/// when the value changes.
///
/// {@youtube 560 315 https://www.youtube.com/watch?v=s-ZG-jS5QHQ}
///
/// ## Performance optimizations
///
/// If your [builder] function contains a subtree that does not depend on the
/// value of the [ValueListenable], it's more efficient to build that subtree
/// once instead of rebuilding it on every animation tick.
///
/// If you pass the pre-built subtree as the [child] parameter, the
/// [ValueListenableBuilder] will pass it back to your [builder] function so
/// that you can incorporate it into your build.
///
/// Using this pre-built child is entirely optional, but can improve
/// performance significantly in some cases and is therefore a good practice.
///
/// {@tool snippet}
///
/// This sample shows how you could use a [ValueListenableBuilder] instead of
/// setting state on the whole `Scaffold` in the default `flutter create` app.
///
/// ```dart
/// class MyHomePage extends StatefulComponent {
///   const MyHomePage({Key? key, required this.title}) : super(key: key);
///   final String title;
///
///   @override
///   State<MyHomePage> createState() => _MyHomePageState();
/// }
///
/// class _MyHomePageState extends State<MyHomePage> {
///   final ValueNotifier<int> _counter = ValueNotifier<int>(0);
///   final Component goodJob = const Text('Good job!');
///   @override
///   Iterable<Component> build(BuildContext context) {
///     return Scaffold(
///       appBar: AppBar(
///         title: Text(component.title)
///       ),
///       body: Center(
///         child: Column(
///           mainAxisAlignment: MainAxisAlignment.center,
///           children: <Component>[
///             const Text('You have pushed the button this many times:'),
///             ValueListenableBuilder<int>(
///               builder: (BuildContext context, int value, Component? child) sync* {
///                 // This builder will only get called when the _counter
///                 // is updated.
///                 return Row(
///                   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
///                   children: <Component>[
///                     Text('$value'),
///                     child!,
///                   ],
///                 );
///               },
///               valueListenable: _counter,
///               // The child parameter is most helpful if the child is
///               // expensive to build and does not depend on the value from
///               // the notifier.
///               child: goodJob,
///             )
///           ],
///         ),
///       ),
///       floatingActionButton: FloatingActionButton(
///         child: const Icon(Icons.plus_one),
///         onPressed: () => _counter.value += 1,
///       ),
///     );
///   }
/// }
/// ```
/// {@end-tool}
///
/// See also:
///
///  * [StreamBuilder], where a builder can depend on a [Stream] rather than
///    a [ValueListenable] for more advanced use cases.
class ValueListenableBuilder<T> extends StatefulComponent {
  /// Creates a [ValueListenableBuilder].
  ///
  /// The [valueListenable] and [builder] arguments must not be null.
  /// The [child] is optional but is good practice to use if part of the component
  /// subtree does not depend on the value of the [valueListenable].
  const ValueListenableBuilder({
    Key? key,
    required this.valueListenable,
    required this.builder,
    this.child,
  }) : super(key: key);

  /// The [ValueListenable] whose value you depend on in order to build.
  ///
  /// This component does not ensure that the [ValueListenable]'s value is not
  /// null, therefore your [builder] may need to handle null values.
  ///
  /// This [ValueListenable] itself must not be null.
  final ValueListenable<T> valueListenable;

  /// A [ValueComponentBuilder] which builds a component depending on the
  /// [valueListenable]'s value.
  ///
  /// Can incorporate a [valueListenable] value-independent component subtree
  /// from the [child] parameter into the returned component tree.
  ///
  /// Must not be null.
  final ValueComponentBuilder<T> builder;

  /// A [valueListenable]-independent component which is passed back to the [builder].
  ///
  /// This argument is optional and can be null if the entire component subtree
  /// the [builder] builds depends on the value of the [valueListenable]. For
  /// example, if the [valueListenable] is a [String] and the [builder] simply
  /// returns a [Text] component with the [String] value.
  final Component? child;

  @override
  State<StatefulComponent> createState() => _ValueListenableBuilderState<T>();
}

class _ValueListenableBuilderState<T> extends State<ValueListenableBuilder<T>> {
  late T value;

  @override
  void initState() {
    super.initState();
    value = component.valueListenable.value;
    component.valueListenable.addListener(_valueChanged);
  }

  @override
  void didUpdateComponent(ValueListenableBuilder<T> oldComponent) {
    if (oldComponent.valueListenable != component.valueListenable) {
      oldComponent.valueListenable.removeListener(_valueChanged);
      value = component.valueListenable.value;
      component.valueListenable.addListener(_valueChanged);
    }
    super.didUpdateComponent(oldComponent);
  }

  @override
  void dispose() {
    component.valueListenable.removeListener(_valueChanged);
    super.dispose();
  }

  void _valueChanged() {
    setState(() {
      value = component.valueListenable.value;
    });
  }

  @override
  Iterable<Component> build(BuildContext context) {
    return component.builder(context, value, component.child);
  }
}
