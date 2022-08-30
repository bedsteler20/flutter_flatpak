import 'dart:convert';
import 'dart:io';

import 'package:args/args.dart';
import 'package:args/command_runner.dart';
import 'package:flutter_flatpak/src/project.dart';
import 'package:yaml/yaml.dart';

import '../helpers/flatpak_builder.dart';
import '../helpers/cpu_arch.dart';

class BuildCommand extends Command {
  @override
  final name = 'build';
  @override
  final description = 'Builds and installs the flatpak';

  late String _mode;
  late String _location;
  late bool _bundle;
  late CpuArch _cpuArch;
  late FlutterProject _project;

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

  Directory get _buildDir => Directory(
      "${_project.root.path}/build/linux/${_cpuArch == CpuArch.arm64 ? "arm64" : "x64"}/$_mode");

  Future<Process> _flutterBuild() async {
    return await Process.start(
      "flutter",
      [
        "build",
        "linux",
        "--$_mode",
        "--target-platform=${_cpuArch == CpuArch.arm64 ? "linux-arm64" : "linux-x64"}",
      ],
      workingDirectory: _project.root.path,
    );
  }

  Future<Map> _readManifest() async {
    final jsonF = File("${_project.root.path}/linux/flatpak.json");
    final yamlF = File("${_project.root.path}/linux/flatpak.yaml");
    var str = "";
    var isJson = false;

    if (await jsonF.exists()) {
      isJson = true;
      str = await jsonF.readAsString();
    } else {
      str = await yamlF.readAsString();
    }

    str = str.replaceAll("\$PROJECT_ROOT", _project.root.path);
    str = str.replaceAll("\$FLUTTER_MODE", _mode);
    return isJson ? jsonDecode(str) : loadYaml(str);
  }

  Future<Process> _bundleFlatpak(String appId) async {
    print("Bundling flatpak");
    return await Process.start(
      "flatpak",
      [
        "build-bundle",
        _location == "user"
            ? "${Platform.environment["HOME"]}/.local/share/flatpak/repo"
            : "/var/lib/flatpak/repo",
        "$_mode-$_cpuArch.flatpak",
        appId,
      ],
      workingDirectory: _buildDir.path,
    );
  }

  @override
  run() async {
    _project = FlutterProject();
    final manifestTempFile =
        File("${_project.root.path}/linux/.manifest.tmp.json");

    if (!await File("${_buildDir.path}/bundle").exists()) {
      final flutterProcess = await _flutterBuild();
      stdout.addStream(flutterProcess.stdout);
      stderr.addStream(flutterProcess.stderr);
      await flutterProcess.exitCode;
    }

    await Directory("${_buildDir.path}/flatpak").create();

    final manifest = await _readManifest();

    if (!await manifestTempFile.exists()) await manifestTempFile.create();
    await manifestTempFile.writeAsString(jsonEncode(manifest));

    final buildProcess = await flatpakBuilder(
      buildDir: Directory("${_buildDir.path}/flatpak"),
      manifestFile: manifestTempFile,
      stateDir: Directory("${_buildDir.path}/.flatpak-builder"),
      location: _location,
      cwd: Directory("${_project.root.path}/linux"),
      install: true,
    );

    stdout.addStream(buildProcess.stdout);
    stderr.addStream(buildProcess.stderr);
    await buildProcess.exitCode;
    await manifestTempFile.delete();

    if (_bundle) {
      final bundleProcess = await _bundleFlatpak(manifest["app-id"]);
      await bundleProcess.exitCode;
    }
  }
}
