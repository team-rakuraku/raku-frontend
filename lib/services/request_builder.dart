import 'package:fpdart/fpdart.dart';

final class RequestBuilder {
  final String baseUrl;
  final Option<String> endpoint;
  final Map<String, dynamic> queryParameters;
  final Map<String, String> headers;

  const RequestBuilder({
    required this.baseUrl,
    this.endpoint = const None(),
    this.queryParameters = const {},
    this.headers = const {},
  });

  RequestBuilder setEndpoint(String endpoint) => RequestBuilder(
        baseUrl: baseUrl,
        endpoint: Some(endpoint),
        queryParameters: queryParameters,
        headers: headers,
      );

  RequestBuilder addQueryParameter(String key, dynamic value) => RequestBuilder(
        baseUrl: baseUrl,
        endpoint: endpoint,
        queryParameters: {...queryParameters, key: value},
        headers: headers,
      );

  /// 헤더 추가
  RequestBuilder addHeader(String key, String value) => RequestBuilder(
        baseUrl: baseUrl,
        endpoint: endpoint,
        queryParameters: queryParameters,
        headers: {...headers, key: value},
      );

  /// 최종 Request 객체 생성
  Either<String, _Request> build() {
    return endpoint.match(
      () => const Left("Endpoint must be set before building the request."),
      (ep) => Right(
        _Request(
          url: '$baseUrl/$ep',
          queryParameters: queryParameters,
          headers: headers,
        ),
      ),
    );
  }
}

final class _Request {
  final String url;
  final Map<String, dynamic> queryParameters;
  final Map<String, String> headers;

  const _Request({
    required this.url,
    this.queryParameters = const {},
    this.headers = const {},
  });

  String buildUrl() {
    final uri = Uri.parse(url).replace(queryParameters: queryParameters.isNotEmpty ? queryParameters : null);
    return uri.toString();
  }
}
