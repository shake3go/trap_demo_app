import 'dart:async';

import 'package:flutter/material.dart';
import '../models/Trap.dart';
import '../models/Log.dart';
import '../models/FatchedData.dart';
import '../controller/DataMgr.dart';

//관리 기록들 보여주는 페이지, 트렙의 NFC ID 필요
class LogsPage extends StatefulWidget {
  final String nfcID;
  LogsPage(this.nfcID);

  @override
  State<StatefulWidget> createState() {
    return _LogsPageState();
  }
}

class _LogsPageState extends State<LogsPage> {
  //로딩중일때 뱅글이 띄워주기 위해 필요
  bool isLoading = true;
  //서버로부터 받아온 관리 기록들
  List<Log> logs;
  //ID 에 해당하는 트렙
  Trap trap;
  //앱 크기 조절용 변수
  double _appBarHeight;

  //입력 유효성 검사를 위해 필요
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  //입력된 값들에 접근하기위한 변수들
  String trapStVal = "좋음";
  String phrmStVal = "충분";
  final cntCtrl = TextEditingController();
  final notesCtrl = TextEditingController();

  //입력 양식 초기화
  void _clearForm() {
    trapStVal = "좋음";
    phrmStVal = "충분";
    cntCtrl.text = "";
    notesCtrl.text = "";
  }

  // 입력 양식 위젯
  Widget _buildForm() {
    final double deviceWidth = MediaQuery.of(context).size.width;
    final double targetWidth = deviceWidth > 550.0 ? 500.0 : deviceWidth * 0.95;
    return Container(
      width: targetWidth,
      child: Form(
        key: _formKey,
        child: Column(
          children: <Widget>[
            _buildtrapStTextField(),
            SizedBox(
              height: 10.0,
            ),
            _buildPhrmStTextField(),
            SizedBox(
              height: 10.0,
            ),
            _buildCntTextField(),
            SizedBox(
              height: 10.0,
            ),
            _buildNotesTextField(),
            SizedBox(
              height: 10.0,
            ),
            _buildSubmitBtn(),
          ],
        ),
      ),
    );
  }

  //신규 관리기록을 서버에 업로드하는 함수
  void _submit() async {
    StreamSubscription<bool> dataSub;

    Log log = Log(
      notes: notesCtrl.text,
      trapStat: trapStVal,
      catchCount: cntCtrl.text,
      phromoneStat: phrmStVal,
    );
    //로그인과 같은방법으로 5초후 강제종료
    dataSub =
        DataMgr().submitLog(log, widget.nfcID).asStream().listen((bool result) {
      if (result) {
        _clearForm();
        _renewData();
      } else {
        setState(() {
          isLoading = false;
          _showDialog("에러 발생");
        });
      }
    });
    await new Future.delayed(const Duration(seconds: 5));
    if (isLoading) {
      dataSub.cancel();
      setState(() {
        isLoading = false;
        _showDialog("에러 발생");
      });
    }
  }

  //버튼입력시 호출될 콜벡
  void _submitForm() {
    //입력 유효성 검사
    if (!_formKey.currentState.validate()) {
      return;
    }
    _formKey.currentState.save();
    setState(() {
      isLoading = true;
      _submit();
    });
  }

  //등록 버튼 위젯
  Widget _buildSubmitBtn() {
    return RaisedButton(
      child: Text('등록'),
      onPressed: () => _submitForm(),
    );
  }

  //입력 필드 위젯
  Widget _buildCntTextField() {
    return TextFormField(
      decoration: InputDecoration(
          labelText: '잡은 수', filled: true, fillColor: Colors.white),
      keyboardType: TextInputType.emailAddress,
      validator: (String value) {
        //정규표현식을 활용한 입력 유효성 검사
        if (value.isEmpty || !RegExp(r'^(?:[1-9]\d*|0)$').hasMatch(value)) {
          return '유효한 숫자를 입력해 주세요';
        }
      },
      controller: cntCtrl,
    );
  }

