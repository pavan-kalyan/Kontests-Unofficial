import 'dart:async';
import 'dart:convert';
import 'dart:ffi';

import 'package:flutter/material.dart';

class Site {
  final String name;
  final String uname;
  final String url;

  Site({this.name, this.uname, this.url});

  factory Site.fromJson(List<dynamic> json) {
    return Site(
      name: json[0],
      uname: json[1],
      url: json[2],
    );
  }
}

class Sites {
  final List<Site> sites;

  Sites({this.sites});

  factory Sites.fromJson(List<dynamic> json) {
    List<Site> sites = new List<Site>();

    sites = json.map((i) => Site.fromJson(i)).toList();

    return new Sites(sites: sites);
  }
}
