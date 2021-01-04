import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:event_service/event_service.dart';

import 'event_mapper.dart';
import 'firebase/firebase_references.dart';

class FirebaseEventService with FirestoreRefs implements EventService {
  final EventMapper _mapper;
  final String _rootCollectionPath;
  final DateTime _eventsAfter;
  final String _eventDateKey;
  final String _eventIdentifierKey;

  FirebaseEventService(
      {EventMapper mapper,
      String rootCollectionPath = 'events',
      DateTime eventsAfter,
      String eventDateKey,
      String eventIdentifierKey})
      : assert(mapper != null),
        assert(rootCollectionPath != null),
        assert(rootCollectionPath.split('/').length % 1 == 0),
        assert(!rootCollectionPath.startsWith('/')),
        assert(!rootCollectionPath.endsWith('/')),
        _mapper = mapper,
        _rootCollectionPath = rootCollectionPath,
        _eventsAfter = eventsAfter ?? DateTime.now(),
        _eventDateKey = eventDateKey ?? 'event_date',
        _eventIdentifierKey = eventIdentifierKey ?? 'event_identifier';

  @override
  Stream<T> listen<T>({EventFilter filter}) {
    final query = eventCollectionRef(_rootCollectionPath, _mapper.listenPathForFilter(filter))
        .where(_eventDateKey, isGreaterThan: _eventsAfter);
    return _createQuery(query, _mapper.filterEventIdentifier(filter), _mapper.filterAttributes(filter))
        .orderBy(_eventDateKey, descending: false)
        .snapshots()
        .map((querySnapshot) {
      return querySnapshot.docs.isNotEmpty
          ? querySnapshot.docs.last.toEvent<T>(_mapper, _rootCollectionPath, _eventDateKey, _eventIdentifierKey)
          : null;
    });
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
  T toEvent<T>(EventMapper mapper, String rootDocumentPath, String eventDateKey, String eventIdentifierKey) {
    if (metadata.hasPendingWrites) {
      return null;
    }
    final path = reference.path;
    if (path.startsWith(rootDocumentPath)) {
      final realPath = path.replaceAll('$rootDocumentPath/', '');
      final eventData = data();
      final eventIdentifier = eventData.remove(eventIdentifierKey);
      final eventTimestamp = eventData.remove(eventDateKey) as Timestamp;
      if (eventTimestamp != null) {
        final eventDate = eventTimestamp.toDate();

        return mapper.mapToEvent<T>(eventIdentifier, eventDate, realPath, eventData);
      }
    }
    return null;
  }
}
