import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';

import '../../../types/failure.dart';

final class _RestAPIResponseWrapper<T> {
  final T data;
  final Map<String, String> headers;

  const _RestAPIResponseWrapper({
    required this.data,
    this.headers = const {},
  });
}

final class RestAPIResponseParser<T> {
  final T Function(Map<String, dynamic>) parse;
  final Map<String, String> Function(Map<String, dynamic>)? headerParser;

  const RestAPIResponseParser({
    required this.parse,
    this.headerParser,
  });

  Either<Failure, _RestAPIResponseWrapper<T>> parseResponse(Object? rawData) =>
      _toMap(rawData).flatMap(_safeParse).map((parsedData) => _RestAPIResponseWrapper(
          data: parsedData,
          headers: _parseHeaders(rawData as Map<String, dynamic>)));

  Either<Failure, _RestAPIResponseWrapper<List<T>>> parseListResponse(
          Object? rawData) =>
      _toMap(rawData).flatMap(_extractList).flatMap(_parseAll).map(
          (listOfModels) => _RestAPIResponseWrapper(
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

extension ParseWithStatusCode<T> on RestAPIResponseParser<T> {
  Either<Failure, _RestAPIResponseWrapper<T>> parseDioResponse(Response response) =>
      _validateStatus(response).flatMap((res) => parseResponse(res.data).map(
            (parsed) =>
                _RestAPIResponseWrapper(data: parsed.data, headers: parsed.headers),
          ));

  Either<Failure, _RestAPIResponseWrapper<List<T>>> parseListDioResponse(
          Response response) =>
      _validateStatus(response).flatMap((res) => parseListResponse(res.data)
          .map((parsedList) => _RestAPIResponseWrapper(
              data: parsedList.data, headers: parsedList.headers)));

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
