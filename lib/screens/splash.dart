import 'package:flutter/material.dart';
import 'dart:async';
import 'onboarding.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {

   late AnimationController _animationController;
   late Animation<double> _fadeAnimation;
   
  @override
   void initState(){
      super.initState();
  
      _animationController = AnimationController(
        duration: const Duration(seconds: 2),
        vsync: this,
      );
  
      _fadeAnimation = Tween<double>(
        begin: 0.0,
        end: 2.5,
      ).animate(_animationController);
  
      _animationController.forward(); 
      Timer(const Duration(seconds: 3), (){
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const OnboardingScreen()),
        );
      });
    }

  @override
  void dispose(){
    _animationController.dispose();
    super.dispose();
   }


 Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF3077E3),
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
               Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Image.asset(
                  'assets/images/icon_herbal.png',
                  width: 150,
                  height: 150,
                ),
              ), 
            ],
          ),
        ),
      ),
    );
  }


}