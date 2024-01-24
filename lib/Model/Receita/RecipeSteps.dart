import 'package:evaluatefood/Model/Receita/RecipeIngredient.dart';

class RecipeSteps  {

  List<RecipeIngredientModel> frase = [

  ];
 
  bool select = false;
  
  int  original=0;

  bool obrigatorio = true;
  //0 normal
  //1 step original
  //2 step modificado

  RecipeSteps.Card(this.id, this.original, this.obrigatorio);
  RecipeSteps(this.id, this.frase, this.original, this.obrigatorio);

  @override
  int id;

  @override
  RecipeSteps getRecipeStep() {
    // TODO: implement getRecipeStep
    throw UnimplementedError();
  }

  @override
  setRecipeStep(RecipeSteps r) {
    // TODO: implement setRecipeStep
    throw UnimplementedError();
  }



}