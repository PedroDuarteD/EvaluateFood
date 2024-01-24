import 'package:evaluatefood/Model/Receita/RecipeIngredient.dart';
import 'package:evaluatefood/Model/Receita/RecipeSteps.dart';

import 'RecipeStepsComment.dart';

class Comment{
  int id = -1, view=0;
  int like=0, dislike=0;
  int idUser=-1, alreadySelected = -1;
  List<CommentStepState> recipeSteps;
  List<CommentIngredientState> ingredients;
 
  String name="", message="";

  Comment(this.id, this.idUser, this.name, this.message, this.alreadySelected,this.like, this.dislike, this.view,this.recipeSteps, this.ingredients);
}


class CommentDetail{
   int id = -1, view=0;


  int idUser=-1;
  String  message="";

  List<RecipeStepsComment> recipeSteps;

  CommentDetail(this.id, this.view, this.idUser,this.message, this.recipeSteps);
}

class CommentStepState{
  int id=0, state=0;
  CommentStepState(this.id, this.state);
}


class CommentIngredientState{
  int id=0;
  String name="";
  CommentIngredientState(this.id, this.name);
}