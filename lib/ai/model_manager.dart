import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'model_catalog.dart';

class ModelManager {
  final Dio _dio = Dio();

  Future<String> download(ModelChoice model, {
    required void Function(int received, int total) onProgress,
  }) async {
    final support = await getApplicationSupportDirectory();
    final directory = Directory(path.join(support.path, 'models'));
    await directory.create(recursive: true);
    final finalPath = path.join(directory.path, model.file);
    final partialPath = '$finalPath.part';

    // Never leave a partial file looking like a valid installed model.
    final partial = File(partialPath);
    if (await partial.exists()) await partial.delete();

    await _dio.download(
      model.url,
      partialPath,
      onReceiveProgress: onProgress,
      options: Options(
        followRedirects: true,
        receiveTimeout: const Duration(minutes: 60),
        headers: {'User-Agent': 'ExpeditionAurelio/0.2'},
      ),
      deleteOnError: true,
    );

    final bytes = await partial.length();
    if (bytes < model.minimumBytes) {
      await partial.delete();
      throw StateError('Downloaded file is smaller than the expected model size.');
    }

    // Atomic rename prevents the app from opening an incomplete download.
    await partial.rename(finalPath);
    return finalPath;
  }

  Future<String?> installedPath(ModelChoice model) async {
    final support = await getApplicationSupportDirectory();
    final file = File(path.join(support.path, 'models', model.file));
    return await file.exists() ? file.path : null;
  }
}
