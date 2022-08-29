import 'dart:io';

import 'package:flutter_flatpak/src/helpers/helpers.dart';

Future<Process> flatpakBuilder({
  required Directory buildDir,
  required File manifestFile,
  required Directory stateDir,
  String location = "user",
  required Directory cwd,
  bool install = false,
  bool run = false,
  CpuArch? cpuArch,
}) async {
  assert(location == "user" || location == "system");
  return await Process.start(
    "flatpak-builder",
    [
      buildDir.absolute.path,
      manifestFile.absolute.path,
      if (install) "--install",
      if (run) "--run",
      "--state-dir",
      stateDir.absolute.path,
      "--force-clean",
      "--$location",
      if (cpuArch != null)
        "--arch=${cpuArch == CpuArch.x64 ? "x86_64" : "aarch64"}",
    ],
    workingDirectory: cwd.absolute.path,
  );
}
