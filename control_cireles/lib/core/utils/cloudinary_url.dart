String cloudinaryTransformedUrl(
  String originalUrl, {
  required String transformation,
}) {
  if (originalUrl.isEmpty || !originalUrl.contains('/upload/')) {
    return originalUrl;
  }

  return originalUrl.replaceFirst('/upload/', '/upload/$transformation/');
}

String cloudinaryThumbnailUrl(String originalUrl) {
  return cloudinaryTransformedUrl(
    originalUrl,
    transformation: 'w_160,h_160,c_fill,q_auto,f_auto',
  );
}

String cloudinaryDetailUrl(String originalUrl) {
  return cloudinaryTransformedUrl(
    originalUrl,
    transformation: 'w_1280,c_limit,q_auto,f_auto',
  );
}
