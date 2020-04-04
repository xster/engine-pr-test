import 'package:flutter/material.dart';
import 'package:graphql/client.dart';
import 'key.dart';

void main() {
  runApp(GitHubGraph());
}

const String prFilesQuery = '''
query {
  repository(name: "engine", owner: "flutter") {
    pullRequests(last: 10) {
      nodes {
        number
        files(last: 100) {
          totalCount
          nodes {
            path
          }
        }
      }
    }
  }
}
''';

class GitHubGraph extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _GitHubGraphState();
}

class _GitHubGraphState extends State<GitHubGraph> {
  GraphQLClient gitHubGraphQlClient;

  @override
  void initState() {
    super.initState();
    var httpLink = HttpLink(
      uri: 'https://api.github.com/graphql'
    );

    var authLink = AuthLink(
      getToken: () => 'Bearer $kGitHubAccessToken',
    );

    gitHubGraphQlClient = GraphQLClient(
      cache: InMemoryCache(),
      link: authLink.concat(httpLink),
    );

    gitHubGraphQlClient.query(QueryOptions(
      documentNode: gql(prFilesQuery),
    )).then(
      (value) {
        print('github value: ${value.data}');
        print('github error: ${value.exception}');
      }
    );
  }


  @override
  Widget build(BuildContext context) {
    return Container();
  }
}