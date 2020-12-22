import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:event_service/event_service.dart';

import 'event_mapper.dart';
import 'firebase/firebase_references.dart';

class FirebaseEventService with FirestoreRefs implements EventService {
  final EventMapper _mapper;
  final String _rootDocumentPath;

  FirebaseEventService({EventMapper mapper, String rootDocumentPath = 'events/event_service'})
      : assert(mapper != null),
        assert(rootDocumentPath != null),
        assert(rootDocumentPath.split('/').length % 2 == 0),
        _mapper = mapper,
        _rootDocumentPath = rootDocumentPath;

  @override
  Stream<T> listen<T>({EventFilter filter}) {
    return eventCollectionRef(_rootDocumentPath, _mapper.listenPathForFilter(filter))
        .where('date', isGreaterThan: DateTime.now())
        .snapshots()
        .map(
          (querySnapshot) =>
              querySnapshot.docs.isNotEmpty ? querySnapshot.docs.first.toEvent<T>(_mapper, _rootDocumentPath) : null,
        );
  }

  @override
  void publishEvent(event) {
    final documentRef = eventDocumentRef(_rootDocumentPath, event.writePath());
    documentRef.set(<String, dynamic>{
      'date': FieldValue.serverTimestamp(),
    });
  }

  @override
  void destroy() {}
}

extension _DocumentSnaphotToEventMapper on DocumentSnapshot {
  T toEvent<T>(EventMapper mapper, String rootDocumentPath) {
    final path = reference.path;
    if (path.startsWith(rootDocumentPath)) {
      final parts = path.replaceAll(rootDocumentPath, '').split('/');
      var collectionNames = <String>[];
      var documentIds = <String>[];
      parts.asMap().forEach((key, value) {
        if (key % 2 == 0) {
          collectionNames.add(value);
        } else {
          documentIds.add(value);
        }
      });
      final newPath = collectionNames.join('/');

      return mapper.mapToEvent(newPath, collectionNames, documentIds);
    }
    return null;
  }
}
