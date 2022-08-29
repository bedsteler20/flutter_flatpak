import 'dart:convert';

import 'package:flutter_flatpak/src/helpers/string_ext.dart';
import 'package:yaml_writer/yaml_writer.dart';

String flatpakManifestTemplate({
  required String command,
  required String appId,
}) {
  final template = {
    "\$schema":
        "https://raw.githubusercontent.com/flatpak/flatpak-builder/main/data/flatpak-manifest.schema.json",
    "app-id": appId,
    "sdk": "org.freedesktop.Sdk",
    "runtime": "org.freedesktop.Platform",
    "runtime-version": "21.08",
    "command": command,
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
      {
        "name": "desktop",
        "buildsystem": "simple",
        "build-commands": [
          "install -Dm 644 $appId.desktop /app/share/applications/",
        ],
        "sources": [
          {
            "type": "file",
            "path": "\$PROJECT_ROOT/linux/flatpak/$appId.desktop"
          }
        ]
      },
    ]
  };

  return jsonEncode(template);
}
