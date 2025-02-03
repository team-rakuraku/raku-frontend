enum ApiEndpoint {
  baseUrl("https://example.com/api"),
  login("auth/login");

  final String path;

  const ApiEndpoint(this.path);
}
