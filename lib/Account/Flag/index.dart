import "dart:convert";

import "package:evaluatefood/Account/Flag/FlagModel.dart";
import "package:evaluatefood/Config/appConfig.dart";
import "package:flutter/material.dart";
import "package:http/http.dart" as http;
import "package:shared_preferences/shared_preferences.dart";

class AccountFlag extends StatefulWidget {
  int idUser=-1, idRecipe=-1;
   AccountFlag(this.idUser,this.idRecipe);

  @override
  State<AccountFlag> createState() => _AccountFlagState();
}

class _AccountFlagState extends State<AccountFlag> {
   List<FlagModel> flags = [
    FlagModel(1, "Denunciar Conta", false),
   ];

   @override
   void initState(){

    super.initState();
   if(widget.idRecipe!=-1){
     flags.add(FlagModel(2, "Denunciar Conteúdo", false));
     flags.add(FlagModel(3, "Burla", false));
     flags.add(FlagModel(4, "Assédio", false));
   }
   }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Denunciar"),
      ),
      body: Column(
        children: [
          ListView(
            shrinkWrap: true,
            children: flags.map((e) {
              return  Container(
                child: Row(children: [
                  Checkbox(value: e.status, onChanged: (value){
                      setState(() {
                      flags.elementAt(flags.indexOf(e)).status= value!;  
                      });
                  }),
                  Text(e.text)
                ]),
              );
            }).toList(),
          ),

          ElevatedButton(onPressed: ()async{
           String reason ="";
              for(var item in flags){
                if(item.status){
               reason+=item.id.toString()+",";
                }
              }
            reason=  reason.substring(0, reason.length-1);
              if(reason.isNotEmpty){
                  final preferences = await SharedPreferences.getInstance();
                var request = await http.post(Uri.parse("${Config.ipadress}/api/flag_acountRecipe"),body: {
                  "iduser" : preferences.getInt("id").toString() ,
                  "iduserProfile" :  widget.idUser.toString()  ,
                  "idRecipe" : widget.idRecipe.toString(),
                  "idReason" : reason
                });

                if(request.statusCode==200 && jsonDecode(request.body)["res"]=="Success"){
                  Navigator.pop(context);
                }
              }

  
             
          }, child: Text("Enviar"))
        ],
      ),
    );
  }
}