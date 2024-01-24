import 'RecipeIngredient.dart';

class RecipeStepsComment{
  int index=-1;
  int idStep=-1;

  int like=0, dislike=0;
  int modified= -1;
  int already = -1;

  List<RecipeIngredientModel> now = [];

  List<RecipeIngredientModel> before = [];


  RecipeStepsComment(this.index,this.now, this.before, this.idStep,this.modified, this.like, this.dislike, this.already);
}