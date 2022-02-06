import 'package:flutter/material.dart';
import 'package:ctse_assignment4_flowerapp/screens/home_page.dart';
import 'package:ctse_assignment4_flowerapp/screens/addFlower.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
Future<void> main() async{

WidgetsFlutterBinding.ensureInitialized();
await Firebase.initializeApp();
//await FirebaseAppCheck.instance.activate(webRecaptchaSiteKey: 'recaptcha-v3-site-key');
  runApp(MyApp());

}

class MyApp extends StatelessWidget {
  final Future<FirebaseApp> _initialization = Firebase.initializeApp();

  @override
  Widget build(BuildContext context) {



    return MaterialApp(

      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Color(0xff67864A),
      ),
      home: FutureBuilder(
        future: _initialization,
        builder: (context,AsyncSnapshot snapshot) {
          if(snapshot.hasError){
            print("You have an error"+snapshot.error.toString());
            return Text("Something went wrong");
          }else if(snapshot.hasData){
            return MyApp();
          }else{
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          return MyApp();
        },
      ),
    );
  }
}