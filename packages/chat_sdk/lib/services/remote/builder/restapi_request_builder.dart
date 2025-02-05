import 'package:fpdart/fpdart.dart';

enum HttpMethod { get, post, put, delete, patch }

final class RestAPIRequest {
  final String url;
  final Map<String, dynamic> queryParameters;
  final Map<String, String> headers;
  final Option<String> body;
  final HttpMethod method;

  const RestAPIRequest({
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

final class RestAPIRequestBuilder {
  final String baseUrl;
  final Option<String> endpoint;
  final Map<String, dynamic> queryParameters;
  final Map<String, String> headers;
  final Option<String> body;
  final Option<HttpMethod> method;

  const RestAPIRequestBuilder({
    required this.baseUrl,
    this.endpoint = const None(),
    this.queryParameters = const {},
    this.headers = const {},
    this.body = const None(),
    this.method = const None(),
  });

  RestAPIRequestBuilder setMethod(HttpMethod method) => RestAPIRequestBuilder(
        baseUrl: baseUrl,
        endpoint: endpoint,
        queryParameters: queryParameters,
        headers: headers,
        body: body,
        method: Some(method),
      );

  RestAPIRequestBuilder setEndpoint(String endpoint) => RestAPIRequestBuilder(
        baseUrl: baseUrl,
        endpoint: Some(endpoint),
        queryParameters: queryParameters,
        headers: headers,
        body: body,
        method: method,
      );

  RestAPIRequestBuilder addQueryParameter(String key, dynamic value) => RestAPIRequestBuilder(
        baseUrl: baseUrl,
        endpoint: endpoint,
        queryParameters: {...queryParameters, key: value},
        headers: headers,
        body: body,
        method: method,
      );

  RestAPIRequestBuilder addHeader(String key, String value) => RestAPIRequestBuilder(
        baseUrl: baseUrl,
        endpoint: endpoint,
        queryParameters: queryParameters,
        headers: {...headers, key: value},
        body: body,
        method: method,
      );

  RestAPIRequestBuilder setBody(String jsonBody) => RestAPIRequestBuilder(
        baseUrl: baseUrl,
        endpoint: endpoint,
        queryParameters: queryParameters,
        headers: headers,
        body: Some(jsonBody),
        method: method,
      );

  Either<String, RestAPIRequest> build() {
    return endpoint.match(
      () => const Left("Endpoint must be provided"),
      (ep) => method.match(
        () => const Left("HTTP method must be provided"),
        (m) => Right(
          RestAPIRequest(
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
