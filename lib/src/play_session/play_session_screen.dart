// Copyright 2022, the Flutter project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';
import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:game_template/src/hole/hole.dart';
import 'package:go_router/go_router.dart';
import 'package:logging/logging.dart' hide Level;
import 'package:provider/provider.dart';

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
import '../hole/hole.dart';

class PlaySessionScreen extends StatefulWidget {
  const PlaySessionScreen({super.key});

  @override
  State<PlaySessionScreen> createState() => _PlaySessionScreenState();
}

class _PlaySessionScreenState extends State<PlaySessionScreen> {
  static final _log = Logger('PlaySessionScreen');
  
  List<int> player1balls = [9,9,9,9,9,9,9,9,9];
  List<int> player2balls = [9,9,9,9,9,9,9,9,9];

  List<int> playerScores = [0,0];
  int playerTurn = 1;
  int turnIndex = 1;


  static const _celebrationDuration = Duration(milliseconds: 2000);

  static const _preCelebrationDuration = Duration(milliseconds: 500);

  bool _duringCelebration = false;

  late DateTime _startOfPlay;

  @override
  Widget build(BuildContext context) {
    final palette = context.watch<Palette>();

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
                Flexible(
                  child:GridView.builder(
                    itemCount: 9,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 9),
                    itemBuilder: (BuildContext, int index) {
                      return GestureDetector(
                        onTap: (){
                          _tapped(1, index);
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey)
                          ),
                          child: Center(
                            child: Text(player1balls[index].toString()),
                          ),
                        )
                      );
                    },              
                  ),
                ),
                Flexible(
                  child:GridView.builder(
                    itemCount: 9,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 9),
                    itemBuilder: (BuildContext, int index) {
                      return GestureDetector(
                        onTap: (){
                          _tapped(2, index);
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey)
                          ),
                          child: Center(
                            child: Text(player2balls[index].toString()),
                          ),
                        )
                      );
                    },              
                  ),
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
    setState(() {
      if (player == 1)
        player1balls[index] = 2;
      if (player == 2)
        player2balls[index] = 2;
    });

    turnIndex = index;
  }

  void _turnTapped() {
    if (playerTurn == 1) {

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
    await Future<void>.delayed(_celebrationDuration);
    if (!mounted) return;

    GoRouter.of(context).go('/won', extra: {'player1Score': 30, 'player2Score': 90});
  }
}
