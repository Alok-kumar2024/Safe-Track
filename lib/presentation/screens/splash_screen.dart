import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:safe_track/colors/app_colors.dart';
import 'package:safe_track/presentation/screens/login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();

}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin{

  late AnimationController _controller;
  late Animation<double> _animation;


  @override
  void initState() {
    super.initState();

    //Not good , while change later , the animation and will make more smoothe..
    _controller = AnimationController(vsync: this , duration: Duration(seconds: 3));
    _animation = Tween<double>(begin: 0, end: 1).animate(_controller)
      ..addStatusListener((status){
      if(status == AnimationStatus.completed)
        {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginScreen()));
        }
    });
    _controller.forward();

    // Timer(Duration(seconds: 3),(){
    //   Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginScreen()));
    // });

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: BackgroundSplash());
  }

}

class BackgroundSplash extends StatelessWidget {
  const BackgroundSplash({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(gradient: AppColors.primaryGradient),

      child: Center(child: BodySplash()),
    );
  }
}

class BodySplash extends StatelessWidget {
  const BodySplash({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Spacer(flex: 1,),
        Material(
          elevation: 10,
          shape: const CircleBorder(),
          color: Colors.transparent,

          child: CircleAvatar(
            backgroundColor: Colors.white,
            radius: 70,
            child: SvgPicture.asset(
              'assets/images/shield.svg',
              width: 90,
              height: 90,
              colorFilter: const ColorFilter.mode(
                Color(0xFF9333EA),
                BlendMode.srcIn,
              ),
            ),
          ),
        ),
        SizedBox(height: 10),
        Text(
          "SafeGuard",
          style: TextStyle(
            color: Colors.white,
            fontSize: 48,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          "Your Safety, Our Priority",
          style: TextStyle(color: Colors.white70, fontSize: 18),
        ),

        Spacer(flex: 1,),
        SpinKitFadingCube(color: Colors.white,size: 50,),
        Spacer(),
      ],
    );
  }
}


