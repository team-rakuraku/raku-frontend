import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';

import '../../types/failure.dart';

final class _ResponseWrapper<T> {
  final T data;
  final Map<String, String> headers;

  const _ResponseWrapper({
    required this.data,
    this.headers = const {},
  });
}

final class ResponseParser<T> {
  final T Function(Map<String, dynamic>) parse;
  final Map<String, String> Function(Map<String, dynamic>)? headerParser;

  const ResponseParser({
    required this.parse,
    this.headerParser,
  });

  Either<Failure, _ResponseWrapper<T>> parseResponse(Object? rawData) =>
      _toMap(rawData).flatMap(_safeParse).map((parsedData) => _ResponseWrapper(
          data: parsedData,
          headers: _parseHeaders(rawData as Map<String, dynamic>)));

  Either<Failure, _ResponseWrapper<List<T>>> parseListResponse(
          Object? rawData) =>
      _toMap(rawData).flatMap(_extractList).flatMap(_parseAll).map(
          (listOfModels) => _ResponseWrapper(
              data: listOfModels,
              headers: _parseHeaders(rawData as Map<String, dynamic>)));

  Either<Failure, Map<String, dynamic>> _toMap(
          Object? rawData) =>
      Either.fromPredicate(
              rawData,
              (data) => data is Map<String, dynamic>,
              (data) => buildFailure(
                  error: Exception(
                      "Expected Map<String, dynamic>, got ${data.runtimeType}"),
                  stackTrace: StackTrace.current))
          .map((data) => data as Map<String, dynamic>);

  Either<Failure, List<Map<String, dynamic>>> _extractList(
          Map<String, dynamic> json) =>
      Either.fromNullable(
        json['data'],
        () => buildFailure(
          error: Exception("Missing 'data' key in response."),
          stackTrace: StackTrace.current,
        ),
      ).flatMap((rawList) => rawList is List
          ? Right(rawList.whereType<Map<String, dynamic>>().toList())
          : Left(buildFailure(
              error: Exception(
                  "Expected a List under 'data', got ${rawList.runtimeType}."),
              stackTrace: StackTrace.current,
            )));

  Either<Failure, T> _safeParse(Map<String, dynamic> json) => Either.tryCatch(
      () => parse(json),
      (error, stackTrace) =>
          buildFailure(error: error, stackTrace: stackTrace));

  Either<Failure, List<T>> _parseAll(List<Map<String, dynamic>> listOfMap) =>
      listOfMap.traverseEither(_safeParse);

  Map<String, String> _parseHeaders(Map<String, dynamic> rawData) =>
      headerParser?.call(rawData) ?? const {};
}

extension ParseWithStatusCode<T> on ResponseParser<T> {
  Either<Failure, _ResponseWrapper<T>> parseDioResponse(Response response) =>
      _validateStatus(response).flatMap((res) => parseResponse(res.data).map(
            (parsed) =>
                _ResponseWrapper(data: parsed.data, headers: parsed.headers),
          ));

  Either<Failure, _ResponseWrapper<List<T>>> parseListDioResponse(
          Response response) =>
      _validateStatus(response)
          .flatMap((res) => parseListResponse(res.data).map(
                (parsedList) => _ResponseWrapper(
                    data: parsedList.data, headers: parsedList.headers),
              ));

  Either<Failure, Response> _validateStatus(Response response) =>
      Either.fromPredicate(
        response,
        (res) =>
            res.statusCode != null &&
            res.statusCode! >= 200 &&
            res.statusCode! <= 299,
        (res) => buildFailure(
          error: Exception("HTTP Error: ${res.statusCode}"),
          stackTrace: StackTrace.current,
        ),
      );
}
