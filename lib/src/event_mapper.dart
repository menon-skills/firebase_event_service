import 'package:event_service/event_service.dart';

abstract class EventMapper {
  String publishPathForEvent(event);
  String listenPathForFilter(EventFilter filter);
  T mapToEvent<T>(String path, List<String> keys, List<String> values);
}
