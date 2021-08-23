import 'package:flutter/material.dart';
import 'package:mood_manager/core/util/hex_color.dart';

class SplashPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: HexColor.fromHex('#131945'),
        child: SafeArea(
          child: Container(
            width: double.infinity,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Center(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5.0),
                      color: Colors.transparent,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.transparent,
                          offset: Offset(0.0, 1.0), //(x,y)
                          blurRadius: 6.0,
                        ),
                      ],
                    ),
                    child: Image.asset('assets/app_icon.png'),
                    width: 75,
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                Text('Mood Manager',
                    style: TextStyle(color: Colors.white, fontSize: 20))
              ],
            ),
          ),
        ),
      ),
    );
  }
}
