// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
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
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCE7cfXWAl6sw0-kkSj2ozFGwKo4pEcokI',
    appId: '1:857469939826:web:42403b3f3412ff399f12eb',
    messagingSenderId: '857469939826',
    projectId: 'assignment2-f42a1',
    authDomain: 'assignment2-f42a1.firebaseapp.com',
    storageBucket: 'assignment2-f42a1.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAGkdVswHu52tW34Qj3mbJO5-OB4OtuNCM',
    appId: '1:857469939826:android:76b16b139aa3b7fe9f12eb',
    messagingSenderId: '857469939826',
    projectId: 'assignment2-f42a1',
    storageBucket: 'assignment2-f42a1.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCMkHGTwP8OFqH7GXZUIMPVDb8hGfpRgr8',
    appId: '1:857469939826:ios:362ce3e6370b4f459f12eb',
    messagingSenderId: '857469939826',
    projectId: 'assignment2-f42a1',
    storageBucket: 'assignment2-f42a1.appspot.com',
    iosBundleId: 'utas.edu.au.kit721.assignment4.assignment4',
  );
}
