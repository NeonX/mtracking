import 'package:flutter/material.dart';
import 'package:mtracking/models/amphur.dart';
import 'package:mtracking/models/project_model.dart';
import 'package:mtracking/models/province.dart';
import 'package:mtracking/screens/authen.dart';
import 'package:mtracking/utility/my_style.dart';
import 'package:mtracking/utility/normal_dialog.dart';
import 'package:mtracking/widgets/list_offline.dart';
import 'package:mtracking/widgets/list_pending.dart';
import 'package:mtracking/widgets/list_project.dart';
import 'package:mtracking/widgets/map_points.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:data_connection_checker/data_connection_checker.dart';

class MyService extends StatefulWidget {
  @override
  _MyServiceState createState() => _MyServiceState();
}

class _MyServiceState extends State<MyService> {
  // Field
  String user;
  Widget currentWidget = ListProject();
  Widget cusSearchBar = Text('Project List');
  Icon cusIcon = Icon(Icons.search);
  Province provSrch;
  Amphur ampSrch;
  String accesskey;
  Icon signalIco = Icon(
    Icons.wifi_tethering,
    color: Colors.greenAccent.shade400,
  );

  IconButton appAction ;

  // Method
  @override
  void initState() {
    super.initState();

    

    //iconSignal();
    checkRemember();

    DataConnectionChecker().onStatusChange.listen((status) {
      switch (status) {
        case DataConnectionStatus.connected:
          setState(() {
            signalIco = Icon(
              Icons.wifi_tethering,
              color: Colors.greenAccent.shade400,
            );
          });
          //print('Data connection is available.');
          break;
        case DataConnectionStatus.disconnected:
          setState(() {
            signalIco = Icon(Icons.portable_wifi_off, color: Colors.grey);
          });
          //print('You are disconnected from the internet.');
          break;
      }
    });

    appAction = IconButton(
              icon: signalIco,
              onPressed: () {},
            );
  }

