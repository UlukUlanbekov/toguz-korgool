import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../style/palette.dart';

class InfoPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final palette = context.watch<Palette>();
    const gap = SizedBox(height: 10);

    return Scaffold(
      backgroundColor: palette.infoBackground,
      resizeToAvoidBottomInset: false,
      body: Container(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
            gap,
            Center(
              child: Text(
                'Developers',
                style: TextStyle(fontFamily: 'Permanent Marker', fontSize: 42, color: palette.pen),
              ),
            ),

            gap,
            Center(
              child: Text(
                'Chyngyz Sydykov',
                style: TextStyle(fontFamily: 'Permanent Marker', fontSize: 22, color: palette.trueWhite),
              ),
            ),
            
            gap,
            Center(
              child: Text(
                'Astar Bekturov',
                style: TextStyle(fontFamily: 'Permanent Marker', fontSize: 22, color: palette.trueWhite),
              ),
            ),

            gap,
            Center(
              child: Text(
                'Hussein Jamoul',
                style: TextStyle(fontFamily: 'Permanent Marker', fontSize: 22, color: palette.trueWhite),
              ),
            ),

            gap,
            Center(
              child: Text(
                'Uluk Ulanbekov',
                style: TextStyle(fontFamily: 'Permanent Marker', fontSize: 22, color: palette.trueWhite),
              ),
            ),

            gap,
            Center(
              child: Text(
                'Daniar Asanov',
                style: TextStyle(fontFamily: 'Permanent Marker', fontSize: 22, color: palette.trueWhite),
              ),
            ),

            gap,
            Center(
              child: Text(
                'Joao Viana',
                style: TextStyle(fontFamily: 'Permanent Marker', fontSize: 22, color: palette.trueWhite),
              ),
            ),

            gap,
            gap,
            Center(
              child: ElevatedButton(
              onPressed: () {
                GoRouter.of(context).pop();
              },
              child: const Text('BACK'),
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
            ),
          ],
          )
        ),
      ),
    );
  }
}
