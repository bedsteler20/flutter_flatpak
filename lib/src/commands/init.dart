import 'dart:io';

import 'package:args/args.dart';
import 'package:args/command_runner.dart';
import 'package:flutter_flatpak/src/helpers/pubspec.dart';
import 'package:flutter_flatpak/src/templates/manifest.dart';
import 'package:pubspec/pubspec.dart';
import 'package:yaml/yaml.dart' as yaml;
import 'package:yaml_writer/yaml_writer.dart';
import '../helpers/string_ext.dart';
import '../helpers/desktop_file.dart';

class InitCommand extends Command {
  final name = "init";
  final description = "Initialize a new Flatpak configs in the current project";

  @override
  Future<void> run() async {
    final project = await projectDir(Directory.current);
    final flatpakDir = Directory("${project!.path}/linux/flatpak");
    final manifestFile = File("${flatpakDir.path}/manifest.yaml");
    final pubSpec = await PubSpec.load(project);
    final desktopFile = File("${flatpakDir.path}/${pubSpec.name}.desktop");
    final appStreamFile = File("${flatpakDir.path}/metainfo.xml");


    print("creating manifest ${manifestFile.path}");

    await flatpakDir.create();
    await manifestFile.create();
    await manifestFile
        .writeAsString(flatpakManifestTemplate(libName: pubSpec.name!));

    if (!await desktopFile.exists()) {
      await desktopFile.create();
      await desktopFile.writeAsString(DesktopFile(
        name: "Flutter Demo",
        exec: "/app/${pubSpec.name}",
        icon: "com.example.${pubSpec.name}",
      ).toString());
    }


    if (!await appStreamFile.exists()) {
      final content = """<?xml version="1.0" encoding="UTF-8"?>
<component type="application">
  <id>com.example.${pubSpec.name!.pascalCase()}</id>
  <name>${pubSpec.name}</name>
  <summary>Flutter Demo</summary>
  <metadata_license>CC0-1.0</metadata_license>
  <developer_name>You</developer_name>
  <url type="homepage">https://example.com</url>
</component>""";
      await appStreamFile.create();
      await appStreamFile.writeAsString(content);
    }
  }
}
