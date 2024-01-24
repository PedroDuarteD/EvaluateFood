import 'package:evaluatefood/Model/Receita/Recipe.dart';
import 'package:evaluatefood/Model/Receita/RecipeComments.dart';
import 'package:evaluatefood/Model/User/User.dart';

class RecipeUsers{
  int id=-1;
  
  late Recipe recipe;
  late User user;

  bool like = true;

  late Comment comment;
}