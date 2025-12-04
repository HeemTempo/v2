import 'dart:async';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:http/http.dart' as http;

import 'package:openspace_mobile_app/config/app_config.dart';

class GraphQLService {
  late final GraphQLClient client;
  final bool debugMode;

  GraphQLService({
    String? endpoint,
    Duration timeout = const Duration(seconds: 30),
    this.debugMode = false,
  }) {
    final url = endpoint ?? AppConfig.graphqlUrl;
    final httpLink = HttpLink(
      url,
      httpClient: TimeoutHttpClient(timeout),
      defaultHeaders: {'Content-Type': 'application/json'},
    );

    client = GraphQLClient(
      cache: GraphQLCache(),
      link: httpLink,
      defaultPolicies: DefaultPolicies(
        query: Policies(fetch: FetchPolicy.networkOnly),
        mutate: Policies(fetch: FetchPolicy.networkOnly),
      ),
    );

    if (debugMode) {
      print('GraphQLService initialized → $endpoint (timeout: ${timeout.inSeconds}s)');
    }
  }

  Future<QueryResult> query(
    String queryString, {
    Map<String, dynamic>? variables,
  }) async {
    return _execute(
      () => client.query(QueryOptions(
        document: gql(queryString),
        variables: variables ?? {},
        fetchPolicy: FetchPolicy.networkOnly,
      )),
      label: 'QUERY',
    );
  }

  Future<QueryResult> mutate(
    String mutationString, {
    Map<String, dynamic>? variables,
  }) async {
    return _execute(
      () => client.mutate(MutationOptions(
        document: gql(mutationString),
        variables: variables ?? {},
        fetchPolicy: FetchPolicy.networkOnly,
      )),
      label: 'MUTATION',
    );
  }

  Future<QueryResult> _execute(
    Future<QueryResult> Function() action, {
    required String label,
  }) async {
    final start = DateTime.now();
    try {
      final result = await action();

      if (debugMode) {
        final duration = DateTime.now().difference(start);
        print('GraphQL $label completed in ${duration.inMilliseconds}ms');
      }

      if (result.hasException) throw result.exception!;
      return result;
    } catch (e) {
      if (debugMode) print('GraphQL $label ERROR: $e');
      rethrow;
    }
  }
}

class TimeoutHttpClient extends http.BaseClient {
  final http.Client _inner = http.Client();
  final Duration timeout;

  TimeoutHttpClient(this.timeout);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    return _inner.send(request).timeout(
      timeout,
      onTimeout: () => throw TimeoutException(
        'Request to ${request.url} timed out after $timeout',
      ),
    );
  }

  @override
  void close() => _inner.close();
}
