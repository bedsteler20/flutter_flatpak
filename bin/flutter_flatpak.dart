import 'package:args/command_runner.dart';
import 'package:flutter_flatpak/src/commands/build.dart';
import 'package:flutter_flatpak/src/commands/init.dart';

void main(List<String> arguments) {
  CommandRunner("flutter-flatpak", "Flutter flatpak")
    ..addCommand(InitCommand())
    ..addCommand(BuildCommand())
    ..run(arguments);
}
