import 'dart:io';

enum FlatpakInstallLocation { system, user }

Future<Process> flatpakBuilder({
  required Directory buildDir,
  required File manifestFile,
  required Directory stateDir,
  required FlatpakInstallLocation location,
  required Directory cwd,
  bool install = false,
  bool run = false,
}) async {
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
      location == FlatpakInstallLocation.system ? "--system" : "--user",
    ],
    workingDirectory: cwd.absolute.path,
  );
}
