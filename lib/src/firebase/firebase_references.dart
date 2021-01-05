import 'package:cloud_firestore/cloud_firestore.dart';

mixin FirestoreRefs {
  CollectionReference collectionRef(FirebaseFirestore db, String path) {
    return db.collection(path);
  }

  DocumentReference documentRef(FirebaseFirestore db, String path) {
    return db.doc(path);
  }

  CollectionReference eventCollectionRef(FirebaseFirestore db, String rootCollectionPath, String path) {
    if (path == null || path.isEmpty) {
      return collectionRef(db, rootCollectionPath);
    }
    return collectionRef(db, '$rootCollectionPath/$path');
  }

  DocumentReference eventDocumentRef(FirebaseFirestore db, String rootCollectionPath, String path) {
    if (path == null || path.isEmpty || path.split('/').length % 2 == 0) {
      return eventCollectionRef(db, rootCollectionPath, path).doc();
    }
    return documentRef(db, '$rootCollectionPath/$path');
  }
}
