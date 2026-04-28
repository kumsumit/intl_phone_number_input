import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:phone_parser/phone_parser.dart';

/// Loads `phone_parser` metadata from a writable directory for platforms that
/// need local metadata access.
class PhoneMetadataBootstrap {
  static String? _resolvedDirectoryPath;

  /// Ensures phone metadata is available to `phone_parser`.
  ///
  /// If [directoryPath] is omitted, a writable application support directory is
  /// used on native platforms. On the web, this method is a no-op.
  static Future<void> ensureInitialized({String? directoryPath}) async {
    if (kIsWeb) {
      return;
    }

    final resolvedDirectoryPath =
        directoryPath ?? await _defaultWritableDirectoryPath();

    if (_resolvedDirectoryPath == resolvedDirectoryPath) {
      return;
    }

    await MetadataFinder.readMetadataJson(resolvedDirectoryPath);
    _resolvedDirectoryPath = resolvedDirectoryPath;
  }

  /// Returns the directory path used by [ensureInitialized] when no explicit
  /// [directoryPath] is provided.
  static Future<String> defaultWritableDirectoryPath() {
    return _defaultWritableDirectoryPath();
  }

  static Future<String> _defaultWritableDirectoryPath() async {
    try {
      final appSupportDirectory = await getApplicationSupportDirectory();
      return appSupportDirectory.path;
    } catch (_) {
      return Directory.current.path;
    }
  }
}
