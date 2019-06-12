import 'dart:convert' as convert;
import 'package:http/http.dart' as http;
import '../models/FatchedData.dart';
import '../models/Log.dart';
import '../models/Trap.dart';
import 'package:flutter_nfc_reader/flutter_nfc_reader.dart';

class DataMgr {
  static final DataMgr _singleton = new DataMgr._internal();
  String _userName = "이름";
  String _userID = "아이디";
  NfcData _nfcData;
  Function nfcCallback;
  bool isServerOn = true;
  String get userName {
    return '$_userName';
  }

  String get userID {
    return '$_userID';
  }
  /*
  Log 데이터를 웹으로부터 읽어드리는 함수 비동기
  */
  Future<FatchedData> fatchingData(final String nfcID) async {
    FatchedData data = FatchedData();
    data.logs = [];
    if (!isServerOn) {
      data.trap = Trap(address: nfcID, insDate: nfcID);
      return Future<FatchedData>(() => data);
    }
    var url = "http://3.18.250.71:8080/demo/logs/" + nfcID + "/";
    var response = await http.get(url);
    // 성공시 statusCode 200 or 201
    if (response.statusCode == 200 || response.statusCode == 201) {
      // 응답이 json임으로 파싱하여 Map<string,dynamic> 형식으로 전환
      var jsonResponse = convert.jsonDecode(response.body);
      // for문을 돌면서 모든 로그를 data에 저장
      for (var log_data in jsonResponse['logs']) {
        var log = Log(
          catchCount: log_data['catch_count'],
          phromoneStat: log_data['phromone_stat'],
          trapStat: log_data['trap_stat'],
          notes: log_data['notes'],
          userName: log_data['user_name'],
          instDate: log_data['insp_date'],
        );
        data.logs.add(log);
      }
      //받아온 트렙을 저장
      data.trap = Trap(
        address: jsonResponse['trap']['address'],
        insDate: jsonResponse['trap']['ins_date'],
      );
    }
    //받아온 데이터를 반환
    return Future<FatchedData>(() => data);
  }

  //로그인
  Future<String> login(String id, String pw) async {
    var url = "http://3.18.250.71:8080/demo/login/";
    var message = "Internet Error";
    if (!isServerOn) {
      _userID = "인터넷없음";
      _userName = "인터넷없음";
      return Future<String>(() => "success");
    }
    //post request 걸시 body에 전달한 Map이 같이 서버에 전달됨
    var response = await http.post(url, body: {
      'id': id,
      'pw': pw,
    });
    if (response.statusCode == 200 || response.statusCode == 201) {
      var jsonResponse = convert.jsonDecode(response.body);
      //로그인 성공시
      if (jsonResponse['result'] == 'success') {
        message = 'success';
        _userName = jsonResponse['name'];
        _userID = id;
      } 
      //실패시
      else {
        message = jsonResponse['messages'];
      }
    }
    //메세지 반환
    return Future<String>(() => message);
  }
  //서버에 로그를 저장
  Future<bool> submitLog(final Log log,final String nfcID) async {
    if (!isServerOn) {
      _userID = "인터넷없음";
      _userName = "인터넷없음";
      return Future<bool>(() => true);
    }
    var url = "http://3.18.250.71:8080/demo/logs/";
    bool ret = false;
    var response = await http.post(url, body: log.toMapData(nfcID, userID));
    if (response.statusCode == 200 || response.statusCode == 201) {
      var jsonResponse = convert.jsonDecode(response.body);
      if (jsonResponse['result'] == 'success') {
        ret = true;
      } 
    }
    return Future<bool>(() => ret);
  }

  //싱글톤용으로 만들기
  factory DataMgr() {
    return _singleton;
  }
  DataMgr._internal();

  //nfc 검색 시작, nfc 탐색시 nfcCallback 호출
  Future<void> startNFC() async {
    if (_nfcData != null) {
      return;
    }
    _nfcData = NfcData();
    FlutterNfcReader.read.listen((response) {
      _nfcData = response;
        if (_nfcData.content != null && nfcCallback!=null) {
          nfcCallback(getFirstNFCText(_nfcData.content));
          nfcCallback = null;
        }
    });
  }
  //nfc에 저장된 첫 스트링을 읽어옮
  String getFirstNFCText(String data) {
    // 0번째 바이트 nfc 타입
    int idx = 1;
    // 1번째 바이트 데이터 타입 길이(바이트)
    int typeLen = data.codeUnitAt(idx);
    idx++;
    // 2번째 바이트 페이로드(ID 길이 + ID + 데이터) 길이(바이트)
    int totalLen = data.codeUnitAt(idx);
    idx++;
    // 그다음 타입 길이만큼 바이트 타입
    String type = data.substring(idx,idx+typeLen);
    if (type != 'T') {
      return null;
    }
    idx+=typeLen;
    // 그다음 1 바이트 아이디 길이 (지금부터 페이로드)
    int idLen = data.codeUnitAt(idx);
    // 그다음 아이디 길이만큼 바이트 ID
    idx += idLen + 1;
    totalLen -= idLen + 1;
    // 나머지 전부 데이터
    return data.substring(idx,idx+totalLen);
    // 다른 저장됨 데이터가 있으면 데이터 타입부터 반복
  }
}
