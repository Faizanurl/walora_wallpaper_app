import 'dart:developer' as developer;
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:share_plus/share_plus.dart';
import 'firebase_service.dart';

class DownloadService {
  static final DownloadService _instance = DownloadService._internal();
  factory DownloadService() => _instance;
  DownloadService._internal();

  final Dio _dio = Dio();

  Future<bool> requestPermissions() async {
    if (Platform.isAndroid) {
      final status = await Permission.storage.request();
      return status.isGranted;
    }
    if (Platform.isIOS) {
      final status = await Permission.photos.request();
      return status.isGranted;
    }
    return true;
  }

  Future<bool> downloadWallpaper({
    required String imageUrl,
    required String fileName,
    required String wallpaperId,
    Function(double)? onProgress,
  }) async {
    try {
      final hasPermission = await requestPermissions();
      if (!hasPermission) return false;

      final tempDir = await getTemporaryDirectory();
      final filePath = '${tempDir.path}/$fileName.jpg';

      await _dio.download(
        imageUrl,
        filePath,
        onReceiveProgress: (received, total) {
          if (total != -1 && onProgress != null) {
            onProgress(received / total);
          }
        },
      );

      final result = await ImageGallerySaver.saveFile(filePath);
      final success = result['isSuccess'] ?? false;

      if (success) {
        await FirebaseService().incrementDownloads(wallpaperId);
        await FirebaseService().addToDownloadHistory(wallpaperId);
      }

      // Clean up temp file
      final file = File(filePath);
      if (await file.exists()) await file.delete();

      return success;
    } catch (e) {
      developer.log('Download error', error: e);
      return false;
    }
  }

  Future<void> shareWallpaper({
    required String imageUrl,
    required String title,
  }) async {
    try {
      final tempDir = await getTemporaryDirectory();
      final filePath = '${tempDir.path}/share_wallpaper.jpg';

      await _dio.download(imageUrl, filePath);

      await Share.shareXFiles(
        [XFile(filePath)],
        text:
            'Check out this amazing wallpaper: $title\n\nDownloaded from Wallpaper App',
      );
    } catch (e) {
      developer.log('Share error', error: e);
      // Fallback to sharing URL
      await Share.share('Check out this amazing wallpaper: $title\n$imageUrl');
    }
  }
}
