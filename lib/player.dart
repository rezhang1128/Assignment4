import 'package:assignment4/team.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Player {
  String? id;
  String? playerName;
  String? playerPhoto =
      "https://firebasestorage.googleapis.com/v0/b/assignment2-f42a1.appspot.com/o/team%2Fdefault.jpg?alt=media&token=0d3886e8-03db-451c-ae37-a6e82aeb6511";
  String? status = "rest";
  String? totalBallFaced = "0";
  String? totalRun = "0";

  Player({this.id, this.playerName, this.playerPhoto,this.totalRun,this.totalBallFaced});
  Player.fromJson(Map<String, dynamic> json, String id)
      : id = id,
        playerName = json['playerName'],
        playerPhoto = json['playerPhoto'],
        status = json['status'],
        totalBallFaced = json['totalBallFaced'],
        totalRun = json['totalRun'];

  Map<String, dynamic> toJson() => {
    'playerName': playerName,
    'playerPhoto': playerPhoto,
    'status': status,
    'totalBallFaced': totalBallFaced,
    'totalRun': totalRun,
  };
}

class PlayerModel extends ChangeNotifier {
  final List<Player?> items = [];
  CollectionReference playerCollection = FirebaseFirestore.instance.collection('playerInfo');
  bool loading = false;

  PlayerModel();

  Future<void> fetch(List<String?> playerIds) async {
    try {
      items.clear();
      loading = true;
      notifyListeners();
      List<String> validPlayerIds = playerIds.whereType<String>().toList();
      if (validPlayerIds.isNotEmpty) {
        var querySnapshot = await playerCollection.where(FieldPath.documentId, whereIn: validPlayerIds).get();
        for (var doc in querySnapshot.docs) {
          var player = Player.fromJson(doc.data() as Map<String, dynamic>, doc.id);
          items.add(player);
        }
      }
      while (items.length < 5) {
        items.add(null);
      }
      loading = false;
      notifyListeners();
    } catch (e) {
      print("Error fetching data: $e");
      loading = false;
      notifyListeners();
    }
  }

  Player? get(String? id) {
    if (id == null) return null;
    try {
      return items.firstWhere((player) => player?.id == id, orElse: () => null);
    } catch (e) {
      return null;
    }
  }

  Future<void> addPlayer(Player player, String teamId, TeamModel teamModel) async {
    try {
      // Add player to Firestore
      var docRef = await playerCollection.add(player.toJson());
      player.id = docRef.id;

      // Add player to local list
      items.add(player);

      // Update the corresponding team
      await teamModel.updateTeamPlayers(teamId, player.id!);

      // Ensure the list always has 5 items
      items.remove(null);
      while (items.length < 5) {
        items.add(null);
      }

      // Notify listeners to update the UI
      notifyListeners();
    } catch (e) {
      print("Error adding player: $e");
    }
  }

  Future<void> updatePlayer(Player player) async {
    try {
      // Update player in Firestore
      await playerCollection.doc(player.id).update(player.toJson());

      // Update player in local list
      var index = items.indexWhere((item) => item?.id == player.id);
      if (index != -1) {
        items[index] = player;
      } else {
        // If the player is not found, add it to the list
        items.add(player);
      }

      // Ensure the list always has 5 items
      items.remove(null);
      while (items.length < 5) {
        items.add(null);
      }

      // Notify listeners to update the UI
      notifyListeners();
    } catch (e) {
      print("Error updating player: $e");
    }
  }

  Future<void> deletePlayer(Player player) async {
    try {
      // Update player in Firestore
      await playerCollection.doc(player.id).delete();
      items.removeWhere((item) => item?.id == player.id);
      // Ensure the list always has 5 items
      items.remove(null);
      while (items.length < 5) {
        items.add(null);
      }
      // Notify listeners to update the UI
      notifyListeners();
    } catch (e) {
      print("Error updating player: $e");
    }
  }

  void update() {
    notifyListeners();
  }
}




