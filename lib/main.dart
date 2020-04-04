import 'package:flutter/material.dart';
import 'package:graphql/client.dart';

void main() {
  runApp(GitHubGraph());
}

class GitHubGraph extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _GitHubGraphState();
}

class _GitHubGraphState extends State<GitHubGraph> {
  GraphQLClient gitHubGraphQlClient;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}