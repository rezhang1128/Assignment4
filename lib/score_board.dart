import 'package:assignment4/match.dart';
import 'package:assignment4/player_list.dart';
import 'package:assignment4/player.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ScoreBoard extends StatefulWidget {
  final Match? match;
  final List<Player?> batPlayers;
  final List<Player?> bowPlayers;

  const ScoreBoard({Key? key, required this.match, required this.batPlayers, required this.bowPlayers}) : super(key: key);

  @override
  State<ScoreBoard> createState() => _ScoreBoardState();
}

class _ScoreBoardState extends State<ScoreBoard> {
  late String selectedOver;
  late Player? currentBatPlayer;
  late Player? currentBowPlayer;
  int wicketsLost = 0;
  int totalRuns = 0;
  int oversCompleted = 0;
  int ballsDeliveredThisOver = 0;

  @override
  void initState() {
    super.initState();
    selectedOver = 'Over 1';
    currentBatPlayer = widget.batPlayers.firstWhere((player) => player?.status == 'play', orElse: () => null);
    currentBowPlayer = widget.bowPlayers.firstWhere((player) => player?.status == 'play', orElse: () => null);
  }
  Future<void> _showPlayerDialog(List<Player?> players, bool isBatting) async {
    Player? selectedPlayer = await showDialog<Player>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Select Player'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: players
                .where((player) => player?.status == 'rest')
                .map((player) => ListTile(
              title: Text(player?.playerName ?? ''),
              onTap: () {
                Navigator.pop(context, player);
              },
            ))
                .toList(),
          ),
        );
      },
    );

    if (selectedPlayer != null) {
      setState(() {
        if (isBatting) {
          currentBatPlayer?.status = 'rest';
          selectedPlayer.status = 'play';
          currentBatPlayer = selectedPlayer;
        } else {
          currentBowPlayer?.status = 'rest';
          selectedPlayer.status = 'play';
          currentBowPlayer = selectedPlayer;
        }
      });
    }
  }
  bool _canSelectBall(String ball) {
    if (widget.match == null || widget.match!.scores == null || widget.match!.scores![selectedOver] == null) {
      return false;
    }
    if (currentBatPlayer == null || currentBowPlayer == null) {
      print(currentBatPlayer);
      return false;
    }
    List<String> balls = widget.match!.scores![selectedOver]!.keys.toList()..sort();
    int index = balls.indexOf(ball);
    if (index == 0) return true;  // First ball can always be selected
    String previousBall = balls[index - 1];
    return widget.match!.scores![selectedOver]![previousBall] != null;  // Previous ball must have a value
  }
  bool _canSelectOver(String over) {
    if (widget.match == null || widget.match!.scores == null) {
      return false;
    }
    List<String> sortedOvers = widget.match!.scores!.keys.toList()..sort();
    int index = sortedOvers.indexOf(over);
    if (index == 0) return true;  // First over can always be selected
    String previousOver = sortedOvers[index - 1];
    return widget.match!.scores![previousOver]!.values.every((score) => score != null);  // All balls in the previous over must have values
  }
  void _updateStats(String selectedValue) {
    widget.batPlayers.forEach((player){
      print(player!.status);
    });

    if (!selectedValue.contains('runs')) {
      wicketsLost++;
      if (currentBatPlayer != null) {
        setState(() {
          currentBatPlayer!.status = 'done';
          int currentIndex = widget.batPlayers.indexOf(currentBatPlayer);
          if (currentIndex != -1 && currentIndex < widget.batPlayers.length - 1) {
            currentBatPlayer = widget.batPlayers[currentIndex + 1];
            currentBatPlayer!.status = 'play';
          }
        });
      }
    } else {
      totalRuns += int.parse(selectedValue.split(' ')[0]);
    }
    ballsDeliveredThisOver++;
    if (ballsDeliveredThisOver == 6) {
      oversCompleted++;
      if(oversCompleted == 5){
        widget.match!.over = true;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('This match is over')),
        );
      }else{
        ballsDeliveredThisOver = 0;
        if (currentBowPlayer != null) {
          setState(() {
            currentBowPlayer!.status = 'done';
            int currentIndex = widget.bowPlayers.indexOf(currentBowPlayer);
            if (currentIndex != -1 && currentIndex < widget.bowPlayers.length - 1) {
              currentBowPlayer = widget.bowPlayers[currentIndex + 1];
              currentBowPlayer!.status = 'play';
            }
          });
        }
      }
    }
    if(wicketsLost == 5){
      widget.match!.over = true;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('This match is over')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    List<Player?> batPlaying = widget.batPlayers.where((player) => player?.status == 'play').toList();
    List<Player?> bowPlaying = widget.bowPlayers.where((player) => player?.status == 'play').toList();
    if (widget.match == null || widget.match!.scores == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Score Board'),
        ),
        body: Center(
          child: Text('No match data available'),
        ),
      );
    }

    List<String> sortedOvers = widget.match!.scores!.keys.toList()..sort();

    return Scaffold(
      appBar: AppBar(
        title: Text('Score Board'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () async {
            PlayerModel playerModel = Provider.of<PlayerModel>(context, listen: false);
            widget.batPlayers.forEach((player) async {
              if (player != null) await playerModel.updatePlayer(player);
            });
            widget.bowPlayers.forEach((player) async {
              if (player != null) await playerModel.updatePlayer(player);
            });

            // You can also update match data if necessary
            MatchModel matchModel = Provider.of<MatchModel>(context, listen: false);
            widget.match?.ballDelivery = wicketsLost as String?;
            widget.match?.run = totalRuns as String?;
            if (widget.match != null) await matchModel.updateMatch(widget.match!);

            Navigator.pop(context);
          },
        ),
      ),
      body: Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: sortedOvers.map((over) {
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton(
                    onPressed: _canSelectOver(over)
                        ? () {
                      setState(() {
                        selectedOver = over;
                      });
                    }
                        : () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('The last over is not over yet')),
                      );
                    },
                    child: Text(over),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: selectedOver == over ? Colors.blue : Colors.grey,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          Expanded(
            child: ListView(
              children: (widget.match!.scores![selectedOver]!.keys.toList()..sort()).map((ball) {
                return ListTile(
                  title: Text(ball),
                  trailing: Text(widget.match!.scores![selectedOver]![ball] ?? 'Tap here to record this ball'),
                  onTap: () async {
                    if (widget.match!.over!) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('This match is over')),
                      );
                      return;
                    }
                    if (currentBatPlayer == null || currentBowPlayer == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Current batter and bowler must be set to play')),
                      );
                      return;
                    }
                    if (_canSelectBall(ball)) {

                      String? selectedValue = await _selectValue(context);
                      if (selectedValue != null && selectedValue == 'Run') {
                        selectedValue = await _selectRun(context);
                      }
                      if (selectedValue != null) {
                        setState(() {
                          widget.match!.scores![selectedOver]![ball] = selectedValue;
                          _updateStats(selectedValue!);
                        });
                      }
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('You miss the last ball record')),
                      );
                    }
                  },
                );
              }).toList(),
            ),
          ),
          Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    Text('Current Batting Players'),
                    ...batPlaying.isEmpty
                        ? [ListTile(
                        title: Text('Click to set a player to play'),
                      onTap: () => _showPlayerDialog(widget.batPlayers, true),
                    )]
                        : batPlaying.map((player) {
                      return ListTile(
                        title: Text(player?.playerName ?? 'Unknown'),
                        onTap: () => _showPlayerDialog(widget.batPlayers, true),
                      );
                    }).toList(),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  children: [
                    Text('Current Bowling Players'),
                    ...bowPlaying.isEmpty
                        ? [ListTile(
                        title: Text('Click to set a player to play'),
                      onTap: () => _showPlayerDialog(widget.bowPlayers, false),
                    )]
                        : bowPlaying.map((player) {
                      return ListTile(
                        title: Text(player?.playerName ?? 'Unknown'),
                        onTap: () => _showPlayerDialog(widget.bowPlayers, false),
                      );
                    }).toList(),
                  ],
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(64.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Text('$wicketsLost / $totalRuns'),
                Text('$oversCompleted / $ballsDeliveredThisOver'),
              ]
            )
          ),
        ],
      ),
    );
  }

  Future<String?> _selectValue(BuildContext context) async {
    return showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Select Value'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              'Run',
              'Bowled',
              'Caught',
              'Caught and Bowled',
              'Leg Before Wicket (LBW)',
              'Run Out',
              'Hit Wicket',
              'Stumping'
            ].map((value) => ListTile(
              title: Text(value),
              onTap: () {
                Navigator.pop(context, value);
              },
            )).toList(),
          ),
        );
      },
    );
  }

  Future<String?> _selectRun(BuildContext context) async {
    int runs = 0;
    return showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Select Runs'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Runs: $runs'),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: Icon(Icons.remove),
                        onPressed: () {
                          setState(() {
                            if (runs > 0) runs--;
                          });
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.add),
                        onPressed: () {
                          setState(() {
                            runs++;
                          });
                        },
                      ),
                    ],
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context, null);
                  },
                  child: Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context, '$runs runs');
                  },
                  child: Text('OK'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
