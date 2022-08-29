import 'dart:convert';

import 'package:flutter_flatpak/src/helpers/string_ext.dart';
import 'package:yaml_writer/yaml_writer.dart';

String flatpakManifestTemplate({
  required String libName,
}) {
  final template = {
    "\$schema":
        "https://raw.githubusercontent.com/flatpak/flatpak-builder/main/data/flatpak-manifest.schema.json",
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
        "name": "app_x64",
        "only-arches": ["x64"],
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
      {
        "name": "app_aarch64",
        "only-arches": ["aarch64"],
        "buildsystem": "simple",
        "build-commands": [
          "cp -r ./* /app/",
        ],
        "sources": [
          {
            "type": "dir",
            "path": "\$PROJECT_ROOT/build/linux/arm64/\$FLUTTER_MODE/bundle"
          }
        ]
      },
      
    ]
  };

  return jsonEncode(template);
}
