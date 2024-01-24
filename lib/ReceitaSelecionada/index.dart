import 'dart:convert';

import 'package:evaluatefood/Account/Flag/index.dart';
import 'package:evaluatefood/Config/appConfig.dart';
import 'package:evaluatefood/ReceitaSelecionada/StateManger/FavoriteConsumer.dart';
import 'package:flutter/material.dart';
import 'package:evaluatefood/ReceitaSelecionada/ReceitaComunidade.dart';
import 'package:evaluatefood/ReceitaSelecionada/ReceitaSelecionada.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ReceitaSelecionada extends StatefulWidget {
int myIdUser = -1;
String idUser="", idRecipe="", nameRecipe="";
bool comments = false, edit_Steps=false, favorite=false;
  ReceitaSelecionada(this.myIdUser,this.idUser,this.idRecipe, this.nameRecipe, this.comments, this.edit_Steps, this.favorite);

  @override
  State<ReceitaSelecionada> createState() => _ReceitaSelecionadaState();
}

class _ReceitaSelecionadaState extends State<ReceitaSelecionada> with TickerProviderStateMixin{

 late TabController tabController;

 Color favoriteColor = Colors.white;


 @override
 void initState(){
  super.initState();
  if(widget.favorite){
    Future.delayed(Duration(microseconds: 300), (){
      context.read<FavoriteCosumer>().setFavorite(true);

    });
  }

  tabController = TabController(length: widget.comments? 2 : 1, vsync: this,initialIndex: 0);
 }

 @override
 void dispose(){
  tabController.dispose();  
  super.dispose();
 }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text("${widget.nameRecipe}"),
          actions: [
          widget.myIdUser.toString()!=widget.idUser?  ElevatedButton(onPressed: (){

                Navigator.push(context, MaterialPageRoute(builder: (_) => AccountFlag(int.parse(widget.idUser), int.parse(widget.idRecipe))));
            }, child: Icon( Icons.flag,color: Colors.yellow,)) : Container(),
            widget.myIdUser.toString()!=widget.idUser?    IconButton(onPressed: ()async{
              final preferences = await SharedPreferences.getInstance();
              if(preferences.containsKey("id")){
                var favorite = await http.post(Uri.parse("${Config.ipadress}/api/likerecipe_create"), body: {
                "idrecipe" : widget.idRecipe,
                "iduser" : preferences.getInt("id").toString(),
                });
                print("code: ${favorite.body}  co2: ${favorite.statusCode}");
                if(jsonDecode(favorite.body)["ans"]=="Success"){
                  if(jsonDecode(favorite.body)["sms"]=="add"){
                    context.read<FavoriteCosumer>().setFavorite(true);

                  }else{
                    context.read<FavoriteCosumer>().setFavorite(false);

                  }
                }
              }else if(!preferences.containsKey("id")){
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Tens de criar conta !")));
              }

            }, icon: Consumer<FavoriteCosumer>(
              builder: (_, value, child){
                return Icon( Icons.favorite, color: value.getFavorite()? Colors.red:Colors.white,);
              },
            )): Container(),
          ],
          bottom: TabBar(
          controller: tabController,
          onTap: (value) {
            setState(() {
              tabController.animateTo(value);
            });
          },
          tabs: 
          widget.comments? 
          [
              Tab(text: "Cozinha",),
              Tab(text: "Comunidade",),
            ] : [
                Tab(text: "Cozinha",),
            ]
            ),),
        body: 
        
        TabBarView(
          controller: tabController,
          children: widget.comments?[

           ReceitaCozinhar(widget.idRecipe),
             ReceitaComunidade(widget.idRecipe, widget.nameRecipe, widget.edit_Steps)
        ]: [

           ReceitaCozinhar(widget.idRecipe),
        ])  ,
      ),
    );
  }
}