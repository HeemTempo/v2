import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:openspace_mobile_app/model/openspace.dart';

import '../api/graphql/graphql_service.dart';
import '../api/graphql/openspace_query.dart';
import '../model/Report.dart';

class OpenSpaceService {
  final GraphQLService _graphQLService = GraphQLService();

  Future<List<OpenSpaceMarker>> getAllOpenSpaces() async {
  final result = await _graphQLService.query(getAllOpenSpacesQuery);

  if (result.hasException) {
    throw Exception(result.exception.toString());
  }

  final spaces = result.data?['allOpenSpacesUser'] as List<dynamic>? ?? [];
  return spaces
      .map((e) => OpenSpaceMarker.fromJson(e as Map<String, dynamic>))
      .toList();
}






  Future<List<Report>> getAllReports() async {
    const String getAllReportsQuery = """
      query MyQuery {
        allReports {
          id
          description
          createdAt
          latitude
          longitude
          reportId
          spaceName
          file
        
        }
      }
    """;
    final Duration queryTimeout = const Duration(seconds: 30);

    try {
      final result = await _graphQLService
          .query(getAllReportsQuery)
          .timeout(queryTimeout);

      if (result.hasException) {
        final exception = result.exception!;
        if (exception.linkException != null) {
          final linkExString = exception.linkException.toString().toLowerCase();
          if (linkExString.contains('timeout') ||
              linkExString.contains('timed out')) {
            throw Exception("Fetching reports timed out. Please try again.");
          } else if (linkExString.contains('socketexception') ||
              linkExString.contains('httpexception') ||
              linkExString.contains('failed host lookup')) {
            throw Exception(
              "Network issue fetching reports. Check your connection.",
            );
          }
          throw Exception("A network error occurred while fetching reports.");
        }
        if (exception.graphqlErrors.isNotEmpty) {
          throw Exception(
            "Error from server: ${exception.graphqlErrors.first.message}",
          );
        }
        throw Exception(
          "Failed to fetch reports due to an unexpected server error.",
        );
      }

      if (result.data == null || result.data!['allReports'] == null) {
        return [];
      }

      final List<dynamic> reportsData =
          result.data!['allReports'] as List<dynamic>;
      return reportsData
          .map((data) => Report.fromJson(data as Map<String, dynamic>))
          .toList();
    } on TimeoutException catch (_) {
      throw Exception("Fetching reports timed out. Please try again.");
    } catch (e) {
      String errorMessage = e.toString().replaceFirst(
        RegExp(r'^Exception:\s*'),
        '',
      );
      if (errorMessage.contains("timed out") ||
          errorMessage.contains("Network issue") ||
          errorMessage.contains("Error from server")) {
        throw Exception(errorMessage);
      }
      throw Exception(
        "An error occurred while fetching reports: $errorMessage",
      );
    }
  }

  Future<Report?> getReportById(String reportId) async {
    const String getReportByIdQuery = """
      query GetReportById(\$reportId: String!) {
        reportById(reportId: \$reportId) {
          id
          description
          createdAt
          latitude
          longitude
          reportId
          spaceName
          file
          type
        
        }
      }
    """;
    final Duration queryTimeout = const Duration(seconds: 30);

    try {
      final result = await _graphQLService
          .query(getReportByIdQuery, variables: {'reportId': reportId})
          .timeout(queryTimeout);

      if (result.hasException) {
        final exception = result.exception!;
        if (exception.linkException != null) {
          final linkExString = exception.linkException.toString().toLowerCase();
          if (linkExString.contains('timeout') ||
              linkExString.contains('timed out')) {
            throw Exception("Fetching report timed out. Please try again.");
          } else if (linkExString.contains('socketexception') ||
              linkExString.contains('httpexception') ||
              linkExString.contains('failed host lookup')) {
            throw Exception(
              "Network issue fetching report. Check your connection.",
            );
          }
          throw Exception("A network error occurred while fetching report.");
        }
        if (exception.graphqlErrors.isNotEmpty) {
          throw Exception(
            "Error from server",
          );
        }
        throw Exception(
          "Failed to fetch report due to an unexpected server error.",
        );
      }

      if (result.data == null || result.data!['reportById'] == null) {
        return null;
      }

      return Report.fromJson(
        result.data!['reportById'] as Map<String, dynamic>,
      );
    } on TimeoutException catch (_) {
      throw Exception("Fetching report timed out. Please try again.");
    } catch (e) {
      String errorMessage = e.toString().replaceFirst(
        RegExp(r'^Exception:\s*'),
        '',
      );
      throw Exception(errorMessage);
    }
  }
}
