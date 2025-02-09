import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'team.dart';

class Match
{
  late String id;
  String? ballDelivery = "0";
  String battingTeam;
  String bowlingTeam;
  String? run = "0";
  bool? over = false;
  Map<String,Map<String,String?>>? scores = {
    'Over 1': {'Ball 1': null, 'Ball 2': null, 'Ball 3': null, 'Ball 4': null, 'Ball 5': null, 'Ball 6': null},
    'Over 2': {'Ball 1': null, 'Ball 2': null, 'Ball 3': null, 'Ball 4': null, 'Ball 5': null, 'Ball 6': null},
    'Over 3': {'Ball 1': null, 'Ball 2': null, 'Ball 3': null, 'Ball 4': null, 'Ball 5': null, 'Ball 6': null},
    'Over 4': {'Ball 1': null, 'Ball 2': null, 'Ball 3': null, 'Ball 4': null, 'Ball 5': null, 'Ball 6': null},
    'Over 5': {'Ball 1': null, 'Ball 2': null, 'Ball 3': null, 'Ball 4': null, 'Ball 5': null, 'Ball 6': null}
  };
  Match({required this.battingTeam, required this.bowlingTeam});
  Match.fromJson(Map<String, dynamic> json, this.id)
      :
        ballDelivery = json['ballDelivery'],
        battingTeam = json['battingTeam'],
        bowlingTeam = json['bowlingTeam'],
        run = json['run'],
        over = json['over'],
        scores = json['scores'] != null
            ? (json['scores'] as Map<String, dynamic>).map((key, value) =>
            MapEntry(key, (value as Map<String, dynamic>).map((k, v) => MapEntry(k, v as String?))))
            : null;

  Map<String, dynamic> toJson() =>
      {
        'ballDelivery': ballDelivery,
        'battingTeam': battingTeam,
        'bowlingTeam' : bowlingTeam,
        'run' : run,
        'over' : over,
        'scores' : scores,

      };
}

class MatchModel extends ChangeNotifier {
  /// Internal, private state of the list.
  final List<Match> items = [];
  final Map<String, Team> teams = {};
  CollectionReference matchCollection = FirebaseFirestore.instance.collection('matchInfo');
  CollectionReference teamCollection = FirebaseFirestore.instance.collection('teamInfo');
  bool loading = false;
  //Normally a model would get from a database here, we are just hardcoding some data for this week
  MatchModel()
  {
    fetch();
  }
  Future fetch() async
  {
    try {
      items.clear();
      teams.clear();
      loading = true;
      notifyListeners();
      // Fetch teams
      var teamSnapshot = await teamCollection.get();
      for (var doc in teamSnapshot.docs) {
        var team = Team.fromJson(doc.data() as Map<String, dynamic>, doc.id);
        teams[doc.id] = team;
      }
      // Fetch matches
      var querySnapshot = await matchCollection.get();
      for (var doc in querySnapshot.docs) {
        var match = Match.fromJson(doc.data() as Map<String, dynamic>, doc.id);
        items.add(match);
      }

      loading = false;
      notifyListeners();
    } catch (e) {
      print("Error fetching data: $e");
      loading = false;
      notifyListeners();
    }
  }
  Match? get(String? id)
  {
    if (id == null) return null;
    return items.firstWhere((match) => match.id == id);
  }
  void add(Match item) {
    items.add(item);
    update();
  }

  // This call tells the widgets that are listening to this model to rebuild.
  void update()
  {
    notifyListeners();
  }
  Future<void> createMatch(Match match) async {
    try {
      DocumentReference docRef = await matchCollection.add(match.toJson());
      match.id = docRef.id;
      items.add(match);
      notifyListeners();
    } catch (e) {
      print("Error creating match: $e");
    }
  }

  Future<void> updateMatch(Match match) async {
    try {
      await matchCollection.doc(match.id).update(match.toJson());
      int index = items.indexWhere((m) => m.id == match.id);
      if (index != -1) {
        items[index] = match;
        notifyListeners();
      }
    } catch (e) {
      print("Error updating match: $e");
    }
  }
  Future<void> deleteMatch(String matchId) async {
    try {
      await matchCollection.doc(matchId).delete();
      items.removeWhere((match) => match.id == matchId);
      notifyListeners();
    } catch (e) {
      print("Error deleting team: $e");
    }
  }
}
