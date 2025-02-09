import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Team {
  late String id;
  String? teamName = '';
  String? teamPhoto =
      "https://firebasestorage.googleapis.com/v0/b/assignment2-f42a1.appspot.com/o/team%2Fdefault.jpg?alt=media&token=0d3886e8-03db-451c-ae37-a6e82aeb6511";
  String teamPosition;
  List<String?> teamPlayers = [null, null, null, null, null];

  Team({ required this.teamPosition});
  Team.fromJson(Map<String, dynamic> json, this.id)
      : teamName = json['teamName'],
        teamPhoto = json['teamPhoto'],
        teamPosition = json['teamPosition'],
        teamPlayers = (json['teamPlayers'] as List?)
            ?.map((item) => item as String?)
            .toList() ??
            [null, null, null, null, null];

  Map<String, dynamic> toJson() => {
    'teamName': teamName,
    'teamPhoto': teamPhoto,
    'teamPosition': teamPosition,
    'teamPlayers': teamPlayers,
  };
}

class TeamModel extends ChangeNotifier {
  final List<Team> items = [];
  CollectionReference teamCollection =
  FirebaseFirestore.instance.collection('teamInfo');
  bool loading = false;

  TeamModel() {
    fetch();
  }

  Future fetch() async {
    try {
      items.clear();
      loading = true;
      notifyListeners();

      var querySnapshot = await teamCollection.get();

      for (var doc in querySnapshot.docs) {
        var match = Team.fromJson(doc.data() as Map<String, dynamic>, doc.id);
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

  Team? get(String? id) {
    if (id == null) return null;
    return items.firstWhere((team) => team.id == id);
  }

  Future<void> updateTeamPlayers(String teamId, String newPlayerId) async {
    try {
      var team = get(teamId);
      if (team != null) {
        // Debug: print current state
        print('Before Update: ${team.teamPlayers}');

        // Add the new player ID and remove a null if present
        team.teamPlayers.add(newPlayerId);
        team.teamPlayers.remove(null);

        // Debug: print updated state
        print('After Update: ${team.teamPlayers}');

        await teamCollection.doc(teamId).update({'teamPlayers': team.teamPlayers});
        notifyListeners();
      }
    } catch (e) {
      print("Error updating team players: $e");
    }
  }

  void add(Team item) {
    items.add(item);
    update();
  }

  void update() {
    notifyListeners();
  }
  Future<void> createTeam(Team team) async {
    try {
      DocumentReference docRef = await teamCollection.add(team.toJson());
      team.id = docRef.id;
      items.add(team);

    } catch (e) {
      print("Error creating team: $e");
    }
  }

  Future<void> updateTeam(Team team) async {
    try {
      await teamCollection.doc(team.id).update(team.toJson());
      int index = items.indexWhere((t) => t.id == team.id);
      if (index != -1) {
        items[index] = team;
        notifyListeners();
      }
    } catch (e) {
      print("Error updating team: $e");
    }
  }
  Future<void> deleteTeam(String teamId) async {
    try {
      await teamCollection.doc(teamId).delete();
      items.removeWhere((team) => team.id == teamId);
      notifyListeners();
    } catch (e) {
      print("Error deleting team: $e");
    }
  }
}
