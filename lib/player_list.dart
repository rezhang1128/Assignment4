import 'package:assignment4/player.dart';
import 'package:assignment4/player_detail.dart';
import 'package:assignment4/team.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PlayerList extends StatefulWidget {
  final Team? team;
  final List<String?>? playerIds;

  const PlayerList({Key? key, this.team, this.playerIds}) : super(key: key);

  @override
  State<PlayerList> createState() => _PlayerListState();
}

class _PlayerListState extends State<PlayerList> {
  late Future<void> _fetchPlayersFuture;
  late List<String?> _localPlayerIds;

  @override
  void initState() {
    super.initState();
    _localPlayerIds = List<String?>.from(widget.playerIds ?? []);
    _ensureFivePlayers();
    _fetchPlayersFuture = _fetchPlayers();
  }

  Future<void> _fetchPlayers() async {
    if (_localPlayerIds.isNotEmpty) {
      await Provider.of<PlayerModel>(context, listen: false)
          .fetch(_localPlayerIds.whereType<String>().toList());
    }
  }

  void _ensureFivePlayers() {
    while (_localPlayerIds.length < 5) {
      _localPlayerIds.add(null);
    }
  }

  void _onDelete(Player player) {
    setState(() {
      final index = _localPlayerIds.indexOf(player.id);
      if (index != -1) {
        _localPlayerIds[index] = null;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final playerModel = Provider.of<PlayerModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.team?.teamName ?? 'Player List'),
      ),
      body: FutureBuilder<void>(
        future: _fetchPlayersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            return ListView.builder(
              itemCount: _localPlayerIds.length,
              itemBuilder: (context, index) {
                final playerId = _localPlayerIds[index];
                final player =
                    playerId != null ? playerModel.get(playerId) : null;

                return ListTile(
                  leading: player?.playerPhoto != null
                      ? Image.network(player!.playerPhoto!)
                      : const CircleAvatar(child: Icon(Icons.person)),
                  title: Text(player?.playerName ?? 'No Player'),
                  subtitle: Text('Status: ${player?.status ?? 'Unknown'}'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PlayerDetail(
                          player: player ?? Player(),
                          teamId: widget.team?.id ?? '',
                          onDelete: _onDelete,
                        ),
                      ),
                    );
                  },
                );
              },
            );
          }
        },
      ),
    );
  }
}
