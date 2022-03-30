import 'dart:async';

import 'package:attend/providers/auth.dart';
import 'package:attend/screens/auth_screen.dart';
import 'package:flutter/material.dart';
import 'package:tuple/tuple.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

int _animationDuration = 300;

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Future.delayed(Duration(seconds: 4)).then((_) {});
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size deviceSize = MediaQuery.of(context).size;
    double sh = deviceSize.height;
    double sw = deviceSize.width;
    return Scaffold(
      // resizeToAvoidBottomInset: false,
      body: SingleChildScrollView(
        child: CustomPaint(
          painter: AuthScreenBackground(),
          size: deviceSize,
          child: Container(
            height: sh,
            width: sw,
            padding: EdgeInsets.symmetric(
              horizontal: 0.085 * sw,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                AnimatedContainer(
                  padding: EdgeInsets.only(top: 0.10 * sh, bottom: 0.04 * sh),
                  duration: Duration(milliseconds: _animationDuration),
                  child: Container(
                    padding: const EdgeInsets.all(5.0),
                    child: Image.asset(
                      'assets/images/kwsu.png',
                      width: 150.0,
                    ),
                  ),
                ),
                SizedBox(height: 0.040 * sh),
                AnimatedContainer(
                  duration: Duration(milliseconds: _animationDuration),
                  child: Text(
                    "MOBILE BASED STUDENT ATTENDANCE SYSTEM USING GEO FENCING AND FACE RECOGNITION",
                    style: TextStyle(
                      color: Color(0xFF1B5E20),
                      fontSize: 22.0,
                      fontWeight: FontWeight.w900,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(height: 0.015 * sh),
                Text(
                  "BY",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 15.0,
                    fontWeight: FontWeight.w900,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 0.030 * sh),
                Text(
                  "OJEKUNLE ADEKUNLE SAMUEL \n 17/47CS/679",
                  style: TextStyle(
                    color: Color(0xFF8078DA),
                    fontSize: 19.0,
                    fontWeight: FontWeight.w900,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 0.030 * sh),
                Text(
                  "OYEYIPO OPEYEMI EMMANUEL \n 17/47CS/681",
                  style: TextStyle(
                    color: Color(0xFF8078DA),
                    fontSize: 19.0,
                    fontWeight: FontWeight.w900,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 0.030 * sh),
                Text(
                  "OYEYEMI JOSHUA TEMITOPE \n 18D/7CS/00135",
                  style: TextStyle(
                    color: Color(0xFF8078DA),
                    fontSize: 19.0,
                    fontWeight: FontWeight.w900,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 0.050 * sh),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class AuthScreenBackground extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    double sw = size.width;
    double sh = size.height;
    Paint paint = Paint();

    Path firstWave = Path();

    firstWave.lineTo(0, 0.406 * sh);
    firstWave.quadraticBezierTo(0.081 * sw, 0.475 * sh, 0.508 * sw, 0.490 * sh);
    firstWave.quadraticBezierTo(0.912 * sw, 0.500 * sh, 1.000 * sw, 0.558 * sh);
    firstWave.lineTo(sw, 0);
    firstWave.close();

    var rect = Offset.zero & size;
    paint.shader = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Color.fromRGBO(112, 210, 255, 1),
        Color.fromRGBO(123, 112, 255, 1),
        Color.fromRGBO(0, 0, 0, 0)
      ],
    ).createShader(rect);

    canvas.drawPath(firstWave, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}
