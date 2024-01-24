import 'dart:convert';
import 'package:flick_video_player/flick_video_player.dart';
import 'package:evaluatefood/Config/appConfig.dart';
import 'package:evaluatefood/Model/Receita/Recipe.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:video_player/video_player.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';

class MyFavoriteRecipes extends StatefulWidget {

  int myID=-1;
  MyFavoriteRecipes(this.myID);

  @override
  State<MyFavoriteRecipes> createState() => _MyFavoriteRecipesState();
}

class _MyFavoriteRecipesState extends State<MyFavoriteRecipes> {
  
  Future<List<Recipe>> loadFavoriteRecipes()async{
    List<Recipe> recipes = [];
    var pref = await SharedPreferences.getInstance();
    var allRecipes = await http.get(Uri.parse("${Config.ipadress}/api/likerecipe_list?iduser=${pref.getInt("id").toString()}"));

    for(var recipe in jsonDecode(allRecipes.body)){
      recipes.add(Recipe.Favorite(recipe["id_recipe"], recipe["id_user"], recipe["name"], recipe["desc"]));
    }

return recipes;
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
          Text("Receitas favoritas") ,
      Icon(Icons.favorite, color: Colors.blue,)
      ],
    ),
      ),
      body: Column(
        children: [
          SizedBox(
            height: 10,
          ),
          
          FutureBuilder<List<Recipe>>(
            future: loadFavoriteRecipes(),
            builder: (_, snapshot){
              if(snapshot.connectionState==ConnectionState.done || snapshot.connectionState==ConnectionState.active){
                if(snapshot.requireData.isNotEmpty){
                 return ListView(
                    shrinkWrap: true,
                    padding: EdgeInsets.only(right: 15, left: 15),
                    children: snapshot.data!.map<Widget>((e) {
                     return Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(17)
                        ),
                        child: Container(
                          width: 45.w,
                          height: 250,
                          padding: EdgeInsets.only(left: 20),
                          decoration: BoxDecoration(
                              color: Color.fromRGBO(217, 217, 217, .20),
                              borderRadius: BorderRadius.only(topRight: Radius.circular(17), bottomRight: Radius.circular(17))
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                height: 20,
                              ),
                              Center(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(60),
                                  child: Container(
                                    width: 80,
                                    height: 80,
                                    child: Image.network("${Config.ipadress}/uploads/profiles/${e.idUser}/profile.png",
                                    width: 80,
                                    height: 80,
                                    fit: BoxFit.cover,
                                    loadingBuilder: (_, child, progress){
                                      if(progress==null) return child;

                                      return Center(
                                        child: CircularProgressIndicator(),
                                      );
                                    },),
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 20,
                              ),
                              Text(e.name,style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),),
                              SizedBox(
                                height: 10,
                              ),
                              Text(e.description)
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  );
                }else{
                  return Center(
                    child: Text("Ainda não tem receitas !"),
                  );
                }
              }else{
                return Center(
                  child: CircularProgressIndicator(),
                );
              }
            }
          )
         

        ],
      ),
    );
  }
}

class ShowTrailer extends StatefulWidget {

  int idRecipe=-1;

  ShowTrailer(this.idRecipe);

  @override
  State<ShowTrailer> createState() => _ShowTrailerState();
}

class _ShowTrailerState extends State<ShowTrailer> {

  late FlickManager flickManager;
  @override
  void initState(){
    super.initState();

    flickManager  =  FlickManager(
        onVideoEnd: (){

        },
        autoPlay: true,
        autoInitialize: true,
        videoPlayerController: VideoPlayerController.networkUrl(Uri.parse("${Config.ipadress}/uploads/receita/${widget.idRecipe}/trailer.mp4")));

  }
  @override
  void dispose(){
    flickManager.dispose();

    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    print("flick: ${Config.ipadress}/uploads/receita/${widget.idRecipe}/ensinar.mp4");
    return  FlickVideoPlayer(flickManager: flickManager,);
  }
}

