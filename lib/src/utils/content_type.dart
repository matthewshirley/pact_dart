String getContentType<T>(content) {
  switch (T) {
    case Map<String, dynamic>:
      return 'application/json';
    default:
      return 'text/plain';
  }
}
