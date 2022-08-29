import 'dart:convert';
import 'dart:io';

import 'package:yaml/yaml.dart';

class FlutterProject {
  final root = _projectDirSearch(Directory.current)!;

  static Directory? _projectDirSearch(Directory start) {
    final f = File("${start.path}/pubspec.yaml");
    if (f.existsSync()) {
      return f.parent;
    } else if (f.path == "/pubspec.yaml") {
      return null;
    } else {
      return _projectDirSearch(start.parent);
    }
  }
}
