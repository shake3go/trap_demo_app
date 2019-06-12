import 'package:flutter/material.dart';
import 'pages/auth.dart';
import 'pages/logs.dart';
import 'pages/profile.dart';
import 'controller/DataMgr.dart';

void main() {
  // debugPaintSizeEnabled = true;
  // debugPaintBaselinesEnabled = true;
  // debugPaintPointersEnabled = true;
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    DataMgr().startNFC();
    //페이지를 
    return MaterialApp(
        // debugShowMaterialGrid: true,
        // home: AuthPage(),
        //routes를 지정함으로서, 페이지 전환시 객체말고 string을 인자로 전달하는것이 가능
        routes: {
          '/': (BuildContext context) => AuthPage(),
          '/profile': (BuildContext context) => ProfilePage(),
        },
        //지정된 string이 아닌 다른 스트링이 인자로 들어왔을때 호출
        onGenerateRoute: (RouteSettings settings) {
          final List<String> pathElements = settings.name.split('/');
          if (pathElements[0] != '') {
            return null;
          }
          //트랩 관리 페이지로 진입을 요청할시 진입
          if (pathElements[1] == 'logs') {
            final String nfcID = pathElements[2];
            return MaterialPageRoute<bool>(
              builder: (BuildContext context) => LogsPage(nfcID),
            );
          }
          return null;
        },
        //404 Error시
        onUnknownRoute: (RouteSettings settings) {
          return MaterialPageRoute(
              builder: (BuildContext context) => ProfilePage());
        },
      );
  }
}