import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return web;
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError('Unsupported platform');
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyC-YjzdP09Xqw3zm-jl4DHt-FCIOCApJwg',
    appId: '1:504730489572:android:413ffc28c00024aa8012f1',
    messagingSenderId: '504730489572',
    projectId: 'wallpaperapp-ea64e',
    storageBucket: 'wallpaperapp-ea64e.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyC-YjzdP09Xqw3zm-jl4DHt-FCIOCApJwg',
    appId: '1:504730489572:android:413ffc28c00024aa8012f1',
    messagingSenderId: '504730489572',
    projectId: 'wallpaperapp-ea64e',
    storageBucket: 'wallpaperapp-ea64e.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDAVYcr1NExWQOfwiQPdjdT2ulagTnu9iU',
    appId: '1:504730489572:ios:820ccb190e11cdfa8012f1',
    messagingSenderId: '504730489572',
    projectId: 'wallpaperapp-ea64e',
    storageBucket: 'wallpaperapp-ea64e.firebasestorage.app',
    iosBundleId: 'com.wallpaper.app',
  );
}
