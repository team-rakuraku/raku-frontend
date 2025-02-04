import 'package:fpdart/fpdart.dart';

enum HttpMethod { get, post, put, delete, patch }

final class Request {
  final String url;
  final Map<String, dynamic> queryParameters;
  final Map<String, String> headers;
  final Option<String> body;
  final HttpMethod method;

  const Request({
    required this.url,
    this.queryParameters = const {},
    this.headers = const {},
    this.body = const None(),
    required this.method,
  });

  String buildUrl() => Uri.parse(url)
      .replace(
          queryParameters: queryParameters.isNotEmpty ? queryParameters : null)
      .toString();
}

final class RequestBuilder {
  final String baseUrl;
  final Option<String> endpoint;
  final Map<String, dynamic> queryParameters;
  final Map<String, String> headers;
  final Option<String> body;
  final Option<HttpMethod> method;

  const RequestBuilder({
    required this.baseUrl,
    this.endpoint = const None(),
    this.queryParameters = const {},
    this.headers = const {},
    this.body = const None(),
    this.method = const None(),
  });

  RequestBuilder setMethod(HttpMethod method) => RequestBuilder(
        baseUrl: baseUrl,
        endpoint: endpoint,
        queryParameters: queryParameters,
        headers: headers,
        body: body,
        method: Some(method),
      );

  RequestBuilder setEndpoint(String endpoint) => RequestBuilder(
        baseUrl: baseUrl,
        endpoint: Some(endpoint),
        queryParameters: queryParameters,
        headers: headers,
        body: body,
        method: method,
      );

  RequestBuilder addQueryParameter(String key, dynamic value) => RequestBuilder(
        baseUrl: baseUrl,
        endpoint: endpoint,
        queryParameters: {...queryParameters, key: value},
        headers: headers,
        body: body,
        method: method,
      );

  RequestBuilder addHeader(String key, String value) => RequestBuilder(
        baseUrl: baseUrl,
        endpoint: endpoint,
        queryParameters: queryParameters,
        headers: {...headers, key: value},
        body: body,
        method: method,
      );

  RequestBuilder setBody(String jsonBody) => RequestBuilder(
        baseUrl: baseUrl,
        endpoint: endpoint,
        queryParameters: queryParameters,
        headers: headers,
        body: Some(jsonBody),
        method: method,
      );

  Either<String, Request> build() {
    return endpoint.match(
      () => const Left("Endpoint must be provided"),
      (ep) => method.match(
        () => const Left("HTTP method must be provided"),
        (m) => Right(
          Request(
            url: '$baseUrl/$ep',
            queryParameters: queryParameters,
            headers: headers,
            body: body,
            method: m,
          ),
        ),
      ),
    );
  }
}
