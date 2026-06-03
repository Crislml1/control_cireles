import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  const DefaultFirebaseOptions._();

  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return ios;
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        return windows;
      case TargetPlatform.fuchsia:
        throw UnsupportedError(
          'Firebase no esta configurado para Fuchsia.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCmbgZe2_AMwchwN88z4FL57qm5MET9Mp0',
    appId: '1:316236177757:android:df194f587235e003bd88b4',
    messagingSenderId: '316236177757',
    projectId: 'control-de-cireles',
    storageBucket: 'control-de-cireles.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBqUaSCyWGByNVdqUZPb5RhlPO09ggqehA',
    appId: '1:316236177757:ios:ab0ce2fd337155b0bd88b4',
    messagingSenderId: '316236177757',
    projectId: 'control-de-cireles',
    storageBucket: 'control-de-cireles.firebasestorage.app',
    iosBundleId: 'com.cireles.control',
  );

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDUhB56Mxo3JCbMHbuwZPRbmDcGpVeGm98',
    appId: '1:316236177757:web:0ffcfde6c1af1fdfbd88b4',
    messagingSenderId: '316236177757',
    projectId: 'control-de-cireles',
    authDomain: 'control-de-cireles.firebaseapp.com',
    storageBucket: 'control-de-cireles.firebasestorage.app',
    measurementId: 'G-DBL76T6VFQ',
  );

  static const FirebaseOptions windows = web;
}
