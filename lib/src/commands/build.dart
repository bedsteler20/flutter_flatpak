import 'dart:io';

import 'package:args/args.dart';
import 'package:args/command_runner.dart';
import 'package:flutter_flatpak/src/helpers/flatpak_builder.dart';

import '../helpers/pubspec.dart';

class BuildCommand extends Command {
  @override
  final name = 'build';
  @override
  final description = 'Builds and installs the flatpak';

  late String _mode;

  @override
  late final argParser = ArgParser()
    ..addOption(
      "mode",
      allowed: ["debug", "profile", "release"],
      defaultsTo: "release",
      callback: (p0) => _mode = p0!,
    );

  @override
  run() async {
    final project = await projectDir(Directory.current);
    final buildRoot = Directory("${project!.path}/build");
    final buildDir = Directory("${buildRoot.path}/linux/x64/$_mode");
    final programDir = Directory("${buildDir.path}/bundle");
    final flatpakBuildDir = Directory("${buildDir.path}/flatpak");
    final manifestFile = File("${project.path}/linux/flatpak/manifest.yaml");
    final manifestTempFile =
        File("${project.path}/linux/flatpak/.manifest.tmp.yaml");

    if (!await programDir.exists()) {
      final buildCommand = await Process.start(
        "flutter",
        ["build", "linux", "--$_mode"],
        workingDirectory: project.path,
      );
      stdout.addStream(buildCommand.stdout);
      stderr.addStream(buildCommand.stderr);

      await buildCommand.exitCode;
    }

    if (!await flatpakBuildDir.exists()) {
      await flatpakBuildDir.create(recursive: true);
    }

    // Inset vars in manifest file
    if (!await manifestTempFile.exists()) await manifestTempFile.create();
    await manifestTempFile.writeAsString(
      (await manifestFile.readAsString())
          .replaceAll("\$PROJECT_ROOT", project.absolute.path)
          .replaceAll("\$FLUTTER_MODE", _mode),
    );

    final buildProcess = await flatpakBuilder(
      buildDir: flatpakBuildDir,
      manifestFile: manifestTempFile,
      stateDir: Directory("${buildDir.path}/.flatpak-builder"),
      location: FlatpakInstallLocation.user,
      cwd: Directory("${project.path}/linux/flatpak"),
      install: true,
    );

    stdout.addStream(buildProcess.stdout);
    await buildProcess.exitCode;
    await manifestTempFile.delete();
  }
}
