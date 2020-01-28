import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:http/http.dart' as http;
import 'package:kontests/ContestServices.dart';
import 'package:kontests/Contest.dart';
import 'package:kontests/SiteServices.dart';
import 'package:kontests/Site.dart';
import 'dart:async';
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kontests Unofficial',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

_launchURL(String url) async {
  String launchURL = url;
  if (await canLaunch(launchURL)) {
    await launch(launchURL);
  } else {
    throw 'Could not launch $launchURL';
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Future<Sites> sites;
  List<Widget> tabList;
  bool refreshing = false;

  @override
  void initState() {
    super.initState();
    sites = loadSites();
    tabList = getTabList(sites);
  }

  List<Widget> getTabList(Future<Sites> sites) {
    List<Widget> list = new List<Widget>();

    FutureBuilder<Sites>(
        future: sites,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            for (var i = 0; i < snapshot.data.sites.length; i++) {
              print(i);
              list.add(new Text(snapshot.data.sites[i].name));
            }
          } else if (snapshot.hasError) {}
          return Container();
        });
    //print(list);
    return list;
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: 11,
        child: Scaffold(
          drawer: Drawer(
            child: ListView(
              children: <Widget>[
                DrawerHeader(
                  child: Text("Kontests App"),
                ),
                ListTile(title: Text("About the App.")),
                ListTile(title: Text("Developer")),
                ListTile(
                  title: Text("Github/pavan-kalyan"),
                  onTap: () => launch("https://github.com/pavan-kalyan"),
                )
              ],
            ),
          ),
          appBar: AppBar(
              title: Text("Kontests Unofficial"),
              bottom: PreferredSize(
                  preferredSize: Size.fromHeight(50.0),
                  child: FutureBuilder<Sites>(
                    future: sites,
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        return TabBar(
                            isScrollable: true,
                            tabs: List<Widget>.generate(
                                snapshot.data.sites.length, (int index) {
                              return new Tab(
                                text: snapshot.data.sites[index].name,
                              );
                            }));
                      }
                      return TabBar(
                        isScrollable: true,
                        tabs: <Widget>[
                          Text('Codeforces'),
                          Text('Codeforces:gym'),
                          Text('TopCoder'),
                          Text('AtCoder'),
                          Text('CS Academy'),
                          Text('CodeChef'),
                          Text('HackerRank'),
                          Text('HackerEarth'),
                          Text('Kick Start'),
                          Text('LeetCode'),
                          Text('A2OJ'),
                        ],
                      );
                    },
                  ))),
          body: FutureBuilder<Sites>(
              future: sites,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return TabBarView(
                      children: List<Widget>.generate(
                          snapshot.data.sites.length, (int index) {
                    return ContestList(
                      site: snapshot.data.sites[index].uname,
                    );
                  }));
                }
                return TabBarView(
                  children: List<Widget>.generate(11, (int index) {
                    return Center(child: CircularProgressIndicator());
                  }),
                );
              }
              /*
                       TabBarView(
                        children: <Widget>[
                          ContestList(site: 'codeforces'),
                          ContestList(site: 'at_coder'),
                          ContestList(site: 'leet_code'),
                          ContestList(site: 'top_coder'),
                          ContestList(site: 'at_coder'),
                          ContestList(site: 'leet_code'),
                          ContestList(site: 'top_coder'),
                          ContestList(site: 'at_coder'),
                          ContestList(site: 'leet_code'),
                          ContestList(site: 'top_coder'),
                          ContestList(site: 'top_coder'),
                        ],
                
                      )
                      */
              ),
        ));
  }

  Future<Null> _handleRefresh() async {
    setState(() => refreshing = true);
    refreshing = false;
  }
}

class ContestList extends StatefulWidget {
  String site;

  ContestList({
    this.site,
  });
  @override
  createState() => _ContestListState();
}

class _ContestListState extends State<ContestList>
    with AutomaticKeepAliveClientMixin<ContestList> {
  Future<Contests> contests;
  bool refreshing = false;

  List<Contest> contestList = List<Contest>();

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    //print("in contestlist" + widget.refreshing.toString());
    contests = loadContests(widget.site, refreshing);
  }

  void _populateContestItems() {
    setState(() {
      contests = loadContests(widget.site, refreshing);
    });
  }

  @override
  dispose() {
    super.dispose();
  }

  @override
  build(context) {
    return RefreshIndicator(
        onRefresh: refresh,
        child: FutureBuilder<Contests>(
            future: contests,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return ListView.separated(
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: snapshot.data.contests.length,
                    separatorBuilder: (context, index) => Divider(
                          color: Colors.black,
                        ),
                    itemBuilder: (context, index) {
                      DateTime startDateTime =
                          snapshot.data.contests[index].start_time.toLocal();
                      TimeOfDay timepicked =
                          TimeOfDay.fromDateTime(startDateTime);
                      String hour = timepicked.hourOfPeriod.toString();
                      
                      String minute = timepicked.minute<10 ? '0'+timepicked.minute.toString():timepicked.minute.toString();
                      String meridiem = timepicked.period.index == 0 ? 'am': 'pm';
                      return ListTile(
                        title: Text(snapshot.data.contests[index].name),
                        onTap: () => launch(snapshot.data.contests[index].url),
                        subtitle: Text(startDateTime.day.toString() +
                            '/' +
                            startDateTime.month.toString() +
                            ' ' +
                            hour +
                            ':' +
                             minute +
                            ' ' +
                            meridiem),
                      );
                    });
              } else if (snapshot.hasError) {
                return Text("${snapshot.error}");
              }
              return Center(child: CircularProgressIndicator());
            }));
  }

  Future<Null> refresh() async {
    print("refresh invoked " + refreshing.toString());
    setState(() {
      refreshing = true;
      _populateContestItems();
    });
    print("refresh invoked after " + refreshing.toString());
    refreshing = false;
  }
}
