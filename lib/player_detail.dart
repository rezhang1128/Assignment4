import 'package:assignment4/player.dart';
import 'package:assignment4/team.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PlayerDetail extends StatefulWidget {
  final Player? player;
  final String teamId;
  final Function onDelete;

  const PlayerDetail({Key? key, this.player, required this.teamId, required this.onDelete}) : super(key: key);

  @override
  State<PlayerDetail> createState() => _PlayerDetailState();
}

class _PlayerDetailState extends State<PlayerDetail> {
  final _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final totalRun = TextEditingController();
  final totalBallFaced = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.player != null) {
      nameController.text = widget.player!.playerName ?? '';
      totalRun.text = widget.player!.totalRun ?? '0';
      totalBallFaced.text = widget.player!.totalBallFaced ?? '0';
    }
  }

  Future<void> _savePlayer() async {
    if (_formKey.currentState!.validate()) {
      final playerModel = Provider.of<PlayerModel>(context, listen: false);
      final teamModel = Provider.of<TeamModel>(context, listen: false);
      final newPlayer = Player(
        playerName: nameController.text,
        totalRun:totalRun.text,
        totalBallFaced: totalBallFaced.text,
        playerPhoto: widget.player?.playerPhoto ??
            'https://firebasestorage.googleapis.com/v0/b/assignment2-f42a1.appspot.com/o/team%2Fdefault.jpg?alt=media&token=0d3886e8-03db-451c-ae37-a6e82aeb6511',
      );

      if (widget.player?.id == null) {
        await playerModel.addPlayer(newPlayer, widget.teamId, teamModel);
        // widget.onSave(newPlayer.id!);
      } else {
        newPlayer.id = widget.player!.id;
        await playerModel.updatePlayer(newPlayer);
        // widget.onSave(newPlayer.id!);
      }

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.player?.playerName ?? 'New Player'),
      ),
      body: Center(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              SizedBox(
                width: 150,
                height: 150,
                child: Image.network(widget.player?.playerPhoto ??
                    'https://firebasestorage.googleapis.com/v0/b/assignment2-f42a1.appspot.com/o/team%2Fdefault.jpg?alt=media&token=0d3886e8-03db-451c-ae37-a6e82aeb6511'),
              ),
              SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(labelText: "Name: "),
                controller: nameController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a name';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(labelText: "Total Runs: "),
                controller: totalRun,
              ),
              SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(labelText: "Total Balls Faced: "),
                controller: totalBallFaced,
              ),
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: Text('Status: ${widget.player?.status ?? 'rest'}',
                    style: TextStyle(fontSize: 18)),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 100.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ElevatedButton(
                      onPressed: _savePlayer,
                      child: Text('Save'),
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white, backgroundColor: Colors.blue,// Change this to your desired color
                      ),
                    ),
                    ElevatedButton(
                      onPressed: (){
                        widget.onDelete(widget.player!);
                        final playerModel = Provider.of<PlayerModel>(context, listen: false);
                        playerModel.deletePlayer(widget.player!);
                        Navigator.pop(context);
                      },
                      child: Text('Delete'),
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white, backgroundColor: Colors.red, // Change this to your desired color
                      ),
                    ),
                  ]

                )

              ),
            ],
          ),
        ),
      ),
    );
  }
}


