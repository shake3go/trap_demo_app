import 'package:meta/meta.dart';

class Log {
  Log({
    @required this.catchCount,
    @required this.phromoneStat,
    @required this.trapStat,
    @required this.notes,
    this.instDate = "",
    this.userName = "",
  });
  final String userName;
  final String instDate;
  final String catchCount;
  final String phromoneStat;
  final String trapStat;
  final String notes;

  Map<String,dynamic> toMapData(String nfcID, String userID) {
      Map<String,dynamic> map = Map<String,dynamic>();
      map['nfc_id'] = nfcID;
      map['user_id'] = userID;
      map['catch_count'] = catchCount;
      map['phromone_stat'] = phromoneStat;
      map['trap_stat'] = trapStat;
      map['notes'] = notes;
      return map;
  }
  //디버그용 toString함수
  @override
  String toString() {
    return "<관리자: " + userName + ' 관리일: ' + instDate + ">";
  }
}
