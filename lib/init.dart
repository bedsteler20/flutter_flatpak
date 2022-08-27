import 'dart:io';

import 'package:args/args.dart';
import 'package:args/command_runner.dart';
import 'package:flutter_flatpak/helpers/pubspec.dart';
import 'package:pubspec/pubspec.dart';
import 'package:yaml/yaml.dart' as yaml;
import 'package:yaml_writer/yaml_writer.dart';
import './helpers/string_ext.dart';

Future<void> init(String appId, Directory project) async {
  final flatpakDir = Directory("${project.path}/linux/flatpak");
  final manifest = File("${flatpakDir}/manifest.yaml");

  if (!flatpakDir.existsSync()) {
    await flatpakDir.create();
  }
  if (!manifest.existsSync()) {
    await manifest.create();
  }
}

class InitCommand extends Command {
  final name = "init";
  final description = "Initialize a new Flatpak configs in the current project";

  @override
  Future<void> run() async {
    final project = await projectDir(Directory.current);
    final flatpakDir = Directory("${project!.path}/linux/flatpak");
    final manifestFile = File("${flatpakDir.path}/manifest.yaml");
    final pubSpec = await PubSpec.load(project);

    print("creating manifest ${manifestFile.path}");
    await flatpakDir.create();
    await manifestFile.create();

    final manifest = {
      "app-id": "com.example.${pubSpec.name!.pascalCase()}",
      "sdk": "org.freedesktop.Sdk",
      "runtime": "org.freedesktop.Platform",
      "runtime-version": "21.08",
      "command": "/app/${pubSpec.name}",
      "modules": [
        {
          "name": "app",
          "buildsystem": "simple",
          "build-commands": [
            "install -Dm 755 lib /app/"
                "install -Dm 755 data /app/"
                "install -Dm 755 ${pubSpec.name} /app/"
          ],
          "sources": [
            {
              "type": "dir",
              "path": "\$FLUTTER_BUILD_DIR/linux/x64/\$FLUTTER_MODE/bundle"
            }
          ]
        },
      ]
    };
    final manifestYaml = YAMLWriter().write(manifest);

    await manifestFile.writeAsString(manifestYaml);

    final desktopFile = File("${flatpakDir.path}/${pubSpec.name}.desktop");
    

  }
}
