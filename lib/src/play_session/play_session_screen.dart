// Copyright 2022, the Flutter project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:logging/logging.dart' hide Level;
import 'package:provider/provider.dart';
import 'dart:math';

import '../ads/ads_controller.dart';
import '../audio/audio_controller.dart';
import '../audio/sounds.dart';
import '../game_internals/level_state.dart';
import '../games_services/games_services.dart';
import '../games_services/score.dart';
import '../in_app_purchase/in_app_purchase.dart';
import '../level_selection/levels.dart';
import '../player_progress/player_progress.dart';
import '../style/confetti.dart';
import '../style/palette.dart';

class PlaySessionScreen extends StatefulWidget {
  const PlaySessionScreen({super.key});

  @override
  State<PlaySessionScreen> createState() => _PlaySessionScreenState();
}

class _PlaySessionScreenState extends State<PlaySessionScreen> {
  static final _log = Logger('PlaySessionScreen');
  
  List<int> player1balls = [9,9,9,9,9,9,9,9,9];
  List<int> player2balls = [9,9,9,9,9,9,9,9,9];

  List<String> player1TileImages = [];
  List<String> player2TileImages = [];

  int player1Scores = 0;
  int player2Scores = 0;
  int playerTurn = 1;
  int turnIndex = -1;
  int player1Avatar = 1;
  int player2Avatar = 2;


  static const _celebrationDuration = Duration(milliseconds: 2000);

  static const _preCelebrationDuration = Duration(milliseconds: 500);

  bool _duringCelebration = false;

  late DateTime _startOfPlay;

