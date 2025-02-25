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
      _toMap(rawData).flatMap(_safeParse).flatMap((parsedData) => _parseHeaders(rawData as Map<String, dynamic>)
          .map((headers) => _RestAPIResponseWrapper(data: parsedData, headers: headers)));

  Either<Failure, _RestAPIResponseWrapper<List<T>>> parseListResponse(Object? rawData) => _toMap(rawData)
      .flatMap(_ensureList)
      .flatMap(_parseAll)
      .flatMap((listOfModels) => _parseHeaders(rawData as Map<String, dynamic>)
          .map((headers) => _RestAPIResponseWrapper(data: listOfModels, headers: headers)));
}

extension ParseWithStatusCode<T> on RestAPIResponseParser<T> {
  Either<Failure, Map<String, dynamic>> _toMap(Object? rawData) => rawData is Map<String, dynamic>
      ? Right(rawData)
      : Left(Failure(
          error: Exception("Expected Map<String, dynamic>, got ${rawData.runtimeType}"),
          stackTrace: StackTrace.current,
          message: "Invalid response format"));

  Either<Failure, List<Map<String, dynamic>>> _ensureList(Map<String, dynamic> json) => json['data'] is List
      ? Right(json['data'])
      : Left(Failure(
          error: Exception("Expected a List under 'data', got ${json['data'].runtimeType}."),
          stackTrace: StackTrace.current,
          message: "Failed to extract list from JSON response"));

  Either<Failure, T> _safeParse(Map<String, dynamic> json) => Either.tryCatch(() => parse(json),
      (error, stackTrace) => Failure(error: error, stackTrace: stackTrace, message: "Parsing error"));

  Either<Failure, List<T>> _parseAll(List<Map<String, dynamic>> listOfMap) => listOfMap.traverseEither(_safeParse);

  Either<Failure, Map<String, String>> _parseHeaders(Map<String, dynamic> rawData) {
    try {
      if (headerParser == null) {
        return Right({});
      }
      return Right(headerParser!.call(rawData));
    } catch (error, stackTrace) {
      return Left(Failure(
        error: error,
        stackTrace: stackTrace,
        message: "Header parsing failed: ${error.toString()}",
      ));
    }
  }

  Either<Failure, _RestAPIResponseWrapper<T>> parseDioResponse(Response response) => _validateStatus(response)
      .flatMap((res) => parseResponse(res.data))
      .map((parsed) => _RestAPIResponseWrapper(data: parsed.data, headers: parsed.headers))
      .mapLeft((failure) => failure);

  Either<Failure, _RestAPIResponseWrapper<List<T>>> parseListDioResponse(Response response) => _validateStatus(response)
      .flatMap((res) => parseListResponse(res.data))
      .map((parsedList) => _RestAPIResponseWrapper(data: parsedList.data, headers: parsedList.headers))
      .mapLeft((failure) => failure);

  Either<Failure, Response> _validateStatus(Response response) =>
      response.statusCode != null && response.statusCode! >= 200 && response.statusCode! <= 299
          ? Right(response)
          : Left(Failure(
              error: Exception("HTTP Error: ${response.statusCode}"),
              stackTrace: StackTrace.current,
              message: "HTTP request failed with status ${response.statusCode}"));
}
