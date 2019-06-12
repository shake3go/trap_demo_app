import 'dart:async';

import 'package:flutter/material.dart';
import '../controller/DataMgr.dart';
//로그인 페이지
class AuthPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _AuthPageState();
  }
}

class _AuthPageState extends State<AuthPage> {
  //ID 를 가지고 있기위해 필요
  final idController = TextEditingController();
  //PW 를 가지고 있기위해 필요
  final pwController = TextEditingController();
  //입력 문자 유효성 검사를 위해 필요
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  //로딩할때 빙글이 보여주기 위해 필요
  bool isLoading = false;

  //배경에 blur처리된 이미지를 띄우는 위젯
  DecorationImage _buildBackgroundImage() {
    return DecorationImage(
      fit: BoxFit.cover,
      colorFilter:
          ColorFilter.mode(Colors.black.withOpacity(0.5), BlendMode.dstATop),
      image: AssetImage('assets/background.jpg'),
    );
  }
  //ID 입력 위젯
  Widget _buildIDTextField() {
    return TextFormField(
      decoration: InputDecoration(
          labelText: '아이디', filled: true, fillColor: Colors.white),
      keyboardType: TextInputType.emailAddress,
      //유효성 검사기
      validator: (String value) {
        if (value.isEmpty) {
          return '아이디를 입력하여 주세요';
        }
      },
      controller: idController,
    );
  }
  //페스워드 입력 위젲
  Widget _buildPasswordTextField() {
    return TextFormField(
      decoration: InputDecoration(
          labelText: '비밀번호', filled: true, fillColor: Colors.white),
      obscureText: true,
      //유효성 검사기
      validator: (String value) {
        if (value.isEmpty) {
          return '패스워드를 입력하여 주세요';
        }
      },
      controller: pwController,
    );
  }
  //로그인 버튼 위젯
  Widget _buildLoginBtn() {
    //로딩중일때(로그인중) 뱅글이 그려주기
    if (isLoading) {
      return CircularProgressIndicator();
    }
    return RaisedButton(
      child: Text('로그인'),
      onPressed: () => _submitForm(),
    );
  }
  //알림창 띄우기
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
  //로그인 함수
  void _login() async {
    StreamSubscription<String> dataSub;
    //5초후 강제종료를 위해서 스트림으로 DataMgr의 로그인 호출
    dataSub = DataMgr()
        .login(idController.text, pwController.text)
        .asStream()
        .listen((String message) {
      isLoading = false;
      //성공시 프로필 페이지로
      if (message == "success") {
        Navigator.pushReplacementNamed(context, '/profile');
      } else {
        //실페시 메세지 띄우기
        //setState호출 이유는 버튼 뱅글이에서 다시 버튼으로 바꾸기 위함
        setState(() {
          _showDialog(message);
        });
      }
    });
    //5초동안 로그인이 안되면 강제종료
    await new Future.delayed(const Duration(seconds: 5));
    if (isLoading) {
      dataSub.cancel();
      setState(() {
        _showDialog("서버 응답시간 초과");
        isLoading = false;
      });
    }
  }
  //로그인 버튼 눌렀을시 콜벡
  void _submitForm() {
    //유효성 검사
    if (!_formKey.currentState.validate()) {
      return;
    }
    _formKey.currentState.save();
    //뱅글이 띄워주고 로그인
    setState(() {
      isLoading = true;
    });
    _login();
  }
  //위젯 빌드
  @override
  Widget build(BuildContext context) {
    final double deviceWidth = MediaQuery.of(context).size.width;
    final double targetWidth = deviceWidth > 550.0 ? 500.0 : deviceWidth * 0.95;
    return Scaffold(
      appBar: AppBar(
        title: Text("로그인"),
      ),
      body: Container(
        decoration: BoxDecoration(
          image: _buildBackgroundImage(),
        ),
        padding: EdgeInsets.all(10.0),
        child: Center(
          child: SingleChildScrollView(
            child: Container(
              width: targetWidth,
              child: Form(
                key: _formKey,
                child: Column(
                  children: <Widget>[
                    _buildIDTextField(),
                    SizedBox(
                      height: 10.0,
                    ),
                    _buildPasswordTextField(),
                    SizedBox(
                      height: 10.0,
                    ),
                    _buildLoginBtn(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
