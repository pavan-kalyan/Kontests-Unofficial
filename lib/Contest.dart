import 'dart:async';
import 'dart:convert';
import 'dart:ffi';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';

class Contests {
  final List<Contest> contests;

  Contests({
    this.contests,
  });

  factory Contests.fromJson(List<dynamic> parsedJson) {
    List<Contest> contests = new List<Contest>();

    contests = parsedJson.map((i) => Contest.fromJson(i)).toList();
    return new Contests(
      contests: contests,
    );
  }
}

class Contest {
  final String name;
  final String url;
  final DateTime start_time;
  final DateTime end_time;
  final String duration;
  final String site;
  final bool in_24_hours;
  final String status;

  Contest(
      {this.name,
      this.url,
      this.start_time,
      this.end_time,
      this.duration,
      this.site,
      this.in_24_hours,
      this.status});
  factory Contest.fromJson(Map<String, dynamic> json) {
    bool within_24 = json['in_24_hours'] == 'Yes' ? true : false;
    return Contest(
      name: json['name'],
      url: json['url'],
      start_time: new DateFormat("yyyy-MM-ddTHH:mm:ss.SSSZ")
          .parseUtc(json['start_time']),
      end_time:
          new DateFormat("yyyy-MM-ddTHH:mm:ss.SSSZ").parseUtc(json['end_time']),
      duration: json['duration'],
      site: json['site'],
      in_24_hours: within_24,
      status: json['status'],
    );
  }

  String getName() {
    return name;
  }
}
