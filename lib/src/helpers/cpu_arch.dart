import 'dart:io';
enum CpuArch { x64, arm64 }
CpuArch getCPUArchitecture() {
  var info = Process.runSync('uname', ['-m']);
  var cpu = info.stdout.toString().replaceAll('\n', '');
  if (cpu == "x86_64") {
    return CpuArch.x64;
  }else if (cpu == "aarch64") {
    return CpuArch.arm64;
  }else {
    throw "Unable to get CPU architecture unknown architecture: $cpu";
  }
}


