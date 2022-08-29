import 'dart:convert';
import 'dart:io';

import 'package:args/args.dart';
import 'package:args/command_runner.dart';
import 'package:flutter_flatpak/src/helpers/flatpak_builder.dart';
import 'package:flutter_flatpak/src/helpers/helpers.dart';

import '../helpers/pubspec.dart';

class BuildCommand extends Command {
  @override
  final name = 'build';
  @override
  final description = 'Builds and installs the flatpak';

  late String _mode;
  late String _location;
  late bool _bundle;
  late CpuArch _cpuArch;

  @override
  late final argParser = ArgParser()
    ..addOption(
      "mode",
      allowed: ["debug", "profile", "release"],
      defaultsTo: "release",
      callback: (p0) => _mode = p0!,
    )
    ..addOption(
      "location",
      allowed: ["user", "system"],
      defaultsTo: "user",
      callback: (p0) => _location = p0!,
    )
    ..addFlag(
      "bundle",
      defaultsTo: false,
      callback: (p0) => _bundle = p0,
    )
    ..addOption(
      "target-platform",
      callback: ((p0) {
        if (p0 == "linux-arm64") {
          _cpuArch = CpuArch.arm64;
        } else if (p0 == "linux-x64") {
          _cpuArch = CpuArch.x64;
        } else {
          _cpuArch = getCPUArchitecture();
        }
      }),
    );

  @override
  run() async {
    final project = await projectDir(Directory.current);
    final buildRoot = Directory("${project!.path}/build");
    final buildDir = Directory(
        "${buildRoot.path}/linux/${_cpuArch == CpuArch.arm64 ? "arm64" : "x64"}/$_mode");
    final programDir = Directory("${buildDir.path}/bundle");
    final flatpakBuildDir = Directory("${buildDir.path}/flatpak");
    final manifestFile = File("${project.path}/linux/flatpak/manifest.json");
    final manifestTempFile =
        File("${project.path}/linux/flatpak/.manifest.tmp.json");

    if (!await programDir.exists()) {
      final buildCommand = await Process.start(
        "flutter",
        [
          "build",
          "linux",
          "--$_mode",
          "--target-platform=${_cpuArch == CpuArch.arm64 ? "linux-arm64" : "linux-x64"}",
        ],
        workingDirectory: project.path,
      );
      stdout.addStream(buildCommand.stdout);
      stderr.addStream(buildCommand.stderr);

      await buildCommand.exitCode;
    }

    if (!await flatpakBuildDir.exists()) {
      await flatpakBuildDir.create(recursive: true);
    }

    final manifest = jsonDecode(
      (await manifestFile.readAsString())
          .replaceAll("\$PROJECT_ROOT", project.absolute.path)
          .replaceAll("\$FLUTTER_MODE", _mode),
    );
    final appId = manifest["app-id"];

    if (!await manifestTempFile.exists()) await manifestTempFile.create();
    await manifestTempFile.writeAsString(jsonEncode(manifest));

    final buildProcess = await flatpakBuilder(
      buildDir: flatpakBuildDir,
      manifestFile: manifestTempFile,
      stateDir: Directory("${buildDir.path}/.flatpak-builder"),
      location: _location,
      cwd: Directory("${project.path}/linux/flatpak"),
      install: true,
    );

    stdout.addStream(buildProcess.stdout);
    await buildProcess.exitCode;
    await manifestTempFile.delete();

    if (_bundle) {
      print("Bundling flatpak");
      final bundleProcess = await Process.start(
        "flatpak",
        [
          "build-bundle",
          _location == "user"
              ? "${Platform.environment["HOME"]}/.local/share/flatpak/repo"
              : "/var/lib/flatpak/repo",
          "$_mode-$_cpuArch.flatpak",
          appId,
        ],
        workingDirectory: buildDir.path,
      );
      stderr.addStream(bundleProcess.stderr);
      stdout.addStream(bundleProcess.stdout);
      await bundleProcess.exitCode;
    }
  }
}
