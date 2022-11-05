String getContentType(content) {
  if (content is Map) {
    return 'application/json';
  }

  return 'text/plain';
}
