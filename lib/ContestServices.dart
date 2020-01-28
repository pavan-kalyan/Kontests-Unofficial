import 'dart:async' show Future;
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_cache_store/flutter_cache_store.dart';
import 'dart:convert';
import 'package:kontests/Contest.dart';
import 'package:http/http.dart' as http;
import 'package:async_resource/async_resource.dart';
import 'package:async_resource/file_resource.dart';
import 'package:path_provider/path_provider.dart';

Future<Contest> loadContest() async {
  final response = await http.get('https://kontests.net/api/v1/codeforces');
  if (response.statusCode == 200) {
    return Contest.fromJson(json.decode(response.body));
  } else {
    throw Exception('Failed to load information');
  }
}

Future<Contests> loadContests(String site, bool refreshing) async {
  final path = (await getApplicationDocumentsDirectory()).path;
  final contests = HttpNetworkResource(
    url: 'https://kontests.net/api/v1/' + site,
    parser: (contents) => json.decode(contents),
    cache: FileResource(File('$path/$site')),
    maxAge: Duration(days: 2),
    strategy: CacheStrategy.cacheFirst,
  );
  final myData = await contests.get(forceReload: refreshing);

  return Contests.fromJson(myData);
}