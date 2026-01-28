import 'package:dotto/feature/bus/domain/bus_stop.dart';
import 'package:dotto/feature/bus/domain/bus_trip.dart';
import 'package:dotto/helper/firebase_realtime_database_repository.dart';

final class BusRepository {
  factory BusRepository() {
    return _instance;
  }
  BusRepository._internal();
  static final BusRepository _instance = BusRepository._internal();

  String formatDuration(Duration d) {
    String twoDigits(int n) {
      if (n.isNaN) return '00';
      return n.toString().padLeft(2, '0').substring(0, 2);
    }

    // 符号の取得
    final negativeSign = d.isNegative ? '-' : '';

    // 各値の絶対値を取得
    final hour = d.inHours.abs();
    final min = d.inMinutes.remainder(60).abs();

    // 各値を2桁の文字列に変換
    final strHour = twoDigits(hour);
    final strMin = twoDigits(min);

    // フォーマット
    return '$negativeSign$strHour:$strMin';
  }

  Future<List<BusStop>> getAllBusStopsFromFirebase() async {
    final snapshot = await FirebaseRealtimeDatabaseRepository().getData(
      'bus/stops',
    ); //firebaseから情報取得
    if (snapshot.exists) {
      final busDataStops = snapshot.value! as List;
      return busDataStops
          .map((e) => BusStop.fromFirebase(Map<String, dynamic>.from(e as Map)))
          .toList();
    } else {
      throw Exception();
    }
  }

  Future<Map<String, Map<String, List<BusTrip>>>> getBusDataFromFirebase(
    List<BusStop> allBusStops,
  ) async {
    final snapshot = await FirebaseRealtimeDatabaseRepository().getData(
      'bus/trips',
    ); //firebaseから情報取得
    if (snapshot.exists) {
      final busTripsData = snapshot.value! as Map;
      final allBusTrips = <String, Map<String, List<BusTrip>>>{
        'from_fun': {'holiday': [], 'weekday': []},
        'to_fun': {'holiday': [], 'weekday': []},
      };
      busTripsData.forEach((key, value) {
        final fromTo = key as String;
        (value as Map).forEach((key2, value2) {
          final week = key2 as String;
          allBusTrips[fromTo]![week] = (value2 as List)
              .map(
                (e) => BusTrip.fromFirebase(
                  Map<String, dynamic>.from(e as Map),
                  allBusStops,
                ),
              )
              .toList();
        });
      });
      return allBusTrips;
    } else {
      throw Exception();
    }
  }
}
