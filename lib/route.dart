import 'dart:convert';

//import 'package:flutter/material.dart';
import "package:http/http.dart" as http;

String apiKEY='AIzaSyD0em7tm03lJXoj4TK47TcunmqfjDwHGcI';
String apiURL='https://maps.googleapis.com/maps/api/directions/json?';
/*
int sta2=0;
double a=127.009686;
double b=37.507941;
double c=126.977977;
double d=37.302263;
*/
Future<String> getDrivingDuration(String origin, String destination) async {
  String drivingDuration='';
  http.Response response = await http.get(Uri.parse(
      '${apiURL}origin=$origin&destination=$destination&mode=driving&departure_time=now&language=ko&key=$apiKEY'
  ),
  );
  if (response.statusCode < 200 || response.statusCode > 400) {
    drivingDuration='-1';
    return drivingDuration; // 오류시 -1 리턴
  } else {
    String responseData = utf8.decode(response.bodyBytes);
    var responseBody = jsonDecode(responseData);
    drivingDuration = responseBody["routes"][0]["legs"][0]["duration"]["value"].toString();
  }
  return drivingDuration;
}

Future<String> getTransitDuration(String origin, String destination) async {
  String transitDuration='';
  http.Response response = await http.get(Uri.parse(
      '${apiURL}origin=$origin&destination=$destination&mode=transit&departure_time=now&language=ko&key=$apiKEY'
  ),
  );
  if (response.statusCode < 200 || response.statusCode > 400) {
    transitDuration='-1';
    return transitDuration; // 오류시 -1 리턴
  } else {
    String responseData = utf8.decode(response.bodyBytes);
    var responseBody = jsonDecode(responseData);
    transitDuration = responseBody["routes"][0]["legs"][0]["duration"]["value"].toString();
  }
  return transitDuration;
}

Future<String> getTransitSteps(String origin, String destination) async {
  String transitSteps='';
  http.Response response = await http.get(Uri.parse(
      '${apiURL}origin=$origin&destination=$destination&mode=transit&departure_time=now&language=ko&key=$apiKEY'
  ),
  );
  if (response.statusCode < 200 || response.statusCode > 400) {
    transitSteps = 'Error'; // Error 반환
  } else {
    String responseData = utf8.decode(response.bodyBytes);
    var responseBody = jsonDecode(responseData);
    var list = (responseBody["routes"][0]["legs"][0]["steps"]);

    String startAddress=responseBody["routes"][0]["legs"][0]["start_address"].toString();
    String endAddress=responseBody["routes"][0]["legs"][0]["end_address"].toString();
    String totalDistance=responseBody["routes"][0]["legs"][0]["distance"]["text"].toString();
    String totalDuration=responseBody["routes"][0]["legs"][0]["duration"]["text"].toString();
    String info='$startAddress에서 $endAddress까지 $totalDistance $totalDuration\n';
    transitSteps+='$info \n\n';
    for (int i = 0; i < list.length; i++) {
      if (list[i]["travel_mode"] == "WALKING") {
        String steps=list[i]["html_instructions"].toString();
        String distance=list[i]["distance"]["text"].toString();
        String subDuration=list[i]["duration"]["text"].toString();
        transitSteps += '$steps $distance $subDuration \n';
      } else {
        String transit='${list[i]["transit_details"]["line"]["name"]} ${list[i]["transit_details"]["line"]["short_name"]}';
        String headSign=list[i]["html_instructions"].toString();
        String departureStop=list[i]["transit_details"]["departure_stop"]["name"].toString();
        String arrivalStop=list[i]["transit_details"]["arrival_stop"]["name"].toString();
        String stops=list[i]["transit_details"]["num_stops"].toString();
        String subDuration=list[i]["duration"]["text"].toString();
        transitSteps +='$transit $headSign $departureStop에서 $arrivalStop까지 $stops정거장 $subDuration\n';
      }
    }
  }
  return transitSteps;
}