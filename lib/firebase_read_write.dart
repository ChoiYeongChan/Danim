import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

//import 'main.dart';

class User {
  String docCode = ""; // 로그인 API로 얻어 온 사용자별 코드
  String name = ""; // 사용자 이름
  List<String> travelList = []; // 여행다닌 city저장, placeNumList랑 1:1 대응
  List<int> placeNumList = []; // 각 여행에서 몇개의 관광지를 여행 다녔는지
  List<String> traveledPlaceList = []; //여행다녔던 관광지들 1차원 배열
  List<int> eventNumList = []; // 각 여행에서 몇개의 이벤트가 있는지
  List<dynamic> eventList = []; // 이벤트 1차원 배열
  List<String> diaryList = []; // 일기 - 텍스트만, travelList랑 1:1 대응

  User(
    this.docCode,
    this.name,
    this.travelList,
    this.placeNumList,
    this.traveledPlaceList,
    this.eventNumList,
    this.eventList,
    this.diaryList,
  );

  // User.fromJson(Map<String, dynamic> json)
  //     : cid = json['full_name'],
  //       title = json['company'],
  //       number = json['age'];

  Map<String, dynamic> toJson() => {
        'docCode': docCode,
        'name': name,
        'travelList': travelList,
        'placeNumList': placeNumList,
        'traveledPlaceList': traveledPlaceList,
        'eventNumList': eventNumList,
        'eventList': eventList,
        'diaryList': diaryList,
      };
}

class Place {
  String name = ""; //_는 private의 의미
  double latitude = 0.00; //위도
  double longitude = 0.00; //경도
  int takenTime = 0; //평균 소요시간
  int popular = 0; //인기관광지 척도 - 조회수기반
  List<int> partner = List.generate(7, (index) => 0);
  //0: 혼자 여행, 1: 커플여행 2:우정여행 3:가족여행 4:효도여행 5:어린자녀와 6:반려견과
  List<int> concept = List.generate(4, (index) => 0);
  //0: 힐링 1: 액티비티 2:배움이 있는 3:맛있는
  List<int> play = List.generate(6, (index) => 0);
  //0: 레저스포츠 1: 문화시설 2: 사진명소 3: 이색체험 4:문화체험 5: 역사
  List<int> tour = List.generate(9, (index) => 0);
  //0: 바다 1:산 2:드라이브코스 3:산책 4: 쇼핑 5:실내여행지 6:시티투어 7:지역축제 8:전통한옥
  List<int> season = List.generate(4, (index) => 0);
  //0: 봄 1:여름 2:가을 3:겨울

  // Place({
  //   required this.name,
  //   required this.latitude,
  //   required this.longitude,
  //   required this.popular,
  //   required this.partner,
  //   required this.concept,
  //   required this.play,
  //   required this.tour,
  //   required this.season,
  // });
  Place(
    this.name,
    this.latitude,
    this.longitude,
    this.takenTime,
    this.popular,
    this.partner,
    this.concept,
    this.play,
    this.tour,
    this.season,
  );

  Place.from(Place bestPath);

  Map<String, dynamic> toJson() => {
        'name': name,
        'latitude': latitude,
        'longitude': longitude,
        'takenTime': takenTime,
        'popular': popular,
        'partner': partner,
        'concept': concept,
        'play': play,
        'tour': tour,
        'season': season,
      };

//deep copy 하기 위한 함수
  Place.clone(Place placeA)
      : this(
            placeA.name,
            placeA.latitude,
            placeA.longitude,
            placeA.takenTime,
            placeA.popular,
            placeA.partner,
            placeA.concept,
            placeA.play,
            placeA.tour,
            placeA.season);
}

//Write하는 부분
void fb_write_user(docCode, name, travelList, placeNumList, traveledPlaceList,
    eventNumList, eventList, diaryList) {
  //문서를 안쓰고 컬렉션만 쓰는 방식.
  // User userModel =
  //     User(fullName: 'John Doe', company: "Stokes and Sons", age: 42);
  // users.add(userModel.toJson());

  //합쳐쓰기
  FirebaseFirestore.instance.collection('Users').doc(docCode).set({
    'name': name,
    'travelList': travelList,
    'placeNumList': placeNumList,
    'traveledPlaceList': traveledPlaceList,
    'eventNumList': eventNumList,
    'eventList': eventList,
    'diaryList': diaryList,
  }, SetOptions(merge: true));
}

