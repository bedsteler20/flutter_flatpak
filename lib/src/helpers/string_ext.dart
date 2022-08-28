extension StringExt on String {
  String pascalCase() {
    var newStr = '';

    for (var i = 0; i < length; i++) {
      if (this[i] == ' ' || this[i] == '_' || this[i] == '_') {
        continue;
      }

      if (i == 0) {
        newStr += this[i].toUpperCase();
      } else if (this[i - 1] == ' ' ||
          this[i - 1] == '_' ||
          this[i - 1] == '_') {
        newStr += this[i].toUpperCase();
      } else {
        newStr += this[i];
      }
    }

    return newStr;
  }
}
