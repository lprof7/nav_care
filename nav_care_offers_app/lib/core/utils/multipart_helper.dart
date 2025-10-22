import 'dart:io' as io;
import 'dart:typed_data';

import 'package:cross_file/cross_file.dart' show XFile;
import 'package:dio/dio.dart';

class MultipartHelper {
  const MultipartHelper._();

  static Future<MultipartFile?> toMultipartFile(
    dynamic file, {
    String fallbackName = 'upload',
  }) async {
    if (file == null) return null;
    if (file is MultipartFile) return file;

    if (file is XFile) {
      return MultipartFile.fromFile(file.path, filename: file.name);
    }

    if (file is io.File) {
      final fileName = _extractName(file.path, fallbackName);
      return MultipartFile.fromFile(file.path, filename: fileName);
    }

    if (file is String && file.isNotEmpty) {
      final fileName = _extractName(file, fallbackName);
      return MultipartFile.fromFile(file, filename: fileName);
    }

    if (file is Uint8List) {
      return MultipartFile.fromBytes(file, filename: fallbackName);
    }

    if (file is List<int>) {
      return MultipartFile.fromBytes(file, filename: fallbackName);
    }

    return null;
  }

  static String _extractName(String path, String fallback) {
    final parts = path.split(RegExp(r'[\\/]'));
    return parts.isNotEmpty && parts.last.isNotEmpty ? parts.last : fallback;
  }
}
