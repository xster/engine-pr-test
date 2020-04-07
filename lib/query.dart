import 'dart:io';

import 'package:graphql/client.dart';
import 'dart:convert';
import 'data.dart';
import 'key.dart';

const String prFilesQuery = r'''
query TestedPrs($pageCursor: String) {
  repository(name: "engine", owner: "flutter") {
    pullRequests(last: 100, states: MERGED, before: $pageCursor) {
      nodes {
        url
        mergedAt
        files(last: 100) {
          totalCount
          nodes {
            path
          }
        }
      }
      pageInfo {
        hasPreviousPage
        startCursor
      }
    }
  }
}

''';

var fileIsTest = RegExp(r'(_test\.\w+|Test\.java|unittests\.\w+)');
var fileIsIos = RegExp(r'shell\/platform\/darwin\/ios.*\.mm');
var fileIsAndroid = RegExp(r'shell\/platform\/android.*\.java');


void main() async {
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

  String currentCursor;
  var output = Histogram();

  while (true) {
    var result = await gitHubGraphQlClient.query(QueryOptions(
      documentNode: gql(prFilesQuery),
      variables: <String, dynamic> {
        'pageCursor': currentCursor,
      }
    ));

    // print('github value: ${result.data}');
    print('github error: ${result.exception}');

    analyzePrs(githubData: result.data, histogram: output);

    File('data/pr_data.json').writeAsStringSync(JsonEncoder().convert(output.toJson()));
    File('data/pr_data.csv').writeAsStringSync(createCvs(output));

    var pageInfo = result.data['repository']['pullRequests']['pageInfo'];
    if (!pageInfo['hasPreviousPage']) {
      break;
    } else {
      currentCursor = pageInfo['startCursor'];
    }
  }
}

String createCvs(Histogram histogram) {
  var output = StringBuffer();
  output.writeln(
    'date,totalPrs,codePrs,androidPrs,iosPrs,testedPrs,androidTestedPrs,'
    'iosTestedPrs,untestedPrs'
  );
  histogram.dates.forEach((date, prs) {
    output.writeln(
      '${date.year}-${date.month}-${date.day},${prs.totalPrs},${prs.enginePrs},'
      '${prs.androidPrs},${prs.iosPrs},${prs.totalPrsWithTest},'
      '${prs.androidPrsWithTest},${prs.iosPrsWithTest},${prs.untestedPrs.join("/")}'
    );
  });
  return output.toString();
}

void analyzePrs({
  dynamic githubData,
  Histogram histogram,
}) {
  List<dynamic> prs = githubData['repository']['pullRequests']['nodes'];

  // print(JsonEncoder.withIndent('  ').convert(prs));

  for (Map<String, dynamic> pr in prs) {
    var mergeDateTime = DateTime.parse(pr['mergedAt']);
    // Trim off the time. Get date only.
    var mergeDate = DateTime(mergeDateTime.year, mergeDateTime.month, mergeDateTime.day);
    var daysPrs = histogram[mergeDate];

    var isAndroid = false;
    var isIos = false;
    var isTested = false;
    var hasRealCode = false;

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
      if (file != 'DEPS' && !file.contains('licenses_golden')) {
        hasRealCode = true;
      }
    }

    daysPrs.totalPrs += 1;
    daysPrs.enginePrs += hasRealCode ? 1 : 0;
    daysPrs.totalPrsWithTest += isTested ? 1 : 0;
    daysPrs.androidPrs += isAndroid ? 1 : 0;
    daysPrs.androidPrsWithTest += isAndroid && isTested ? 1 : 0;
    daysPrs.iosPrs += isIos ? 1 : 0;
    daysPrs.iosPrsWithTest += isIos && isTested ? 1 : 0;

    if (hasRealCode && !isTested) {
      daysPrs.untestedPrs.add(pr['url']);
    }
  }

  print(histogram);
  print('===========================');
}

