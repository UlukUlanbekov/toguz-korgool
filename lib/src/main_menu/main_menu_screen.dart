// Copyright 2022, the Flutter project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../audio/audio_controller.dart';
import '../audio/sounds.dart';
import '../settings/settings.dart';
import '../style/palette.dart';
import '../style/responsive_screen.dart';

class MainMenuScreen extends StatelessWidget {
  const MainMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final palette = context.watch<Palette>();
    final settingsController = context.watch<SettingsController>();
    final audioController = context.watch<AudioController>();


    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight
    ]);
    
    return Scaffold(
      backgroundColor: palette.backgroundMain,
      body: new Container(
        decoration: new BoxDecoration(
          image: new DecorationImage(
            image: new AssetImage('assets/images/main-background.png'),
            fit: BoxFit.fill
          )
        ),
        child: ResponsiveScreen(
          mainAreaProminence: 0.45,
          squarishMainArea: Center(
            child:
                Text(
                  'Toguz Korgool Game!',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white),
                )
          ),

          rectangularMenuArea: Column(
            children: [
              ElevatedButton(
                onPressed: () {
                  audioController.playSfx(SfxType.buttonTap);
                  GoRouter.of(context).go('/board');
                },
                child: const Text('START GAME'),
                style: TextButton.styleFrom(
                  primary: palette.trueWhite,
                  minimumSize: Size(150, 40),
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  backgroundColor: palette.trueWhite.withOpacity(0.3),
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12.0)),
                  ),
                  side: BorderSide(color: palette.trueWhite)
                ),
              ),
              
              ValueListenableBuilder<bool>(
                  valueListenable: settingsController.muted,
                  builder: (context, muted, child) {
                    return IconButton(
                      onPressed: () => settingsController.toggleMuted(),
                      icon: Icon(muted ? Icons.volume_off : Icons.volume_up),
                    );
                  },
                ),
              const Text('Developed by Turbine Kreuzberg',style: TextStyle(color: Colors.white)),
            ],
          ),
        ),
      )
    );
  }

  /// Prevents the game from showing game-services-related menu items
  /// until we're sure the player is signed in.
  ///
  /// This normally happens immediately after game start, so players will not
  /// see any flash. The exception is folks who decline to use Game Center
  /// or Google Play Game Services, or who haven't yet set it up.
  Widget _hideUntilReady({required Widget child, required Future<bool> ready}) {
    return FutureBuilder<bool>(
      future: ready,
      builder: (context, snapshot) {
        // Use Visibility here so that we have the space for the buttons
        // ready.
        return Visibility(
          visible: snapshot.data ?? false,
          maintainState: true,
          maintainSize: true,
          maintainAnimation: true,
          child: child,
        );
      },
    );
  }

  static const _gap = SizedBox(height: 10);
}
