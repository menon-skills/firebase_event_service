import 'package:event_service/event_service.dart';

abstract class EventMapper {
  String publishPathForEvent(event);
  String listenPathForFilter(EventFilter filter);
  dynamic mapToEvent(String path, List<String> keys, List<String> values);
}
