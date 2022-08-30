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
      "--device=dri",
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
            "path": "\$PROJECT_ROOT/build/linux/x64/\$FLUTTER_MODE/bundle",
            "only-arches": ["x86_64"]
          },
          {
            "type": "dir",
            "path": "\$PROJECT_ROOT/build/linux/arm64/\$FLUTTER_MODE/bundle",
            "only-arches": ["aarch64"]
          }
        ]
      },
      {
        "name": "meta",
        "buildsystem": "simple",
        "build-commands": [
          "install -Dm 644 $appId.desktop -t /app/share/applications/",
          "install -Dm 644 $appId.appdata.xml -t /app/share/appdata/",
          "cp -r icons /app/share/",
        ],
        "sources": [
          {
            "type": "file",
            "path": "\$PROJECT_ROOT/linux/share/applications/$appId.desktop"
          },
          {
            "type": "dir",
            "path": "\$PROJECT_ROOT/linux/share/icons",
            "dest": "icons",
          },
          {
            "type": "file",
            "path": "\$PROJECT_ROOT/linux/share/appdata/$appId.appdata.xml",
          }
        ]
      },
    ]
  };

  return jsonEncode(template);
}

String appStreamTemplate(String appId) {
  return """<?xml version='1.0' encoding='utf-8'?>
<component type="desktop">
  <id>$appId</id>
  <name>Flutter Demo</name>
  <summary>Flutter Demo</summary>
  <developer_name>You</developer_name>
  <metadata_license>CC0-1.0</metadata_license>
  <project_license>MIT</project_license>
  <description>
    <p>Flutter Demo</p>
  </description>
  <content_rating type="oars-1.1"/>
</component>
""";
}
