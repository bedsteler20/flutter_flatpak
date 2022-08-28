import 'dart:io';

import 'package:pubspec/pubspec.dart';

Future<PubSpec?> getPubSpec() async {
  final pubspec = await projectDir(Directory.current);
  
  if (pubspec == null) {
    return null;
  }else {
    return await PubSpec.loadFile(pubspec.path);
  }
}

Future<Directory?> projectDir(Directory start) async {
  final f = File("${start.path}/pubspec.yaml");
  if (await f.exists()) {
    return f.parent;
  } else if (f.path == "/pubspec.yaml") {
    return null;
  } else {
    return projectDir(start.parent);
  }
}
