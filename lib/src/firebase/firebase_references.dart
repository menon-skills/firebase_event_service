import 'package:cloud_firestore/cloud_firestore.dart';

mixin FirestoreRefs {
  FirebaseFirestore get _db => FirebaseFirestore.instance;

  CollectionReference collectionRef(String path) {
    return _db.collection(path);
  }

  DocumentReference documentRef(String path) {
    return _db.doc(path);
  }

  CollectionReference eventCollectionRef(String rootCollectionPath, String path) {
    if (path == null || path.isEmpty) {
      return collectionRef(rootCollectionPath);
    }
    return collectionRef('$rootCollectionPath/$path');
  }

  DocumentReference eventDocumentRef(String rootCollectionPath, String path) {
    if (path == null || path.isEmpty || path.split('/').length % 2 == 0) {
      return eventCollectionRef(rootCollectionPath, path).doc();
    }
    return documentRef('$rootCollectionPath/$path');
  }
}
