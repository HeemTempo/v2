import 'dart:async';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:http/http.dart' as http;

class GraphQLService {
  late GraphQLClient client;

  GraphQLService({String endpoint ='http://127.0.0.1:8001/graphql/'}) {
    final httpLink = HttpLink(
      endpoint,
      httpClient: TimeoutHttpClient(const Duration(seconds: 60)),
      defaultHeaders: {
        'Content-Type': 'application/json',
      },
    );

    client = GraphQLClient(
      cache: GraphQLCache(),
      link: httpLink,
      defaultPolicies: DefaultPolicies(
        query: Policies(fetch: FetchPolicy.networkOnly),
        mutate: Policies(fetch: FetchPolicy.networkOnly),
      ),
    );
  }

  Future<QueryResult> query(String queryString, {Map<String, dynamic>? variables}) async {
    final startTime = DateTime.now();
    print('GraphQLService: Starting query at $startTime with query: $queryString, variables: $variables');

    try {
      final options = QueryOptions(
        document: gql(queryString),
        variables: variables ?? {},
        fetchPolicy: FetchPolicy.networkOnly,
      );

      final result = await client.query(options).timeout(
        const Duration(seconds: 60),
        onTimeout: () {
          print('GraphQLService: Query timed out after 60 seconds');
          throw TimeoutException('GraphQL query timed out after 60 seconds');
        },
      );

      final duration = DateTime.now().difference(startTime);
      print('GraphQLService: Query completed in ${duration.inMilliseconds}ms');

      if (result.hasException) {
        print('[GraphQL QUERY ERROR]: ${result.exception.toString()}');
        throw result.exception!;
      }

      return result;
    } catch (e) {
      print('[GraphQL QUERY ERROR]: $e');
      throw Exception('Query failed');
    }
  }

  Future<QueryResult> mutate(String mutationString, {Map<String, dynamic>? variables}) async {
    final startTime = DateTime.now();
    print('GraphQLService: Starting mutation at $startTime with mutation: $mutationString, variables: $variables');

    try {
      final options = MutationOptions(
        document: gql(mutationString),
        variables: variables ?? {},
        fetchPolicy: FetchPolicy.networkOnly,
      );

      final result = await client.mutate(options).timeout(
        const Duration(seconds: 60),
        onTimeout: () {
          print('GraphQLService: Mutation timed out after 60 seconds');
          throw TimeoutException('GraphQL mutation timed out after 60 seconds');
        },
      );

      final duration = DateTime.now().difference(startTime);
      print('GraphQLService: Mutation completed in ${duration.inMilliseconds}ms');

      if (result.hasException) {
        print('[GraphQL MUTATION ERROR]: ${result.exception.toString()}');
        throw result.exception!;
      }

      return result;
    } catch (e) {
      print('[GraphQL MUTATION ERROR]: $e');
      throw Exception('Mutation failed: $e');
    }
  }
}

class TimeoutHttpClient extends http.BaseClient {
  final http.Client _inner = http.Client();
  final Duration timeout;

  TimeoutHttpClient(this.timeout);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    print('TimeoutHttpClient: Sending request to ${request.url} with timeout: $timeout');
    try {
      final response = await _inner.send(request).timeout(
        timeout,
        onTimeout: () {
          print('TimeoutHttpClient: Request timed out after $timeout');
          throw TimeoutException('Request to GraphQL API timed out after $timeout');
        },
      );
      print('TimeoutHttpClient: Received response with status: ${response.statusCode}');
      return response;
    } catch (e) {
      print('TimeoutHttpClient: Error sending request: $e');
      rethrow;
    }
  }

  @override
  void close() {
    print('TimeoutHttpClient: Closing client');
    _inner.close();
  }
}