  //입력 필드 위젯
  Widget _buildPhrmStTextField() {
    return Row(
      children: <Widget>[
        Text("페로몬 상태 : "),
        SizedBox(width: 20.0),
        DropdownButton<String>(
          value: phrmStVal,
          onChanged: (String newValue) {
            setState(() {
              phrmStVal = newValue;
            });
          },
          items: <String>['충분', '부족']
              .map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
        ),
      ],
    );
  }

  //입력 필드 위젯
  Widget _buildtrapStTextField() {
    return Row(
      children: <Widget>[
        Text("트랩 상태 : "),
        SizedBox(width: 20.0),
        DropdownButton<String>(
          value: trapStVal,
          onChanged: (String newValue) {
            setState(() {
              trapStVal = newValue;
            });
          },
          items: <String>['좋음', '나쁨']
              .map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
        ),
      ],
    );
  }

  //입력 필드 위젯
  Widget _buildNotesTextField() {
    return TextFormField(
      decoration: InputDecoration(
          labelText: '비고', filled: true, fillColor: Colors.white),
      keyboardType: TextInputType.emailAddress,
      validator: (String value) {
        if (value.isEmpty) {
          return '비고를 입력하여 주세요';
        }
      },
      controller: notesCtrl,
    );
  }

  //데이터를 서버로부터 받아오는 함수
  void _renewData() {
    //뱅글이 띄우고
    setState(() {
      isLoading = true;
    });
    //DataMgr의 데이터 받아오는 함수 호출
    DataMgr().fatchingData(widget.nfcID).then<FatchedData>((FatchedData data) {
      logs = data.logs;
      trap = data.trap;
      setState(() {
        isLoading = false;
      });
    });
  }

  @override
  void initState() {
    _renewData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    AppBar appBar = AppBar(
      title: Text('관리 기록'),
    );
    _appBarHeight =
        appBar.preferredSize.height + MediaQuery.of(context).padding.top;
    return Scaffold(
      appBar: appBar,
      body: Center(
        child: _pageContent(),
      ),
    );
  }

  //내부 위젯
  Widget _pageContent() {
    if (isLoading) {
      return CircularProgressIndicator();
    } else {
      return SingleChildScrollView(
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height - _appBarHeight,
          child: Column(
            children: <Widget>[
              _getTrapCard(),
              _buildLogsList(),
              _buildForm(),
            ],
          ),
        ),
      );
    }
  }

  //관리 기록 리스트 위젯
  Widget _buildLogsList() {
    Widget logCards;
    if (logs.length > 0) {
      logCards = Flexible(
        child: ListView.builder(
          itemBuilder: (BuildContext context, int index) =>
              _logToCard(logs[index]),
          itemCount: logs.length,
        ),
      );
    } else {
      logCards = Container(
        child: Center(
          child: Text("로그가 없습니다."),
        ),
      );
    }
    return logCards;
  }

  //로그를 위젯으로 만들어주는 함수
  Widget _logToCard(Log log) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 10.0),
      child: Column(
        children: <Widget>[
          Text("관리자: " + log.userName),
          Text("관리일: " + log.instDate.split('+')[0].split('.')[0]),
          Text("잡은수: " + log.catchCount),
          Text("트랩 상태: " + log.trapStat),
          Text("패로몬 상태: " + log.phromoneStat),
          Text("비고: " + log.notes),
        ],
      ),
    );
  }

  //트렙을 위젯으로 만들어주는 함수
  Widget _getTrapCard() {
    return Card(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        child: Column(
          children: <Widget>[
            Text("트랩정보"),
            Text("트랩 위치: " + trap.address),
            Text("설치일: " + trap.insDate.split('+')[0].split('.')[0]),
          ],
        ),
      ),
    );
  }

  //팝업 띄우는 함수
  void _showDialog(String text) {
    // flutter defined function
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text(text),
        );
      },
    );
  }
}
