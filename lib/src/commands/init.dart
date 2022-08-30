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
      callback: (p0) => _appId = p0!,
    );

  Future<void> _stealIcon(Directory project, int size) async {
    final flutterRoot = Platform.resolvedExecutable
        .replaceAll("bin/cache/dart-sdk/bin/dart", "");

    final ogIcon = File(
      "$flutterRoot/examples/image_list/macos/Runner"
      "/Assets.xcassets/AppIcon.appiconset/app_icon_$size.png",
    );

    final newIcon = File(
      "${project.path}/linux/share/icons/hicolor/${size}x$size/apps/$_appId.png",
    );

    if (await newIcon.exists()) return;

    await newIcon.parent.create(recursive: true);
    await ogIcon.copy(newIcon.path);
  }

  @override
  Future<void> run() async {
    final project = await projectDir(Directory.current);
    final pubSpec = await PubSpec.load(project!);

    final manifestFile = File("${project.path}/linux/flatpak.yaml");
    final desktopFile =
        File("${project.path}/linux/share/applications/$_appId.desktop");
    final appSteamFile =
        File("${project.path}/linux/share/appdata/$_appId.appdata.xml");

    print("creating manifest ${manifestFile.path}");

    await manifestFile.create(recursive: true);
    await manifestFile.writeAsString(flatpakManifestTemplate(
        command: "/app/${pubSpec.name}", appId: _appId));

    if (!await desktopFile.exists()) {
      await desktopFile.create(recursive: true);
      await desktopFile.writeAsString(DesktopFile(
        name: "Flutter Demo",
        exec: "/app/${pubSpec.name}",
        icon: _appId,
      ).toString());
    }

    if (!await appSteamFile.exists()) {
      await appSteamFile.create(recursive: true);
      await appSteamFile.writeAsString(appStreamTemplate(_appId));
    }

    _stealIcon(project, 128);
    _stealIcon(project, 64);
    _stealIcon(project, 256);
    _stealIcon(project, 512);
  }
}
