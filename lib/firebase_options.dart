import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return FirebaseOptions(
        apiKey: "AIzaSyAxBzO7j9hqARutf_DhBY5FD4DLd8jx4mI",
        authDomain: "ultimo-e3c28.firebaseapp.com",
        projectId: "ultimo-e3c28",
        storageBucket: "ultimo-e3c28.firebasestorage.app",
        messagingSenderId: "426963760095",
        appId: "1:426963760095:android:b4be483e16d962d57e8a6a",
        measurementId: "your-measurement-id",
      );
    } else if (defaultTargetPlatform == TargetPlatform.android) {
      return FirebaseOptions(
        apiKey: "AIzaSyAxBzO7j9hqARutf_DhBY5FD4DLd8jx4mI",
        authDomain: "ultimo-e3c28.firebaseapp.com",
        projectId: "ultimo-e3c28",
        storageBucket: "ultimo-e3c28.firebasestorage.app",
        messagingSenderId: "426963760095",
        appId: "1:426963760095:android:b4be483e16d962d57e8a6a",

      );
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      return FirebaseOptions(
        apiKey: "your-ios-api-key",
        authDomain: "ultimo-e3c28.firebaseapp.com",
        projectId: "ultimo-e3c28",
        storageBucket: "ultimo-e3c28.firebasestorage.app",
        messagingSenderId: "426963760095",
        appId: "1:426963760095:android:b4be483e16d962d57e8a6a",
        iosBundleId: "your.ios.bundle.id",
      );
    }
    throw UnsupportedError('This platform is not supported');
  }
}
