import 'package:event_service/src/event_filter.dart';
import 'package:firebase_event_service/firebase_event_service.dart';

import 'counter_event.dart';
import 'counter_event_filter.dart';

class CounterEventMapper implements EventMapper {
  @override
  Map<String, dynamic> eventAttributes(event) {
    final counterEvent = event as CounterEvent;
    return {'amount': counterEvent.amount};
  }

  @override
  String eventIdentifier(event) {
    if (event is CounterIncrementEvent) {
      return 'increment';
    } else if (event is CounterDecrementEvent) {
      return 'decrement';
    }
    throw UnimplementedError('event $event not found');
  }

  @override
  Map<String, dynamic> filterAttributes(EventFilter filter) {
    return null;
  }

  @override
  String filterEventIdentifier(EventFilter filter) {
    if (filter is CounterIncrementEventFilter) {
      return 'increment';
    } else if (filter is CounterDecrementEventFilter) {
      return 'decrement';
    }
    throw UnimplementedError('filter $filter not found');
  }

  @override
  String listenPathForFilter(EventFilter filter) {
    return null;
  }

  @override
  T mapToEvent<T>(String eventIdentifier, DateTime eventDate, String path, Map<String, dynamic> eventAttributes) {
    final amount = eventAttributes['amount'] ?? 0;
    if (eventIdentifier == 'increment') {
      return CounterIncrementEvent(amount) as T;
    } else if (eventIdentifier == 'decrement') {
      return CounterDecrementEvent(amount) as T;
    }
    return null;
  }

  @override
  String publishPathForEvent(event) {
    return null;
  }
}
