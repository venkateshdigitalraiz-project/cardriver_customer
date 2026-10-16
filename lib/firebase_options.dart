// File generated for Firebase project: driverbooking-4b700
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.

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
      default:
        return android;
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBvtvOKWHImzzkLKYN2eAuLBG1wMS4hm80',
    appId: '1:538470397018:android:8a5cfe2d11216f0c399463',
    messagingSenderId: '538470397018',
    projectId: 'driverbooking-4b700',
    storageBucket: 'driverbooking-4b700.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBvtvOKWHImzzkLKYN2eAuLBG1wMS4hm80',
    appId: '1:538470397018:android:8a5cfe2d11216f0c399463',
    messagingSenderId: '538470397018',
    projectId: 'driverbooking-4b700',
    storageBucket: 'driverbooking-4b700.firebasestorage.app',
  );

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBvtvOKWHImzzkLKYN2eAuLBG1wMS4hm80',
    appId: '1:538470397018:android:8a5cfe2d11216f0c399463',
    messagingSenderId: '538470397018',
    projectId: 'driverbooking-4b700',
    storageBucket: 'driverbooking-4b700.firebasestorage.app',
  );
}
