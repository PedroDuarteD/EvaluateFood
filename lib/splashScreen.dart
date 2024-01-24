import 'dart:convert';
import 'package:dotted_border/dotted_border.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:evaluatefood/Config/appConfig.dart';
import 'package:evaluatefood/HomeScreen/HomeScreen.dart';

class SplashScreen extends StatelessWidget {


  int position =0;

  Future<List> getSplash(BuildContext context)async{
    var data  = await http.get(Uri.parse("${Config.ipadress}/api/access"));
    
    var d = jsonDecode(data.body);
    var pre = await SharedPreferences.getInstance();

  return [
    d["go"],
    d["version"],
    pre.containsKey("id") ? pre.getInt("id") : -1
  ];

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(28, 34, 44, 1),
      body: FutureBuilder<List>(
        future: getSplash(context),
        builder: (_, snapshot){
          if(snapshot.connectionState==ConnectionState.done || snapshot.connectionState==ConnectionState.active){
  var d = snapshot.data!;

  if(d[0]==false){


    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Spacer(
          flex: 5,
        ),
        Image.asset("assets/icon/logo.PNG", width: MediaQuery.of(context).size.width-200,),


        Spacer(
          flex: 2,
        ),
        DottedBorder(
          color: Colors.black,
          radius: Radius.circular(10),
          child: Container(
            padding: EdgeInsets.only(top: 5, bottom: 5, right: 10, left: 10),
            decoration: BoxDecoration(
              color: Color.fromRGBO(255, 184, 0, 0.19),
            ),
            child: Column(
              children: [
                SizedBox(height: 5,),
                Text("Server off",style: TextStyle(color: Colors.red),),
                SizedBox(height: 10,),

                Text("Tente novamente mais tarde")
              ],
            ),
          ),
        ),

        Spacer(
          flex: 3,
        ),
      ],
    );

  } else  if(d[0]==true && double.parse(d[1].toString())==Config.version){
    Future.delayed(Duration(seconds: 3), (){
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => HomeScreen(d[2])));

    });
    return    Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Spacer(
            flex: 5,
          ),


          Image.asset("assets/icon/logo.PNG", width: MediaQuery.of(context).size.width-200,),


          Spacer(
            flex: 2,
          ),
          CircularProgressIndicator(),

          Spacer(
            flex: 5,
          ),
        ],
      ),
    );


  }
  else if(double.parse(d[1].toString())>Config.version){
    Future.delayed(Duration(seconds: 3), (){
      showDialog(context: context,

          builder: (_) => AlertDialog(
            title: Text("Nova atualização !"),
            content: SizedBox(
              height: 90,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Queres receber as novidades ?"),
                  SizedBox(height: 20,),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ElevatedButton(onPressed: (){
                        launchUrl(Uri.parse("https://google.com"),mode: LaunchMode.externalApplication);
                      }, child: Text("Sim"))
                    ],
                  )
                ],
              ),
            ),
          ),barrierDismissible: false);
    });
    return    Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Spacer(
            flex: 5,
          ),
          Image.asset("assets/icon/logo.PNG", width: MediaQuery.of(context).size.width-200,),

          Spacer(
            flex: 2,
          ),
          CircularProgressIndicator(),

          Spacer(
            flex: 5,
          ),
        ],
      ),
    );


  } 
  return Container();


          }else{
        return    Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
                  Spacer(
                  flex: 5,
                ),
            Image.asset("assets/icon/logo.PNG", width: MediaQuery.of(context).size.width-200,),
                  Spacer(
                  flex: 2,
                ),
            CircularProgressIndicator(),

              Spacer(
                  flex: 5,
                ),
          ],
        ),
      );
          }
        },
      )
    );
  }
}