import 'dart:async' show Future;
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import 'package:kontests/Site.dart';
import 'package:http/http.dart' as http;

Future<Sites> loadSites() async {
  final response = await http.get('https://kontests.net/api/v1/sites');
  //print(response.body);
  if (response.statusCode == 200) {
    return Sites.fromJson(json.decode(response.body));
  } else {
    throw Exception('Failed to load List of Sites');
  }
}

Future<int> getNumberofSites() async {
  final response = await http.get('http://kontests.net/api/v1/sites');

  if (response.statusCode == 200) {
    return Sites.fromJson(json.decode(response.body)).sites.length;
  } else {
    throw Exception('Failed to get sites');
  }
}
