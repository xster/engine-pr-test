import 'package:graphql/client.dart';
import 'dart:convert';
import 'key.dart';

const String prFilesQuery = '''
query {
  repository(name: "engine", owner: "flutter") {
    pullRequests(last: 100, states: MERGED) {
      nodes {
        files(last: 100) {
          totalCount
          nodes {
            path
          }
        }
        mergedAt
        url
      }
    }
  }
}
''';

var fileIsTest = RegExp(r'_test\.');
var fileIsIos = RegExp(r'shell\/platform\/darwin\/ios.*\.mm');
var fileIsAndroid = RegExp(r'shell\/platform\/android.*\.java');

class PrsThatDay {
  int totalPrs = 0;
  int iosPrs = 0;
  int androidPrs = 0;
  int totalPrsWithTest = 0;
  int iosPrsWithTest = 0;
  int androidPrsWithTest = 0;

  @override
  String toString() {
    return '$totalPrsWithTest/$totalPrs tested. $androidPrsWithTest/$androidPrs android. $iosPrsWithTest/$iosPrs ios.';
  }
}

void main() {
  var httpLink = HttpLink(
    uri: 'https://api.github.com/graphql'
  );

  var authLink = AuthLink(
    getToken: () => 'Bearer $kGitHubAccessToken',
  );

  var gitHubGraphQlClient = GraphQLClient(
    cache: InMemoryCache(),
    link: authLink.concat(httpLink),
  );

  gitHubGraphQlClient.query(QueryOptions(
    documentNode: gql(prFilesQuery),
  )).then(
    (value) {
      print('github value: ${value.data}');
      print('github error: ${value.exception}');

      analyzePrs(value.data);
    }
  );
}

void analyzePrs(dynamic data) {
  List<dynamic> prs = data['repository']['pullRequests']['nodes'];
  var output = <DateTime, PrsThatDay>{};
  print(JsonEncoder.withIndent('  ').convert(prs));

  for (Map<String, dynamic> pr in prs) {
    var mergeDateTime = DateTime.parse(pr['mergedAt']);
    // Trim off the time. Get date only.
    var mergeDate = DateTime(mergeDateTime.year, mergeDateTime.month, mergeDateTime.day);
    output.putIfAbsent(mergeDate, () => PrsThatDay());
    var daysPrs = output[mergeDate];
    daysPrs.totalPrs += 1;

    var isAndroid = false;
    var isIos = false;
    var isTested = false;

    for (String file in pr['files']['nodes'].map((node) => node['path'])) {
      if (fileIsAndroid.hasMatch(file)) {
        isAndroid = true;
      }
      if (fileIsIos.hasMatch(file)) {
        isIos = true;
      }
      if (fileIsTest.hasMatch(file)) {
        isTested = true;
      }
    }

    daysPrs.totalPrsWithTest += isTested ? 1 : 0;
    daysPrs.androidPrs += isAndroid ? 1 : 0;
    daysPrs.androidPrsWithTest += isAndroid && isTested ? 1 : 0;
    daysPrs.iosPrs += isIos ? 1 : 0;
    daysPrs.iosPrsWithTest += isIos && isTested ? 1 : 0;
  }

  print(output);
}