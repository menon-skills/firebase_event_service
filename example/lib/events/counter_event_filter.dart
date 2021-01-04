import 'package:event_service/event_service.dart';

import 'counter_event.dart';

abstract class CounterEventFilter implements EventFilter {}

class CounterIncrementEventFilter extends CounterEventFilter {
  @override
  bool filter(event) {
    return event is CounterIncrementEvent;
  }
}

class CounterDecrementEventFilter extends CounterEventFilter {
  @override
  bool filter(event) {
    return event is CounterDecrementEvent;
  }
}
