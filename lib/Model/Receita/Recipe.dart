import 'package:evaluatefood/Model/Receita/RecipeSteps.dart';
import 'package:evaluatefood/Model/Receita/RecipeTypes.dart';

import 'Tag.dart';

class Recipe{
  late RecipeTypes recipeTypes;
  int id=0, idUser=-1, likes=0;
  String name="", description="";
  bool show = true, comments = false, edit_steps=false, likeRecipe= false;
  late List<RecipeSteps> recipeSteps;
  List<Tag> tags = [];
  Recipe(this.id, this.idUser,this.name,this.description, this.show ,this.comments, this.edit_steps, this.likes, this.likeRecipe, this.tags);

  Recipe.Favorite(this.id, this.idUser, this.name, this.description);
}