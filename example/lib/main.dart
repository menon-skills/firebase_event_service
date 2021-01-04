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
    print('Initialize firebase app');
    await Firebase.initializeApp();
  } catch (e) {
    rethrow;
  }
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
        // This makes the visual density adapt to the platform that you run
        // the app on. For desktop platforms, the controls will be smaller and
        // closer together (more dense) than on mobile platforms.
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
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Invoke "debug painting" (press "p" in the console, choose the
          // "Toggle Debug Paint" action from the Flutter Inspector in Android
          // Studio, or the "Toggle Debug Paint" command in Visual Studio Code)
          // to see the wireframe for each widget.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
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
