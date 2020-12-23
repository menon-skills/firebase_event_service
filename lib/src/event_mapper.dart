import 'package:event_service/event_service.dart';

abstract class EventMapper {
  String publishPathForEvent(event);
  Map<String, dynamic> eventAttributes(event);
  String eventIdentifier(event);

  String listenPathForFilter(EventFilter filter);
  String filterEventIdentifier(EventFilter filter);
  Map<String, dynamic> filterAttributes(EventFilter filter);

  T mapToEvent<T>(String eventIdentifier, DateTime eventDate, String path, Map<String, dynamic> eventAttributes);
}
