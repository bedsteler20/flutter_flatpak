import 'dart:convert';

import 'package:flutter_flatpak/src/helpers/string_ext.dart';
import 'package:yaml_writer/yaml_writer.dart';

String flatpakManifestTemplate({
  required String libName,
}) {
  final template = {
    "app-id": "com.example.${libName.pascalCase()}",
    "sdk": "org.freedesktop.Sdk",
    "runtime": "org.freedesktop.Platform",
    "runtime-version": "21.08",
    "command": "/app/$libName",
    "finish-args": [
      "--share=network",
      "--socket=fallback-x11",
      "--socket=wayland",
    ],
    "modules": [
      {
        "name": "app",
        "buildsystem": "simple",
        "build-commands": [
          "cp -r ./* /app/",
        ],
        "sources": [
          {
            "type": "dir",
            "path": "\$PROJECT_ROOT/build/linux/x64/\$FLUTTER_MODE/bundle"
          }
        ]
      },
    ]
  };

  return jsonEncode(template);
}
