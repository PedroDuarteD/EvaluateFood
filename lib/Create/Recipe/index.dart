import "dart:convert";
import "package:evaluatefood/Create/Recipe/RecipeCountry.dart";
import "package:evaluatefood/Create/Recipe/RecipeTags.dart";
import "package:flutter/material.dart";
import "package:images_picker/images_picker.dart";
import "package:evaluatefood/Config/appConfig.dart";
import "package:evaluatefood/Create/Recipe/IngredientController.dart";
import "package:evaluatefood/Create/Recipe/Receita.dart";
import "package:evaluatefood/Create/Recipe/RecipeFinish.dart";
import 'package:evaluatefood/Create/Recipe/RecipeIngredientTree/RecipeIngredient.dart';
import "package:evaluatefood/Create/Recipe/RecipeMultimidia.dart";
import "package:evaluatefood/Model/User/User.dart";
import 'package:http/http.dart' as http;
import "../../Model/Receita/Country.dart";
import "../../Model/Receita/RecipeStepTimeout.dart";
import "../../Model/Receita/RecipeSteps.dart";

class CreateReceita extends StatefulWidget {

  int recipeID =-1;

  late int idUser;

  List<RecipeSteps> allSteps =[];

  CreateReceita({required int user,int recipeId=-1 }){
    this.idUser = user;
    this.recipeID = recipeId;
  }

 static List<Media> trailer = [];
 static List<Media> ensinar = [];

 static var sop_selected = 0;
  static List<Country> countries = [
    Country(1, "Portugal", true),
    Country(2, "Espanha", false),
  ];
 static TextEditingController edit_people = new TextEditingController();
 static TextEditingController edit_name = new TextEditingController();
  static TextEditingController edit_description = new TextEditingController();
  static  List tags = [];

 
 static  List<RecipeSteps> lista_passos = [];


  @override
  State<CreateReceita> createState() => _CreateReceitaState();
}

class _CreateReceitaState extends State<CreateReceita> {

  Future GetDataFromRecipe()async{
    if(widget.recipeID!=-1){
    var dataFromRecipe =await  http.get(Uri.parse("${Config.ipadress}/api/getRecipe/${widget.recipeID}"));

    var convert = jsonDecode(dataFromRecipe.body);



     CreateReceita.edit_people.text =  convert["people"].toString();
     CreateReceita.sop_selected = int.parse( convert["category"].toString());
    CreateReceita.edit_name.text = convert["name"].toString();
    CreateReceita.edit_description.text = convert["description"].toString();


    CreateReceita.lista_passos.clear();
      for(var step in convert["steps"]){

     CreateReceita.lista_passos.add(new RecipeSteps(CreateReceita.lista_passos.length, Config.ConvertStringStepToListIngredients(step["id"], step["step"]), 0, step["required"]==1 ? true : false));


      if(step["step"].toString().contains("TOUT") ){
        var timeout = step["step"].toString().split(" ")[0].replaceAll("TOUT", "").split(":");

        if((int.parse(timeout[0])+1)==(CreateReceita.lista_passos.length)){
          Config.list_recipe_Step_Timeout.add( new RecipeStepTimeout( Config.list_recipe_Step_Timeout.isEmpty? Config.list_recipe_Step_Timeout.length : Config.list_recipe_Step_Timeout.length+1,(int.parse(timeout[0])),timeout[3].toString(), int.parse(timeout[1].toString()), int.parse(timeout[2].toString()) ));

        }
         }
      }

    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Criar Receita")),

      body: FutureBuilder(
        future: GetDataFromRecipe(),
        builder: (_, snaptshot){
          if(snaptshot.connectionState==ConnectionState.done || snaptshot.connectionState==ConnectionState.active){
           return PageView(
                children: [
                  ReceitaApresentacao(),
                  RecipeTags(),
              //    RecipeCountry(),
                  RecipeMultimidia(widget.recipeID),
                  RecipeIngredient(widget.recipeID),
                  RecipeFinish(widget.recipeID)
                ]);
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