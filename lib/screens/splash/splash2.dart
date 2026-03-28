import 'package:flutter/material.dart';
import 'package:garbage_collection_system/custom_widgets/button.dart';

class Splash2 extends StatefulWidget {
  const Splash2({super.key});

  @override
  State<Splash2> createState() => _SplashState();
}

class _SplashState extends State<Splash2> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child:
          SingleChildScrollView(
            child:
          
           Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // App Icon
              Image.asset('assets/app_icon.jpg', width: 400, height: 400),

              const SizedBox(height: 40),

              SizedBox(
                width: 200, 
                height: 50, 
                child: CustomButton(
                  text: "Start as User",
                  onPressed: () {
                    Navigator.pushNamed(context, '/signup');
                  },
                ),
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: 200,
                height: 50,
                child: CustomButton(
                  text: "Start as Company",
                  onPressed: () {
                    Navigator.pushNamed(context, '/addcompany');
                  },
                ),
              ),
            ],
          )),
        ),
      ),
    );
  }
}
