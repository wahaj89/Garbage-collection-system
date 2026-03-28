import 'package:flutter/material.dart';
import 'package:garbage_collection_system/custom_widgets/button.dart';

class Splash extends StatefulWidget {
  const Splash({super.key});

  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [

              // App Icon
              Image.asset(
                'assets/app_icon.jpg',
                width: 400,
                height: 400,
              ),

              const SizedBox(height: 40),

            CustomButton(text: "Get Started", onPressed:() {
             Navigator.pushNamed(context, '/splash2');

            }, icon: Icons.arrow_forward,)
            ],
          ),
        ),
      ),
    );
  }
}
