import "dart:convert";
import "dart:io";

import "package:flutter/material.dart";
import "package:http/http.dart" as http;
import "package:images_picker/images_picker.dart";
import "package:evaluatefood/Account/Account.dart";
import "package:evaluatefood/Config/appConfig.dart";
import "package:evaluatefood/Create/Account/Sign%20in.dart";
import "package:shared_preferences/shared_preferences.dart";

import "../../Model/User/User.dart";


class CreateAccount extends StatefulWidget {

  @override
  State<CreateAccount> createState() => _CreateAccountState();
}

class _CreateAccountState extends State<CreateAccount> {
  TextEditingController edit_name = new TextEditingController();

  TextEditingController edit_email = new TextEditingController();

  TextEditingController edit_password = new TextEditingController();

  TextEditingController edit_confirm_password = new TextEditingController();

  String imgPath ="";

  FocusNode name= new FocusNode(), email= new FocusNode(), pass= new FocusNode(), conf_pass = new FocusNode();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Criar Conta")),
      body: Padding(
        padding: const EdgeInsets.only(right: 20,left: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            SizedBox(
              height: 30,
            ),

            SizedBox(
              height: 20,
            ),
            Container(
              height: 45,
              child: TextField(
                onTap: (){
                  setState(() {
                    name.requestFocus();
                    email.unfocus();
                    pass.unfocus();
                    conf_pass.unfocus();
                  });
                },
                onTapOutside: (tap){
                  setState(() {
                    name.unfocus();
                    email.unfocus();
                    pass.unfocus();
                    conf_pass.unfocus();
                  });
                },
                focusNode: name,
                decoration: InputDecoration(
                    label: Text("Nome"),
                    prefixIcon: Icon(Icons.person, color: name.hasFocus ? Colors.blue : Color.fromRGBO(219, 219, 229, 100)),
                    border: OutlineInputBorder(
      borderSide: BorderSide(color: Colors.red)
                    )),
                controller: edit_name,

              ),
            ),
            SizedBox(
              height: 10,
            ),
            Container(
              height: 45,
              child: TextField(
                focusNode: email,
                onTap: (){
                  setState(() {
                    name.unfocus();
                    email.requestFocus();
                    pass.unfocus();
                    conf_pass.unfocus();
                  });
                },
                onTapOutside: (tap){
                  setState(() {
                    name.unfocus();
                    email.unfocus();
                    pass.unfocus();
                    conf_pass.unfocus();
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
                    name.unfocus();
                    email.unfocus();
                    pass.requestFocus();
                    conf_pass.unfocus();
                  });
                },
                onTapOutside: (tap){
                  setState(() {
                    name.unfocus();
                    email.unfocus();
                    pass.unfocus();
                    conf_pass.unfocus();
                  });
                },
                decoration: InputDecoration(
                    label: Text("Password"),
                    prefixIcon: Icon(Icons.lock,color: pass.hasFocus ? Colors.blue : Color.fromRGBO(219, 219, 229, 100)),
                    border: OutlineInputBorder(

                    )),
                keyboardType: TextInputType.text,
                controller: edit_password,
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Container(
              height: 45,
              child: TextField(
                focusNode: conf_pass,
                onTap: (){
                  setState(() {
                    name.unfocus();
                    email.unfocus();
                    pass.unfocus();
                    conf_pass.requestFocus();
                  });
                },
                onTapOutside: (tap){
                  setState(() {
                    name.unfocus();
                    email.unfocus();
                    pass.unfocus();
                    conf_pass.unfocus();
                  });
                },
                decoration: InputDecoration(
                    label: Text("Confirmar Password"),
                    prefixIcon: Icon(Icons.lock,color: conf_pass.hasFocus ? Colors.blue : Color.fromRGBO(219, 219, 229, 100)),
                    border: OutlineInputBorder(

                    )),
                controller: edit_confirm_password,
              ),
            ),

            SizedBox(
              height: 5,
            ),

            Container(
              width: MediaQuery.of(context).size.width,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white
                ),
                onPressed: ()async{

                    List<Media>? res = await ImagesPicker.pick(
                      count: 1,
                      pickType: PickType.image,
                    );
                    if(File(res!.last.path).existsSync()){
    setState(() {     imgPath = res.last.path;
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Imagem Perfil Guardada !")));
    });   }



                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.account_box, color: Colors.blue,),
                    SizedBox(
                      width: 10,
                    ),
                    Text("Imagem Perfil",style: TextStyle(color: Colors.blue),),
                    SizedBox(
                      width: 10,
                    ),
               imgPath.isEmpty ? Container():     Icon(Icons.done, color: Colors.green,)
                  ],
                ),
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Padding(
              padding: EdgeInsets.only(top: 10),
              child: Container(
                width: MediaQuery.of(context).size.width,
                child: ElevatedButton(onPressed: ()async{

                  if(edit_name.text!="" && edit_email.text!="" && edit_password.text!="" && edit_confirm_password.text!="" && (edit_password.text==edit_confirm_password.text) && imgPath.isNotEmpty){
                    var resultado = await http.post(Uri.parse(Config.ipadress+"/api/createUser"),body: {
                      "name":edit_name.text,
                      "email": edit_email.text,
                      "password": edit_password.text,
                    });
                    print("RES: ${resultado.body}");
                    var resultado_json = jsonDecode(resultado.body);
                    var request = http.MultipartRequest('POST', Uri.parse(Config.ipadress+"/api/uploadfile"));

                    request.fields["type"]="profile";
                    request.fields["idprofile"]= resultado_json["id"].toString();

                    request.files.add(
                        http.MultipartFile(
                            'file',
                            File(imgPath).readAsBytes().asStream(),
                            File(imgPath).lengthSync(),
                            filename: "profile"+".png"
                        )
                    );
                    http.StreamedResponse res = await request.send();

                    print("RESf: ${res.statusCode} - ${resultado_json["id"]}");


                    if(resultado_json["response"]=="Sucesso" && res.statusCode==200){

                      final preferences = await SharedPreferences.getInstance();

                      preferences.setInt("id", resultado_json["id"]);
                      preferences.setString("name", edit_name.text);
                      preferences.setString("email", edit_email.text);
                      preferences.setString("action", "low");

                      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=> Account(resultado_json["id"], true, -1)));
                    }

                  }else{
                    String error ="";
                    if(edit_name.text==""){
                      error = "Nome";
                    }

                    if(edit_email.text==""){
                      error = "Email";
                    }


                    if(edit_password.text==""){
                      error = "Password";
                    }



                    if(edit_password.text!=edit_confirm_password.text){
                      error = "passwords não são iguais !";
                    }

                    if(imgPath.isEmpty){
                      error = "Imagem Perfil";
                    }
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Erro: "+error)));
                  }

                }, child: Text("Guardar")),
              ),
            ),
            SizedBox(
              height: 10,
            ),

            Center(child: GestureDetector(
                onTap: () {
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=> SignIn()));
                },
                child: Text("Já tenho conta !")))

          ],
        ),
      ),
    );
  }
}