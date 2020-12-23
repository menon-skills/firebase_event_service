import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:event_service/event_service.dart';

import 'event_mapper.dart';
import 'firebase/firebase_references.dart';

String _eventDateKey = 'event_date';
String _eventIdentifierKey = 'event_identifier';

class FirebaseEventService with FirestoreRefs implements EventService {
  final EventMapper _mapper;
  final String _rootCollectionPath;

  FirebaseEventService({EventMapper mapper, String rootCollectionPath = 'events'})
      : assert(mapper != null),
        assert(rootCollectionPath != null),
        assert(rootCollectionPath.split('/').length % 1 == 0),
        assert(!rootCollectionPath.startsWith('/')),
        assert(!rootCollectionPath.endsWith('/')),
        _mapper = mapper,
        _rootCollectionPath = rootCollectionPath;

  @override
  Stream<T> listen<T>({EventFilter filter}) {
    final query = eventCollectionRef(_rootCollectionPath, _mapper.listenPathForFilter(filter))
        .where(_eventDateKey, isGreaterThan: DateTime.now());
    return _createQuery(query, _mapper.filterEventIdentifier(filter), _mapper.filterAttributes(filter))
        .orderBy(_eventDateKey)
        .snapshots()
        .map(
          (querySnapshot) =>
              querySnapshot.docs.isNotEmpty ? querySnapshot.docs.first.toEvent<T>(_mapper, _rootCollectionPath) : null,
        );
  }

  @override
  void publishEvent(event) {
    final documentRef = eventDocumentRef(_rootCollectionPath, _mapper.publishPathForEvent(event));
    var eventAttributes = _mapper.eventAttributes(event);
    eventAttributes[_eventDateKey] = FieldValue.serverTimestamp();
    eventAttributes[_eventIdentifierKey] = _mapper.eventIdentifier(event);
    documentRef.set(eventAttributes);
  }

  @override
  void destroy() {}

  Query _createQuery(Query query, String filterEventIdentifier, Map<String, dynamic> filterAttributes) {
    var modifiedQuery = query;
    if (filterEventIdentifier != null) {
      modifiedQuery = query.where(_eventIdentifierKey, isEqualTo: filterEventIdentifier);
    }
    if (filterAttributes != null) {
      for (final filterAttribute in filterAttributes.keys) {
        modifiedQuery = query.where(filterAttribute, isEqualTo: filterAttributes[filterAttribute]);
      }
    }
    return modifiedQuery;
  }
}

extension _DocumentSnaphotToEventMapper on DocumentSnapshot {
  T toEvent<T>(EventMapper mapper, String rootDocumentPath) {
    final path = reference.path;
    if (path.startsWith(rootDocumentPath)) {
      final realPath = path.replaceAll('$rootDocumentPath/', '');
      final eventData = data();
      final eventIdentifier = eventData.remove(_eventIdentifierKey);
      final eventTimestamp = eventData.remove(_eventDateKey) as Timestamp;
      final eventDate = eventTimestamp.toDate();

      return mapper.mapToEvent<T>(eventIdentifier, eventDate, realPath, eventData);
    }
    return null;
  }
}
