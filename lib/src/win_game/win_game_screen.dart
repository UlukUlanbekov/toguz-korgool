// Copyright 2022, the Flutter project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../ads/ads_controller.dart';
import '../ads/banner_ad_widget.dart';
import '../in_app_purchase/in_app_purchase.dart';
import '../style/palette.dart';
import '../style/responsive_screen.dart';

class WinGameScreen extends StatelessWidget {
  final int player1Score;
  final int player2Score;

  const WinGameScreen(this.player1Score, this.player2Score);

  @override
  Widget build(BuildContext context) {
    final adsControllerAvailable = context.watch<AdsController?>() != null;
    final adsRemoved =
        context.watch<InAppPurchaseController?>()?.adRemoval.active ?? false;
    final palette = context.watch<Palette>();

    const gap = SizedBox(height: 10);

    String winner = "Player 1 won";
    int maxScore = player1Score;
    if (player1Score < player2Score) {
      winner = "Player 2 won";
      maxScore = player2Score;
    }
    else if (player1Score == player2Score)
    {
        winner = "Stalemate";
    }
    return Scaffold(
      backgroundColor: palette.backgroundPlaySession,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          if (adsControllerAvailable && !adsRemoved) ...[
            const Expanded(
              child: Center(
                child: BannerAdWidget(),
              ),
            ),
          ],
          gap,
          Center(
            child:   
            Text(
              '$winner',
              style: TextStyle(fontFamily: 'Permanent Marker', fontSize: 50),
            ),
          ),
          gap,
          Center(
            child: Text(
              'Score: ${maxScore}\n',
              style:
                  const TextStyle(fontFamily: 'Permanent Marker', fontSize: 20),
            ),
          ),
          gap,
          Center(
            child: ElevatedButton(
            onPressed: () {
              GoRouter.of(context).pop();
            },
            child: const Text('Play again'),
          ),
          ),
        ],
      ),
    );
  }
}
