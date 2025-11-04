class File {
  File(String path);

  String get path =>
      throw UnsupportedError('File is not supported on this platform');

  File get absolute =>
      throw UnsupportedError('File is not supported on this platform');
}