  Widget showDrawer() {
    return Drawer(
      child: ListView(
        children: <Widget>[
          DrawerHeader(
            decoration: BoxDecoration(color: Colors.red.shade300),
            child: Container(
              padding: EdgeInsets.only(top: 10.0),
              child: Column(
                children: <Widget>[
                  Container(
                    width: 70.0,
                    height: 70.0,
                    child: Image.network(
                        'http://vm80.pte.co.th/mtrack/tmp_images/user.png'),
                  ),
                  SizedBox(
                    height: 10.0,
                  ),
                  Text(
                    'login by : $user',
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
          ListTile(
            leading: Icon(Icons.toc),
            title: Text('Project List'),
            onTap: () {
              setState(() {
                currentWidget = ListProject();
                cusSearchBar = Text('Project List');
              });
              //iconBar();
              Navigator.pop(context);
              //normalDialog(context, 'Drawer Menu', 'Click menu PROJECT LIST');
            },
          ),
          ListTile(
            leading: Icon(Icons.file_upload),
            title: Text('Pending Upload'),
            onTap: () {
              setState(() {
                currentWidget = ListPending();
                cusSearchBar = Text('Pending Upload');
              });
              //iconBar();
              Navigator.pop(context);
              //normalDialog(context, 'Drawer Menu', 'Click menu PROJECT LIST');
            },
          ),
          ListTile(
            leading: Icon(Icons.map),
            title: Text('View Map'),
            onTap: () {
              setState(() {
                currentWidget = MapPoints();
                cusSearchBar = Text('View Map');
              });
              //iconBar();
              Navigator.pop(context);
              //normalDialog(context, 'Drawer Menu', 'Click menu VIEW MAP');
            },
          ),
          ListTile(
            leading: Icon(Icons.cloud_off),
            title: Text('Offline mode'),
            onTap: () {
              setState(() {
                currentWidget = ListOffline();
                cusSearchBar = Text('Offline Mode');
              });
              //iconBar();
              Navigator.pop(context);
              //normalDialog(context, 'Drawer Menu', 'Click menu OFFLINE MODE');
            },
          ),
          ListTile(
            leading: Icon(Icons.exit_to_app),
            title: Text('Logout'),
            onTap: () {
              confirmLogout();
            },
          ),
        ],
      ),
    );
  }

  Future<void> checkRemember() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    bool offMode = prefs.containsKey("is_offline");
    prefs.remove("is_offline");

    if (offMode) {
      setState(() {
        currentWidget = ListOffline();
        cusSearchBar = Text('Offline Mode');
      });
    }

    if (prefs.containsKey('uname')) {
      setState(() {
        user = prefs.getString('uname');
      });
    }
  }

  Widget customSearchAppBar() {
    return IconButton(
      icon: cusIcon,
      onPressed: () {
        setState(() {
          if (this.cusIcon.icon == Icons.search) {
            this.cusIcon = Icon(Icons.cancel);
            this.cusSearchBar = TextField(
              textInputAction: TextInputAction.go,
              onSubmitted: (String srch) {
                normalDialog(context, 'Searching', 'key search is \'$srch\'');
              },
              decoration: InputDecoration(
                  border: InputBorder.none,
                  icon: Icon(
                    Icons.search,
                    color: Colors.grey.shade400,
                  ),
                  hintText: "Search here...",
                  hintStyle: TextStyle(
                    color: Colors.grey.shade400,
                  )),
              style: TextStyle(
                color: Colors.white,
              ),
            );
          } else {
            this.cusSearchBar = Text('Project List');
            this.cusIcon = Icon(Icons.search);
          }
        });
      },
    );
  }

  Future<void> confirmLogout() async {
    showDialog<String>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Confirmation'),
        content: Text(
          'Do you really want to logout?',
        ),
        actions: <Widget>[
          FlatButton(
            child: Text('No'),
            onPressed: () => Navigator.pop(context, 'No'),
          ),
          FlatButton(
            child: Text('Yes'),
            onPressed: () {
              logout();
            },
          ),
        ],
      ),
    );
  }

  Future<void> logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('uname');
    await prefs.remove('remember');

    MaterialPageRoute materialPageRoute =
        MaterialPageRoute(builder: (BuildContext context) => Authen());
    Navigator.of(context).pushAndRemoveUntil(materialPageRoute,
        (Route<dynamic> route) {
      return false;
    });
  }

/*
  Future<bool> checkConnection() async {
    return await DataConnectionChecker().hasConnection;
  }

  Future<void> iconSignal() async {
    checkConnection().then((con) {
      setState(() {
        if (con) {
          signalIco = Icon(
            Icons.wifi_tethering,
            color: Colors.greenAccent.shade400,
          );
        } else {
          signalIco = Icon(Icons.portable_wifi_off, color: Colors.grey);
        }
      });
    });
  }
*/

  Future<void> iconBar() async {
      setState(() {
        if (cusSearchBar.toString() == 'Text("Offline Mode")') {
          appAction = IconButton(
            icon: Icon(Icons.delete_forever, color: Colors.white),
            onPressed: () {
              deleteAllDialog();
            },
          );
        } else {
          appAction = IconButton(
              icon: signalIco,
              onPressed: () {},
            );
        }
      });
  }

  Future<void> deleteAllDialog() async {
    showDialog(
      context: context,
      barrierDismissible: false, // user must tap button for close dialog!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('ลบโครงการ'),
          content: Text('คุณต้องการลบรายชื่อโครงการทั้งหมด ใช่หรือไม่?'),
          actions: <Widget>[
            FlatButton(
              child: Text('ใช่'),
              onPressed: () {
                ProjectModel().deleteAll().then((int x){
                  Navigator.of(context).pop();
                });
              },
            ),
            FlatButton(
              child: Text('ไม่'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            )
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    
            
    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: cusSearchBar,
          backgroundColor: MyStyle().barColor,
          actions: <Widget>[
            appAction,
          ],
        ),
        drawer: showDrawer(),
        body: currentWidget,
      ),
    );
  }
}
