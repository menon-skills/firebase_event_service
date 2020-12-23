import 'package:event_service/event_service.dart';

abstract class EventMapper {
  String publishPathForEvent(event);
  String listenPathForFilter(EventFilter filter);
  Map<String, dynamic> filterAttributes(EventFilter filter);
  Map<String, dynamic> eventAttributes(event);
  T mapToEvent<T>(String path, Map<String, dynamic> eventAttributes);
}
