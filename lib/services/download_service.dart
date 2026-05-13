import 'dart:io';
import 'package:dio/dio.dart';
import 'package:gal/gal.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
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
      // Check permission
      final hasAccess = await Gal.hasAccess(toAlbum: true);
      if (!hasAccess) {
        await Gal.requestAccess(toAlbum: true);
      }

      final tempDir = await getTemporaryDirectory();
      final filePath = '${tempDir.path}/$fileName.jpg';

      // Download file
      await _dio.download(
        imageUrl,
        filePath,
        onReceiveProgress: (received, total) {
          if (total != -1 && onProgress != null) {
            onProgress(received / total);
          }
        },
      );

      // Save to gallery
      await Gal.putImage(filePath, album: 'Wallpapers');

      // Update Firebase
      await FirebaseService().incrementDownloads(wallpaperId);
      await FirebaseService().addToDownloadHistory(wallpaperId);

      // Clean temp file
      final file = File(filePath);
      if (await file.exists()) await file.delete();

      return true;
    } catch (e) {
      print('Download error: $e');
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
        text: 'Check out this wallpaper: $title',
      );
    } catch (e) {
      await Share.share('$title\n$imageUrl');
    }
  }
}