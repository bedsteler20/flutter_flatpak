import 'package:args/command_runner.dart';
import 'package:flutter_flatpak/init.dart';

void main(List<String> arguments) {
  CommandRunner("flutter-flatpak", "Flutter flatpak")
    ..addCommand(InitCommand())
    ..run(arguments);
}
