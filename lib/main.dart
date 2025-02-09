import 'package:assignment4/match.dart';
import 'package:assignment4/team.dart';
import 'package:assignment4/player.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:provider/provider.dart';
import 'match_detail.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();

  var app = await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  print("\n\nConnected to Firebase App ${app.options.projectId}\n\n");

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => MatchModel()),
        ChangeNotifierProvider(create: (context) => PlayerModel()),
        ChangeNotifierProvider(create: (context) => TeamModel()), // Added PlayerModel provider
      ],
      child: MaterialApp(
        title: 'All Match',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: const MyHomePage(title: 'All Match'),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Consumer<MatchModel>(
      builder: (context, matchModel, _) {
        List<Match> filteredMatches = matchModel.items.where((match) {
          var battingTeam = matchModel.teams[match.battingTeam]?.teamName?.toLowerCase() ?? '';
          var bowlingTeam = matchModel.teams[match.bowlingTeam]?.teamName?.toLowerCase() ?? '';
          return battingTeam.contains(_searchQuery.toLowerCase()) || bowlingTeam.contains(_searchQuery.toLowerCase());
        }).toList();

        return Scaffold(
          appBar: AppBar(
            backgroundColor: Theme.of(context).colorScheme.inversePrimary,
            title: Text(widget.title),
          ),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      labelText: 'Search by Team Name',
                      border: OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchQuery = '';
                          });
                        },
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                  ),
                ),
                if (matchModel.loading)
                  const CircularProgressIndicator()
                else
                  Expanded(
                    child: ListView.builder(
                      itemBuilder: (_, index) {
                        var match = filteredMatches[index];
                        var battingTeam = matchModel.teams[match.battingTeam];
                        var bowlingTeam = matchModel.teams[match.bowlingTeam];
                        return InkWell(
                          child: Card(
                            elevation: 2.0,
                            margin: EdgeInsets.all(4.0),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text('Batting Team'),
                                        SizedBox(
                                          width: 100, // Set the desired width
                                          height: 100, // Set the desired height
                                          child: Image.network(battingTeam!.teamPhoto!),
                                        ),
                                        Text('${battingTeam.teamName}'),
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text('${match.run}'),
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text('Bowling Team'),
                                        if (bowlingTeam?.teamPhoto != null)
                                          SizedBox(
                                            width: 100, // Set the desired width
                                            height: 100, // Set the desired height
                                            child: Image.network(bowlingTeam!.teamPhoto!),
                                          ),
                                        Text('${bowlingTeam?.teamName}'),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          onTap: () {
                            Navigator.push(context, MaterialPageRoute(
                              builder: (context) {
                                return MatchDetails(id: match.id, match: match, batTeam: battingTeam, bowTeam: bowlingTeam);
                              },
                            ));
                          },
                        );
                      },
                      itemCount: filteredMatches.length,
                    ),
                  ),
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () async {
              TeamModel teamModel = Provider.of<TeamModel>(context, listen: false);
              MatchModel matchModel = Provider.of<MatchModel>(context, listen: false);
              // Create new match
              Team newBatTeam = Team(teamPosition: 'bat');
              await teamModel.createTeam(newBatTeam);
              Team newBowTeam = Team(teamPosition: 'bow');
              await teamModel.createTeam(newBowTeam);
              Match newMatch = Match(battingTeam: newBatTeam.id, bowlingTeam: newBowTeam.id);
              await matchModel.createMatch(newMatch);
              Navigator.push(context, MaterialPageRoute(
                builder: (context) {
                  return MatchDetails(id: newMatch.id, match: newMatch, batTeam: newBatTeam, bowTeam: newBowTeam);
                },
              ));
            },
            child: const Icon(Icons.add),
          ),
        );
      },
    );
  }
}
