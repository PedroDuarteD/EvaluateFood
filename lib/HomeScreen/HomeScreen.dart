import 'dart:convert';
import 'package:evaluatefood/Create/Account/Favorite/MyFavorite.dart';
import 'package:evaluatefood/HomeScreen/FullHomePage.dart';
import 'package:evaluatefood/Model/Receita/Ingredient.dart';
import 'package:evaluatefood/Model/Receita/Tag.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import 'package:evaluatefood/Account/Account.dart';
import 'package:evaluatefood/Config/appConfig.dart';
import 'package:evaluatefood/Create/Account/index.dart';
import 'package:evaluatefood/HomeScreen/RecipeRequirements.dart';
import 'package:evaluatefood/Model/Receita/Recipe.dart';
import 'package:evaluatefood/Providers/UpdateRecipeSelect.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import 'TrailerRecipe.dart';

class HomeScreen extends StatefulWidget {
  int  myID = -1;
  static TextEditingController name = TextEditingController();
  static int cat = 0;
  static List<Ingredient> ingredients = [
  ];

  HomeScreen(this.myID);
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
 String nome_receita="";

 int pagina_atual = 0;

 ScrollController scrollController = new ScrollController();

 PageController pageController = new PageController(initialPage: 0);



late Recipe selectRecipe;

 Future<List<Recipe>> getAllRecipes()async{

   List<Recipe> list = [];
var pref = await SharedPreferences.getInstance();
String selectedIng="";
for(var item in HomeScreen.ingredients){
  if(item.active){
    selectedIng+=item.name+",";

  }
}
if(selectedIng.isNotEmpty){
  selectedIng = selectedIng.substring(0, selectedIng.length-1);

}

   var allRecipes = await http.get(Uri.parse("${Config.ipadress}/api/getAllRecipes${pref.containsKey("id")? "?idUser=${pref.getInt("id").toString()}" : ""}${HomeScreen.name.text.isEmpty? '':'${pref.containsKey("id")? '&':''}nameRecipe=${HomeScreen.name.text}'}${HomeScreen.cat!=0 && (pref.containsKey("id") || HomeScreen.name.text.isNotEmpty) ? '&' : ''}${HomeScreen.cat!=0? 'cat=${HomeScreen.cat}':''}${ HomeScreen.ingredients.isNotEmpty && (pref.containsKey("id") || HomeScreen.name.text.isNotEmpty || HomeScreen.cat!=0 && HomeScreen.ingredients.isNotEmpty) ? '&' : ''}${HomeScreen.ingredients.isEmpty? '':'ing=$selectedIng'}"));
   print("${Config.ipadress}/api/getAllRecipes${pref.containsKey("id")? "?idUser=${pref.getInt("id").toString()}" : ""}${HomeScreen.name.text.isEmpty? '':'${pref.containsKey("id")? '&':''}nameRecipe=${HomeScreen.name.text}'}${HomeScreen.cat!=0 && (pref.containsKey("id") || HomeScreen.name.text.isNotEmpty) ? '&' : ''}${HomeScreen.cat!=0? 'cat=${HomeScreen.cat}':''}${ HomeScreen.ingredients.isNotEmpty && (pref.containsKey("id") || HomeScreen.name.text.isNotEmpty || HomeScreen.cat!=0) ? '&' : ''}${HomeScreen.ingredients.isEmpty? '':'ing=$selectedIng'}");

   for(var recipe in jsonDecode(allRecipes.body)){

     List<Tag> tags = [];
     for(var item in recipe["tags"]){
       tags.add(new Tag(item["tag"]));
     }

       list.add(new Recipe(recipe["id"],recipe["idUser"], recipe["name"],recipe["desc"], true, recipe["comments"]==0? true: false, recipe["edit_steps"]==0? true:false,recipe["likes"], recipe["like"], tags));

   }
   if(list.isNotEmpty){
      Recipe recipeFirst = list.first;
      selectRecipe = list.first;
   context.read<UpdateRecipeSelect>().setNameOfRecipe(recipeFirst.name);
   context.read<UpdateRecipeSelect>().setIdofRecipe(recipeFirst.id);
   }


   return list;
 }

 int positionnavBottom = 0;



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Consumer<UpdateRecipeSelect>(
          builder: (_, recipeSelect, child){
            return Text("Evaluate Food ");
          } ),
      actions: [

        widget.myID!=-1 ?  IconButton(onPressed: ()async{
Navigator.push(context, MaterialPageRoute(builder: (_) => MyFavoriteRecipes(widget.myID)));
        }, icon: Icon(Icons.favorite, color: Colors.white,)) : Container(),

        IconButton(onPressed: ()async{
        //  flickManager.flickControlManager!.pause();
          final account = await SharedPreferences.getInstance();

          if(account.containsKey("id")){
             Navigator.push(context, MaterialPageRoute(builder: (context)=> Account(

             account.getInt("id")!, true, -1)))
             ;

          }else{
             Navigator.push(context, MaterialPageRoute(builder: (context)=> CreateAccount(

             )));

          }
        }, icon: Icon(Icons.person))
      ],),
      body: FutureBuilder<List<Recipe>>(
        future: getAllRecipes(),
        builder: (_, snapshot){
          if(snapshot.connectionState==ConnectionState.done || snapshot.connectionState==ConnectionState.active){


            if(snapshot.hasData && snapshot.data!.length>0){

              return PageView(

                children: [
                  PageView.builder(
                      itemCount: snapshot.data!.length,
                      scrollDirection: Axis.vertical,
                      controller: pageController ,
                      onPageChanged: (page){
                        Recipe recipe = snapshot.data![page];
                        pagina_atual = page;
                        context.read<UpdateRecipeSelect>().setNameOfRecipe(recipe.name);
                        context.read<UpdateRecipeSelect>().setIdofRecipe(recipe.id);
                        selectRecipe = recipe;
                      },
                      itemBuilder: (_, position){

                        Recipe recipe = snapshot.data![position];


                        return GestureDetector(
                            onTap: (){
                              showModalBottomSheet(context: context, builder: (context){
                                return RecipeRequirements(selectRecipe.idUser,selectRecipe.id, selectRecipe.name, selectRecipe.comments, selectRecipe.edit_steps , selectRecipe.likeRecipe);
                              });
                            },
                            child:  RecipeTrailerState(recipe));
                      })
                ,  Settings((){
                    setState(() {

                    });
                  })
                ],
              );
            }else{
              return PageView(
               children: [
                 Center(
                   child: Text("Nenhuma receita encontrada !"),
                 ) ,  Settings((){
                   setState(() {

                   });
                 })
               ],
              );
            }
          }else{
            return Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),



       );
  }
}