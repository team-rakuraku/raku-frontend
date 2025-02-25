import 'package:fpdart/fpdart.dart';

final class RestAPIRequestBuilder {
  final String baseUrl;
  final Option<String> endpoint;
  final Map<String, dynamic> queryParameters;
  final Map<String, String> headers;
  final Option<String> body;

  const RestAPIRequestBuilder({
    required this.baseUrl,
    this.endpoint = const None(),
    this.queryParameters = const {},
    this.headers = const {},
    this.body = const None(),
  });

  // Set endpoint for the request
  RestAPIRequestBuilder setEndpoint(String endpoint) => RestAPIRequestBuilder(
    baseUrl: baseUrl,
    endpoint: Some(endpoint),
    queryParameters: queryParameters,
    headers: headers,
    body: body,
  );

  // Add a query parameter to the request
  RestAPIRequestBuilder addQueryParameter(String key, dynamic value) {
    value = value.toString(); // Convert any value to String

    return RestAPIRequestBuilder(
      baseUrl: baseUrl,
      endpoint: endpoint,
      queryParameters: {...queryParameters, key: value},
      headers: headers,
      body: body,
    );
  }

  RestAPIRequestBuilder addHeader(String key, String value) =>
      RestAPIRequestBuilder(
        baseUrl: baseUrl,
        endpoint: endpoint,
        queryParameters: queryParameters,
        headers: {...headers, key: value},
        body: body,
      );

  RestAPIRequestBuilder setBody(String jsonBody) => RestAPIRequestBuilder(
    baseUrl: baseUrl,
    endpoint: endpoint,
    queryParameters: queryParameters,
    headers: headers,
    body: Some(jsonBody),
  );

  String getUrl() {
    final String urlWithParams = queryParameters.isNotEmpty
        ? '$baseUrl/${endpoint.getOrElse(() => '')}?${Uri(queryParameters: queryParameters).query}'
        : '$baseUrl/${endpoint.getOrElse(() => '')}';

    return urlWithParams;
  }

  // Return headers as a Map
  Map<String, String> buildHeaders() {
    return headers;
  }
}
