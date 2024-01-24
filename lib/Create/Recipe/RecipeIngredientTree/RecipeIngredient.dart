import 'dart:convert';
import 'package:evaluatefood/Create/Recipe/RecipeIngredientTree/RecipeSteps.dart';
import 'package:flutter/material.dart';
import 'package:evaluatefood/Config/appConfig.dart';
import 'package:evaluatefood/Model/Receita/RecipeIngredient.dart';
import 'package:evaluatefood/Model/Receita/RecipeStepTimeout.dart';
import 'package:evaluatefood/Model/Receita/RecipeSteps.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:speech_to_text/speech_to_text.dart';

import '../../../Model/Receita/Ingredient.dart';
import '../../../ReceitaSelecionada/Community/AddOneStep.dart';

List<Ingredient> list_ingrediente = [];

class RecipeIngredient extends StatelessWidget {
  int RecipeID=-1;
    RecipeIngredient(this.RecipeID);

 Future<List<Ingredient>> CarregarIngredientes()  async {
list_ingrediente.clear();
    var response = await http
        .get(Uri.parse(Config.ipadress+"/api/list_ingrediente"));

    for (var ingrediente in jsonDecode(response.body)) {
      list_ingrediente.add(Ingredient(ingrediente["id"], ingrediente["nome"]));
    }
    return list_ingrediente;
  }

  TextEditingController edit_step = new TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        RenderWidgetRecipeEtapa(edit_step,list_ingrediente, RecipeID),

       

        FutureBuilder<List<Ingredient>>(
          future: CarregarIngredientes(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done ||
                snapshot.connectionState == ConnectionState.active) {

              return Container(
                width: MediaQuery.of(context).size.width-1,
                height: 35,
                margin: EdgeInsets.only(left: 20,right: 20,top: 10),
                child: ListView.builder(
                  shrinkWrap: true,
                  scrollDirection: Axis.horizontal,
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    Ingredient recipeIngredientModel =
                    snapshot.data![index];
                    return Material(
                      elevation: 2,
                      child: Container(
                        margin: EdgeInsets.only(right: 10),
                        child: TextButton(
                            onPressed: () {
                          
                          
                          if( edit_step.text!="" && edit_step.text.characters.last!=" "){
                      edit_step.text += " "+recipeIngredientModel.name;
                          }else{
                         edit_step.text += recipeIngredientModel.name;
                          }
                    
                                    edit_step.selection = TextSelection.fromPosition(TextPosition(offset: edit_step.text.length));
                            },
                            child: Text(recipeIngredientModel.name,style: TextStyle(color: Colors.black),)),
                      ),
                    );
                  },
                ),
              );
            } else {
              return Center(
                child: CircularProgressIndicator(),
              );
            }
          },
        ),
      ],
    );
 
  }
}




