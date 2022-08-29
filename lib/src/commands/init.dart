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

  late String _appId;

  @override
  late final argParser = ArgParser()
    ..addOption(
      "app-id",
      defaultsTo: "com.flutter.Example",
      callback: (p0) => _appId,
    );

  @override
  Future<void> run() async {
    final project = await projectDir(Directory.current);
    final flatpakDir = Directory("${project!.path}/linux/flatpak");
    final manifestFile = File("${flatpakDir.path}/manifest.json");
    final pubSpec = await PubSpec.load(project);
    final desktopFile = File("${flatpakDir.path}/$_appId.desktop");

    print("creating manifest ${manifestFile.path}");

    await flatpakDir.create();
    await manifestFile.create();
    await manifestFile.writeAsString(flatpakManifestTemplate(
        command: "/app/${pubSpec.name}", appId: _appId));

    if (!await desktopFile.exists()) {
      await desktopFile.create();
      await desktopFile.writeAsString(DesktopFile(
        name: "Flutter Demo",
        exec: "/app/${pubSpec.name}",
        icon: _appId,
      ).toString());
    }
  }
}
