import 'package:evaluatefood/Model/Receita/RecipeIngredient.dart';
import 'package:evaluatefood/Model/Receita/RecipeStepTimeout.dart';
import '../Model/Receita/RecipeSteps.dart';

class Config{

 static double version = 0.3;

  static String ipadress = "https://evaluatefood.pedroduarte.online";
 //;"http://192.168.1.99"

  static List<RecipeSteps> listStepEdit = [];

 static List<RecipeStepTimeout> list_recipe_Step_Timeout = [];
 static List<RecipeStepTimeout> list_recipe_Step_TimeoutSelect = [];


  static List<RecipeSteps> listStepsofRecipe = [];

  static List<RecipeIngredientModel> ConvertStringStepToListIngredients(int idStep,String frase){
  List<RecipeIngredientModel> list_Ingredients = [];
  int posicaoNaLista =0;


  if(frase.contains("<-->")){
    frase = frase.split("<-->")[1];
  }

  for(var word in frase.split(" ")){
    if(word.startsWith("?ID") && word.endsWith("?")){

      int idIngredient = int.parse( word.split("*")[0].replaceAll("?ID", ""));
      String name =  word.split("*")[1];
      int amount = int.parse( word.split("*")[2]);
      String measure =word.split("*")[3].replaceAll("?", "");
      list_Ingredients.add(RecipeIngredientModel.Ingredient(idStep, posicaoNaLista, idIngredient, amount,measure, name));

    }else if(word.startsWith("TOUT") && word.endsWith("TOUT")){

        }
    else{
      list_Ingredients.add(RecipeIngredientModel.Word(idStep, word+" "));

    }

    posicaoNaLista+=1;
  }

  list_Ingredients.last.name.replaceAll(" ", "");

  return list_Ingredients;
}
}