extension ToInt on bool {
  int toInt() => this ? 1 : 0;
}

extension ToBool on int {
  bool toBool() => this == 1 ? true : false;
}
