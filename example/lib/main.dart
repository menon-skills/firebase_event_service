import 'package:flutter/material.dart';
import 'package:firebase_event_service/firebase_event_service.dart';
import 'package:event_service/event_service.dart';

import 'package:firebase_core/firebase_core.dart';

import 'events/counter_event.dart';
import 'events/counter_event_filter.dart';
import 'events/counter_event_mapper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp();
  } catch (e) {
    rethrow;
  }
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Firebase Event Service Demo'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;
  final EventService eventService = FirebaseEventService(mapper: CounterEventMapper());

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  var incrementListener;
  var decrementListener;

  @override
  void initState() {
    incrementListener =
        widget.eventService.listen<CounterIncrementEvent>(filter: CounterIncrementEventFilter()).listen((event) {
      if (event != null) {
        _modifyCounter(event.amount);
      }
    });
    decrementListener =
        widget.eventService.listen<CounterDecrementEvent>(filter: CounterDecrementEventFilter()).listen((event) {
      if (event != null) {
        _modifyCounter(event.amount * -1);
      }
    });
    super.initState();
  }

  void _modifyCounter(int amount) {
    setState(() {
      _counter += amount;
    });
  }

  void _incrementCounter() {
    widget.eventService.publishEvent(CounterIncrementEvent());
  }

  void _decrementCounter() {
    widget.eventService.publishEvent(CounterDecrementEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'You have pushed the button this many times:',
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FloatingActionButton(
                    onPressed: _decrementCounter,
                    tooltip: 'Decrement',
                    child: Icon(Icons.remove),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Text(
                      '$_counter',
                      style: Theme.of(context).textTheme.headline4,
                    ),
                  ),
                  FloatingActionButton(
                    onPressed: _incrementCounter,
                    tooltip: 'Increment',
                    child: Icon(Icons.add),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
