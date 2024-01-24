import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:evaluatefood/Account/Account.dart';
import 'package:evaluatefood/Config/appConfig.dart';
import 'package:evaluatefood/Model/User/User.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'index.dart';

class SignIn extends StatefulWidget {

  @override
  State<SignIn> createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  TextEditingController edit_email = new TextEditingController();

  TextEditingController edit_password = new TextEditingController();

  FocusNode email = new FocusNode(), pass = new FocusNode();

  bool showPass = true;

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      appBar: AppBar(title: Text("Iniciar Sessão"),),

      body: Padding(
        padding: const EdgeInsets.only(right: 20,left: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 35,
            ),

            Text("Evaluate Food",style: TextStyle(fontSize: 35,color: Colors.blue),),
            SizedBox(
              height: 35,
            ),

            Container(
              height: 45,
              child: TextField(
                focusNode: email,
                onTap: (){
                  setState(() {
                    email.requestFocus();
                    pass.unfocus();
                  });
                },
                onTapOutside: (tap){
                  setState(() {
                    email.unfocus();
                    pass.unfocus();
                  });
                },
                decoration: InputDecoration(
                    label: Text("Email"),
                    prefixIcon: Icon(Icons.email,color: email.hasFocus ? Colors.blue : Color.fromRGBO(219, 219, 229, 100)),
                    border: OutlineInputBorder(

                    )),
                controller: edit_email,
                keyboardType: TextInputType.emailAddress,
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Container(
              height: 45,
              child: TextField(
                focusNode: pass,
                onTap: (){
                  setState(() {
                    email.unfocus();
                    pass.requestFocus();
                  });
                },
                onTapOutside: (tap){
                  setState(() {
                    email.unfocus();
                    pass.unfocus();
                  });
                },
                decoration: InputDecoration(
                    label: Text("Password"),
                    prefixIcon: Icon(Icons.lock,color: pass.hasFocus ? Colors.blue : Color.fromRGBO(219, 219, 229, 100)),
                    suffixIcon: GestureDetector(
                      onTap: (){
                        setState(() {
                          showPass = !showPass;
                        });
                      },
                      child: Icon(Icons.remove_red_eye),
                    ),
                    border: OutlineInputBorder(

                    )),
                keyboardType: TextInputType.text,
                obscureText: showPass,
                controller: edit_password,
              ),
            ),
            SizedBox(
              height: 10,
            ),

                Padding(
                  padding: EdgeInsets.only(top: 10),
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    child: Material(
                      elevation: 0.3,
                      child: ElevatedButton(onPressed: ()async{

                          if( edit_email.text!="" && edit_password.text!="" ){
                            var resultado = await http.post(Uri.parse(Config.ipadress+"/api/LoginUser"),body: {
                              "email": edit_email.text,
                              "password": edit_password.text,
                            });

                              var resultado_json = jsonDecode(resultado.body);

                              if(resultado_json["response"]=="Sucesso"){

                                  final preferences = await SharedPreferences.getInstance();

                                  preferences.setInt("id", resultado_json["id"]);
                                  preferences.setString("name", resultado_json["name"].toString());
                                  preferences.setString("email", edit_email.text);
                                  preferences.setString("action", resultado_json["action"]);


                                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=> Account(resultado_json["id"], true, -1)));
                              }else{
                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(resultado_json["ans"])));
                              }

                          }else{
                            String error ="";

                              if(edit_email.text==""){
                              error = "Email";
                            }


                               if(edit_password.text==""){
                              error = "Password";
                            }
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Por favor altere "+error)));
                          }

                      }, child: const Text("Entrar")),
                    ),
                  ),
                ),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                    onTap: (){
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Ainda não disponível !")));
                    },
                    child: Text("Não lembro da senha",style: TextStyle(color: Colors.black,decoration: TextDecoration.underline),)),
                GestureDetector(
                    onTap: (){
                      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) =>CreateAccount() ));
                    },
                    child: Text("Não tenho conta ?", style: TextStyle(color: Colors.green, decoration: TextDecoration.underline),))
              ],
            )
          ],
        ),
      ),
    );
  }
}