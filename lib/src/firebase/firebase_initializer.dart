import 'package:firebase_core/firebase_core.dart';

Future<void> initFirebaseApp() async {
  try {
    await Firebase.initializeApp();
  } catch (e) {
    print('Initializing firebase app failed: $e');
    rethrow;
  }
}
