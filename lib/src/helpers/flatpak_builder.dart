import 'dart:io';

Future<Process> flatpakBuilder({
  required Directory buildDir,
  required File manifestFile,
  required Directory stateDir,
  String location = "user",
  required Directory cwd,
  bool install = false,
  bool run = false,
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
    ],
    workingDirectory: cwd.absolute.path,
  );
}
