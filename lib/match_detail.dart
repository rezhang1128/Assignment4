import 'package:assignment4/match.dart';
import 'package:assignment4/player.dart';
import 'package:assignment4/player_list.dart';
import 'package:assignment4/score_board.dart';
import 'package:assignment4/team.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MatchDetails extends StatefulWidget {
  final String? id;
  final Match? match;
  final Team? batTeam;
  final Team? bowTeam;

  const MatchDetails({Key? key, this.id, this.match, this.batTeam, this.bowTeam}) : super(key: key);

  @override
  State<MatchDetails> createState() => _MatchDetailsState();
}

class _MatchDetailsState extends State<MatchDetails> {
  final _batFormKey = GlobalKey<FormState>();
  final _bowFormKey = GlobalKey<FormState>();
  final batTeamName = TextEditingController();
  final bowTeamName = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.batTeam != null) {
      batTeamName.text = widget.batTeam!.teamName ?? '';
    }
    if (widget.bowTeam != null) {
      bowTeamName.text = widget.bowTeam!.teamName ?? '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text("Match Detail"),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () async {
            TeamModel teamModel = Provider.of<TeamModel>(context, listen: false);
            MatchModel matchModel = Provider.of<MatchModel>(context, listen: false);
            bool? shouldPop = await showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: Text('Warning'),
                content: Text("Plase be sure you have saved the match and the match is over before you go back"),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () async {
                    if (widget.match != null && (!(widget.match!.over ?? false) || batTeamName.text == '' || bowTeamName.text == '')) {
                      if (widget.bowTeam != null) {
                        await teamModel.deleteTeam(widget.bowTeam!.id);
                      }
                      if (widget.batTeam != null) {
                        await teamModel.deleteTeam(widget.batTeam!.id);
                      }
                        await matchModel.deleteMatch(widget.match!.id);
                      }
                      Navigator.of(context).pop(true);
                    },
                    child: Text('Yes'),
                  ),
                ],
              ),
            );
            if (shouldPop == true) {
              Navigator.pop(context);
            }
          },
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            teamCard(widget.batTeam!, batTeamName, _batFormKey),
            teamCard(widget.bowTeam!, bowTeamName, _bowFormKey),
            saveButton(context),
          ],
        ),
      ),
    );
  }

  Form teamCard(Team team, TextEditingController name, GlobalKey<FormState> formKey) {
    return Form(
      key: formKey,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(
              width: 150,
              height: 150,
              child: Image.network(team.teamPhoto!),
            ),
            TextFormField(
              decoration: const InputDecoration(labelText: "Team Name: "),
              controller: name,
            ),
            Padding(
              padding: const EdgeInsets.only(top: 12.0),
              child: Text('Team Position: ${team.teamPosition}'),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(
                      builder: (context) {
                        return PlayerList(team: team, playerIds: team.teamPlayers);
                      }));
                },
                child: Text('Player List'),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white, backgroundColor: Colors.blue, // Change this to your desired color
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget saveButton(BuildContext context) {
    return
      Padding(
          padding: const EdgeInsets.only(top: 50.0),
          child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Expanded(
                  child: ElevatedButton(
                    onPressed: ()async {
                      if(widget.bowTeam?.teamPlayers.where((player) => player != null).length != 5 ||
                          widget.batTeam?.teamPlayers.where((player) => player != null).length != 5){
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('You must have 5 players in each team to start scoring')),
                        );
                      }else{
                        List<String?> batPlayerIds = widget.batTeam!.teamPlayers;
                        List<String?> bowPlayerIds = widget.bowTeam!.teamPlayers;
                        PlayerModel playerModel = Provider.of<PlayerModel>(context, listen: false);
                        await playerModel.fetch(batPlayerIds);
                        List<Player?> batPlayers = playerModel.items.where((player) => batPlayerIds.contains(player?.id)).toList();
                        await playerModel.fetch(bowPlayerIds);
                        List<Player?> bowPlayers = playerModel.items.where((player) => bowPlayerIds.contains(player?.id)).toList();
                        Navigator.push(context, MaterialPageRoute(
                            builder: (context)  {
                              return ScoreBoard(match: widget.match, batPlayers: batPlayers, bowPlayers: bowPlayers,);
                            })
                        );
                      }

                    },
                    child: Text('Score Board'),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white, backgroundColor: Colors.purple, // Change this to your desired color
                    ),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      if(bowTeamName.text == '' || batTeamName.text == ''){
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('You have to fill a name for each team')),
                        );
                      }
                      else if(widget.bowTeam?.teamPlayers.where((player) => player != null).length != 5 ||
                          widget.batTeam?.teamPlayers.where((player) => player != null).length != 5){
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Each team must have 5 players')),
                        );
                      }
                      else if (!widget.match!.over!){
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('The match is not over')),
                        );
                      }else if(widget.match!.over!){
                        if (_batFormKey.currentState?.validate() == true && _bowFormKey.currentState?.validate() == true) {
                          // Update team names
                          if (widget.batTeam != null) {
                            widget.batTeam!.teamName = batTeamName.text;
                          }
                          if (widget.bowTeam != null) {
                            widget.bowTeam!.teamName = bowTeamName.text;
                          }

                          // Save teams and match to the database
                          TeamModel teamModel = Provider.of<TeamModel>(context, listen: false);
                          MatchModel matchModel = Provider.of<MatchModel>(context, listen: false);

                          if (widget.batTeam != null) {
                            await teamModel.updateTeam(widget.batTeam!);
                          }
                          if (widget.bowTeam != null) {
                            await teamModel.updateTeam(widget.bowTeam!);
                          }
                          if (widget.match != null) {
                            await matchModel.updateMatch(widget.match!);
                          }
                          Navigator.pop(context);
                          // // Show a success message or navigate back

                        }
                      }
                    },
                    child: Text('Save'),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white, backgroundColor: Colors.blue, // Change this to your desired color
                    ),
                  )
                ),
              ]
          )
      );
  }
}
