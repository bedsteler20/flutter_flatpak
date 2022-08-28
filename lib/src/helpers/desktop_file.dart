class DesktopFile {
  String? icon;
  String? path;
  String? name;
  String? comment;
  String? exec;
  List<String>? catagories = [];
  bool? terminal = false;

  DesktopFile({
    this.catagories,
    this.path,
    this.name,
    this.comment,
    this.exec,
    this.terminal,
    this.icon,
  });

  String _entry(String key, value) {
    if (value == null) {
      return "";
    } else if (value is List) {
      var str = '';
      for (String s in value) {
        str += "$s;";
      }
      return "$key=$str\n";
    } else {
      return "$key=$value\n";
    }
  }

  @override
  String toString() {
    // ignore: prefer_interpolation_to_compose_strings
    return "[Desktop Entry]\n" +
        _entry("Type", "Application") +
        _entry("Name", name) +
        _entry("Icon", icon) +
        _entry("Terminal", terminal) +
        _entry("Exec", exec) +
        _entry("Comment", comment) +
        _entry("Path", path) +
        _entry("Catagories", catagories);
  }
}
