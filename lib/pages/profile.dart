import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import '../controller/DataMgr.dart';

//프로필 페이지
class ProfilePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _ProfilePageState();
  }
}

class _ProfilePageState extends State<ProfilePage> {
  //NFC를 추가해야함
  void nfcValidation() {
    DataMgr().nfcCallback = (String nfcID) {
      Navigator.pop(context);
      Navigator.pushNamed(context, "/logs/" + nfcID);
    };
  }

  //NFC로 알아오기 버튼을 눌렀을때 콜벡
  void _onBtnPress() {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return Container(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    "휴대폰을 트랩에 갖다 대주세요",
                    style: TextStyle(fontSize: 20.0),
                  ),
                  Text("정보 읽는중"),
                ],
              ),
            ),
          );
        }).then((_) {
      DataMgr().nfcCallback = null;
    });
    nfcValidation();
  }

  @override
  Widget build(BuildContext context) {
    final _width = MediaQuery.of(context).size.width;
    final _height = MediaQuery.of(context).size.height;

    return new Stack(
      children: <Widget>[
        new Container(
          color: Colors.blue,
        ),
        new Image.asset(
          'assets/face.jpg',
          fit: BoxFit.fill,
        ),
        new BackdropFilter(
            filter: new ui.ImageFilter.blur(
              sigmaX: 6.0,
              sigmaY: 6.0,
            ),
            child: new Container(
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.9),
              ),
            )),
        new Scaffold(
            appBar: new AppBar(
              title: new Text("프로필"),
              centerTitle: false,
              elevation: 0.0,
              backgroundColor: Colors.transparent,
            ),
            backgroundColor: Colors.transparent,
            body: new Center(
              child: new Column(
                children: <Widget>[
                  new SizedBox(
                    height: _height / 12,
                  ),
                  new CircleAvatar(
                    radius: _width < _height ? _width / 4 : _height / 4,
                    backgroundImage: AssetImage('assets/face.jpg'),
                  ),
                  new SizedBox(
                    height: _height / 25.0,
                  ),
                  new Text(
                    DataMgr().userName,
                    style: new TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: _width / 15,
                        color: Colors.white),
                  ),
                  new Divider(
                    height: _height / 30,
                    color: Colors.white,
                  ),
                  new Row(
                    children: <Widget>[
                      rowCell('지역', '울산'),
                      rowCell('직급', '대리'),
                      rowCell('회사', '팹스원'),
                    ],
                  ),
                  new Divider(height: _height / 30, color: Colors.white),
                  new Padding(
                    padding: new EdgeInsets.only(
                        left: _width / 8, right: _width / 8),
                    child: new FlatButton(
                      onPressed: _onBtnPress,
                      child: new Container(
                          child: new Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          new Icon(Icons.edit_location),
                          new SizedBox(
                            width: _width / 30,
                          ),
                          new Text('트렙 관리')
                        ],
                      )),
                      color: Colors.blue[50],
                    ),
                  ),
                ],
              ),
            ))
      ],
    );
  }

  Widget rowCell(String data, String type) => new Expanded(
          child: new Column(
        children: <Widget>[
          new Text(
            data,
            style: new TextStyle(color: Colors.white),
          ),
          new Text(type,
              style: new TextStyle(
                  color: Colors.white, fontWeight: FontWeight.normal))
        ],
      ));
}
