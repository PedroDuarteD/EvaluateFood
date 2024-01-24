import 'dart:convert';
import 'package:evaluatefood/HomeScreen/Refractor.dart';
import 'package:flutter/material.dart';
import 'package:evaluatefood/Model/Receita/RecipeIngredient.dart';
import 'package:evaluatefood/ReceitaSelecionada/index.dart';
import 'package:http/http.dart' as http;
import 'package:evaluatefood/Config/appConfig.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RecipeRequirements extends StatelessWidget {

  int idofUser= -1,idofRecipe=-1;
  String nameRecipe="";
  bool comments = false, edit_steps = false, favorite= false;
  RecipeRequirements(this.idofUser,this.idofRecipe, this.nameRecipe, this.comments, this.edit_steps, this.favorite);

  int amountMax = 0;

  Future<List<RecipeIngredientModel>> LoadAllRecipeIngredient()async{


  List<RecipeIngredientModel> list = [];
print("ID recipe ${this.idofRecipe}");
  var response = await http.get(Uri.parse("${Config.ipadress}/api/ListAllIngredient/"+this.idofRecipe.toString()));
  var response_convert = jsonDecode(response.body);

  for(var ingredient in response_convert["ingredients"]){
      RecipeIngredientModel recipeIngredientModel =  RecipeIngredientModel.IngredientPreview(ingredient["id"], ingredient["amount"],"N", ingredient["name"]);
      amountMax+=  recipeIngredientModel.amount;
      list.add(recipeIngredientModel);
  }
  return list;
} 

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<RecipeIngredientModel>>(
    future: LoadAllRecipeIngredient(),
    builder: (context, snapshot) {
        if(snapshot.connectionState==ConnectionState.active|| snapshot.connectionState==ConnectionState.done){
           if(snapshot.data!.isEmpty){
      return Center(
        child: Text("Sem Ingredientes !"),
      );
    }else{
        return  Column(
        children: [
    
      Container(
      height: 400,
      
      child: DataTable(
        columns: [
      DataColumn(label: Text("Nome")),
      DataColumn(label: Text("Quantidade")),
      DataColumn(label: Text("%")),
        ], rows: snapshot.data!.map<DataRow>((e) {
  return DataRow(cells: [
        DataCell(  Text(e.name)),
        
            DataCell(  Text(e.amount.toString())),
            DataCell(  Text(((e.amount*100)/amountMax ).toInt().toString())),
      ]);
        }).toList(),
         
      ),
      ),
    
     
      
      ElevatedButton(onPressed: ()async{
        var preferences = await SharedPreferences.getInstance();
        if(preferences.containsKey("id")){
          Navigator.push(context, MaterialPageRoute(builder: (context)=> ReceitaSelecionada(preferences.getInt("id")!,this.idofUser.toString(),this.idofRecipe.toString(),this.nameRecipe, this.comments, this.edit_steps, this.favorite)));

        }else{
          Navigator.push(context, MaterialPageRoute(builder: (context)=> ReceitaSelecionada(-1,this.idofUser.toString(),this.idofRecipe.toString(),this.nameRecipe, this.comments, this.edit_steps, this.favorite)));

        }


        
      }, child: Text("Cozinhar"))
        
    
         
        ],
      );
    }
        }else{
          return Center(
            child: CircularProgressIndicator(),
          );
        }
    },
    );
  }
}