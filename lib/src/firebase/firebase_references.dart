import 'package:cloud_firestore/cloud_firestore.dart';

mixin FirestoreRefs {
  FirebaseFirestore get _db => FirebaseFirestore.instance;

  CollectionReference collectionRef(String path) {
    return _db.collection(path);
  }

  DocumentReference documentRef(String path) {
    return _db.doc(path);
  }

  CollectionReference eventCollectionRef(String rootDocumentPath, String path) {
    return collectionRef('$rootDocumentPath/$path');
  }

  DocumentReference eventDocumentRef(String rootDocumentPath, String path) {
    return documentRef('$rootDocumentPath/$path');
  }

}