void fb_write_place(city, name, latitude, longitude, takenTime, popular,
    partner, concept, play, tour, season) {
  //CollectionReference points = FirebaseFirestore.instance.collection('points');

  //덮어쓰기
  // FirebaseFirestore.instance.collection('points').doc(city).set({
  //   'name': name,
  //   'xCoordinate': xCoordinate,
  //   'yCoordinate': yCoordinate,
  // }, SetOptions(merge: false));

  //합쳐쓰기
  FirebaseFirestore.instance.collection(city).doc(name).set({
    'latitude': latitude,
    'longitude': longitude,
    'takenTime': takenTime,
    'popular': popular,
    'partner': partner,
    'concept': concept,
    'play': play,
    'tour': tour,
    'season': season,
  }, SetOptions(merge: true));
}

//Read하는 부분
class ReadController extends GetxController {
  final db = FirebaseFirestore.instance;
  //var data;
  Future<User> fb_read_user(docCode) async {
    var data = await db.collection('Users').doc(docCode).get();

    String name = data.data()!['name'] as String;

    //Error: Expected a value of type 'List<int>', but got one of type 'List<dynamic>'
    //위 에러 때문에 하나식 일일히 형변환함. 리스트를 통으로 형변환하면 에러

    List<dynamic> travelList2 = data.data()!['travelList'];
    List<String> travelList = [];
    for (int i = 0; i < travelList2.length; i++) {
      travelList.add(travelList2[i] as String);
    }

    List<dynamic> placeNumList2 = data.data()!['placeNumList'];
    List<int> placeNumList = [];
    for (int i = 0; i < placeNumList2.length; i++) {
      placeNumList.add(placeNumList2[i] as int);
    }

    List<dynamic> traveledPlaceList2 = data.data()!['traveledPlaceList'];
    List<String> traveledPlaceList = [];
    for (int i = 0; i < traveledPlaceList2.length; i++) {
      traveledPlaceList.add(traveledPlaceList2[i] as String);
    }

    List<dynamic> eventNumList2 = data.data()!['eventNumList'];
    List<int> eventNumList = [];
    for (int i = 0; i < eventNumList2.length; i++) {
      eventNumList.add(eventNumList2[i] as int);
    }

    List<dynamic> eventList2 = data.data()!['eventList'];
    List<dynamic> eventList = [];
    for (int i = 0; i < eventList2.length; i++) {
      eventList.add(eventList2[i]);
    }

    List<dynamic> diaryList2 = data.data()!['diaryList'];
    List<String> diaryList = [];
    for (int i = 0; i < diaryList2.length; i++) {
      diaryList.add(diaryList2[i] as String);
    }

    User userData = User(docCode, name, travelList, placeNumList,
        traveledPlaceList, eventNumList, eventList, diaryList);

    return userData;
  }

  Future<List<Place>> fb_read_all_place(city) async {
    List<Place> data = [];

    List<String> placeList = await fb_read_place_list(city) as List<String>;

    for (int i = 0; i < placeList.length; i++) {
      Place read_data = await fb_read_one_place(city, placeList[i]);
      data.add(read_data);
    }
    // for (int i = 0; i < data.length; i++) {
    //   print(data[i].name);
    //   print(data[i].latitude);
    // }

    return data;
  }

  Future<List> fb_read_place_list(city) async {
    var data = await db.collection(city).doc("관광지목록").get();

    List<String> placeList = [];
    for (int i = 0; i < data.data()!['관광지'].length; i++) {
      placeList.add(data.data()!['관광지'][i]);
    }
    return placeList;
  }

  Future<Place> fb_read_one_place(city, name) async {
    var data = await db.collection(city).doc(name).get();

    double latitude = data.data()!['latitude'] as double;
    double longitude = data.data()!['longitude'] as double;
    int popular = data.data()!['popular'] as int;
    int takenTime = data.data()!['takenTime'] as int;

    //Error: Expected a value of type 'List<int>', but got one of type 'List<dynamic>'
    //위 에러 때문에 하나식 일일히 형변환함. 리스트를 통으로 형변환하면 에러
    List<dynamic> partner2 = data.data()!['partner'];
    List<int> partner = [];
    for (int i = 0; i < partner2.length; i++) {
      partner.add(partner2[i] as int);
    }
    List<dynamic> concept2 = data.data()!['concept'];
    List<int> concept = [];
    for (int i = 0; i < concept2.length; i++) {
      concept.add(concept2[i] as int);
    }
    List<dynamic> play2 = data.data()!['play'];
    List<int> play = [];
    for (int i = 0; i < play2.length; i++) {
      play.add(play2[i] as int);
    }
    List<dynamic> tour2 = data.data()!['tour'];
    List<int> tour = [];
    for (int i = 0; i < tour2.length; i++) {
      tour.add(tour2[i] as int);
    }
    List<dynamic> season2 = data.data()!['season'];
    List<int> season = [];
    for (int i = 0; i < season2.length; i++) {
      season.add(season2[i] as int);
    }

    Place placedata = Place(name, latitude, longitude, takenTime, popular,
        partner, concept, play, tour, season);

    return placedata;
  }
}