  void main() {
    // random avatars
    var rng = Random();
    player1Avatar = rng.nextInt(12);
    player2Avatar = rng.nextInt(12);

    do {
      player2Avatar = rng.nextInt(12);
    }while(player1Avatar == player2Avatar);
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.watch<Palette>();

    player1TileImages = [];
    for(var i = 0; i < 9; i++)
    {
      var player1Image = 'assets/images/player1-tile.png';
      if (playerTurn == 1 && turnIndex == i) {
        player1Image = 'assets/images/player1-tile-selected.png';
      }
      player1TileImages.add(player1Image);
    }

    player2TileImages = [];
    for(var i = 0; i < 9; i++)
    {
      var player2Image = 'assets/images/player2-tile.png';
      if (playerTurn == 2 && turnIndex == i) {
        player2Image = 'assets/images/player2-tile-selected.png';
      }
      player2TileImages.add(player2Image);
    }

    var turnButton = (turnIndex == -1) ? 'assets/images/turn-button.png' : 'assets/images/turn-button-selected.png';

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => LevelState(
            onWin: _playerWon,
          ),
        ),
      ],
      child: IgnorePointer(
        ignoring: _duringCelebration,
        child: Scaffold(
          backgroundColor: palette.backgroundPlaySession,
          body: 
          new Container (
            decoration: new BoxDecoration(
              image: new DecorationImage(
                image: new AssetImage('assets/images/main-background.png'),
                fit: BoxFit.fill
              )
            ),
            child: Column(
              children: [
                Expanded(
                  flex: 1,
                  child: Padding(
                    padding: EdgeInsets.all(8),
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Container(
                        width: 100,
                        decoration: new BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          color: Colors.white,
                        ),
                        child: Row(
                          children:[
                            Image(
                              image: new AssetImage('assets/images/avatar'+player1Avatar.toString()+'.png'),
                              height: 30,
                              fit: BoxFit.fitHeight
                            ),
                            Padding(
                              padding: EdgeInsets.fromLTRB(8.0,0,0,0),
                              child: Text('Player 2'),
                            )
                          ]
                        )
                      )
                    )
                  )
                ),
                Expanded(
                  flex: 2,
                  child:GridView.builder(
                    itemCount: 9,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 9),
                    physics: NeverScrollableScrollPhysics(),
                    itemBuilder: (BuildContext, int index) {
                      return GestureDetector(
                        onTap: (){
                          _tapped(2, index);
                        },
                        child: Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              image: new DecorationImage(
                                image: new AssetImage(player2TileImages[index]),
                                fit: BoxFit.scaleDown
                              )
                            ),
                            child: Center(
                              child: Text(player2balls[index].toString(), style: TextStyle(color: Colors.white)),
                            ),
                          )
                        )
                      );
                    },              
                  ),
                ),
                Expanded(
                  flex: 4,
                  child: Row(children: [
                    Expanded(
                      child: Container (
                        decoration: new BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          image: new DecorationImage(
                            image: new AssetImage('assets/images/player2-score-tile.png'),
                            fit: BoxFit.contain
                          )
                        ),
                        child: Center(
                              child: Text(player2Scores.toString(), style: TextStyle(color: Colors.white)),
                            )
                      )
                    ),
                    Expanded(
                      child: TextButton(
                        onPressed: () {
                          _turnTapped();
                        },
                        child: Image.asset(turnButton)
                      )
                    ),
                    Expanded(
                      child: Container (
                        decoration: new BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          image: new DecorationImage(
                            image: new AssetImage('assets/images/player1-score-tile.png'),
                            fit: BoxFit.fitWidth
                          )
                        ),
                        child: Center(
                              child: Text(player1Scores.toString(), style: TextStyle(color: Colors.black)),
                            )
                      )
                    ),
                  ]),
                ),
                Expanded(
                  flex: 2,
                  child:GridView.builder(
                    itemCount: 9,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 9),
                    physics: NeverScrollableScrollPhysics(),
                    itemBuilder: (BuildContext, int index) {
                      return GestureDetector(
                        onTap: (){
                          _tapped(1, index);
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            image: new DecorationImage(
                              image: new AssetImage(player1TileImages[index]),
                              fit: BoxFit.contain
                            )
                          ),
                          child:
                          Align(
                            alignment: Alignment.topCenter,
                            child: 
                              Padding(
                                padding:
                                  EdgeInsets.fromLTRB(0,5,0,0),
                                child: 
                                  Text(player1balls[index].toString(), style: TextStyle(color: Colors.black)),
                                )
                          )
                        )
                      );
                    },              
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: EdgeInsets.all(8),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Container(
                            width: 100,
                            decoration: new BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                              color: Colors.white,
                            ),
                            child: Row(
                              children:[
                                Image(
                                  image: new AssetImage('assets/images/avatar'+player2Avatar.toString()+'.png'),
                                  height: 30,
                                  fit: BoxFit.fitHeight
                                ),
                                Padding(
                                  padding: EdgeInsets.fromLTRB(0,0,8,0),
                                  child: Text('Player 1'),
                                )
                              ]
                            )
                          )
                        )
                      ),
                      ElevatedButton(
                        onPressed: () {
                          _playerWon();
                        },
                        child: const Text('Finish'),
                        style: TextButton.styleFrom(
                          primary: palette.trueWhite,
                          padding: EdgeInsets.symmetric(horizontal: 16.0),
                          backgroundColor: palette.trueWhite.withOpacity(0.3),
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(12.0)),
                          ),
                          side: BorderSide(color: palette.trueWhite)
                        ),
                      )
                  ])
                )
              ]
            )
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();

    _startOfPlay = DateTime.now();

    // Preload ad for the win screen.
    final adsRemoved =
        context.read<InAppPurchaseController?>()?.adRemoval.active ?? false;
    if (!adsRemoved) {
      final adsController = context.read<AdsController?>();
      adsController?.preloadAd();
    }
  }

  void _tapped(int player, int index){
    if (player != playerTurn){
      return;
    }

    turnIndex = index;
    setState(() {});
  }

  void _turnTapped() {
    var remainder = (playerTurn == 1) ? player1balls[turnIndex] : player2balls[turnIndex];
    if (remainder == 0)
      return;

    if (playerTurn == 1) {
      player1balls[turnIndex] = 0;
    } else {
      player2balls[turnIndex] = 0;
    }
    
    var i = turnIndex;
    var isPlayer1Holes = (playerTurn == 1);

    do{
      if (isPlayer1Holes) {
        i++;
      } else {
        i--;
      }

      if(i == 9) {
        i = 8;
        isPlayer1Holes = false;
      }else if(i == -1) {
        i = 0;
        isPlayer1Holes = true;
      }

      if (isPlayer1Holes) {
        player1balls[i]++;
      } else {
        player2balls[i]++;
      }
      
      remainder--;
    } while(remainder != 0);
    
    if(isPlayer1Holes) {
      calculateScore(1, i);
    } else {
      calculateScore(2, i);
    }

    playerTurn = (playerTurn == 1) ? 2 : 1;
    turnIndex = -1;
    setState((){});
  }

  void calculateScore(int player, int index) {
    if (playerTurn == player) {
      return;
    }

    var score = (player == 1) ? player1balls[index] : player2balls[index]; 
    if (score % 2 != 0){
      return;
    }

    if (playerTurn == 1){
      player1Scores += score;
      player2balls[index] = 0;
    }

    if (playerTurn == 2){
      player2Scores += score;
      player1balls[index] = 0;
    }
  }

  Future<void> _playerWon() async {
    _log.info('Player won');

    // final score = Score(
    //   widget.level.number,
    //   widget.level.difficulty,
    //   DateTime.now().difference(_startOfPlay),
    // );

    // final playerProgress = context.read<PlayerProgress>();
    // playerProgress.setLevelReached(widget.level.number);

    // Let the player see the game just after winning for a bit.
    await Future<void>.delayed(_preCelebrationDuration);
    if (!mounted) return;

    setState(() {
      _duringCelebration = true;
    });

    final audioController = context.read<AudioController>();
    audioController.playSfx(SfxType.congrats);

    /// Give the player some time to see the celebration animation.
    // await Future<void>.delayed(_celebrationDuration);
    if (!mounted) return;

    GoRouter.of(context).go('/won', extra: {'player1Score': player1Scores, 'player2Score': player2Scores});
  }
}
