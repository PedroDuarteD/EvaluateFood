import 'package:flutter/material.dart';

class UpdateRecipeSelect extends ChangeNotifier{

  int _idofRecipe = -1;
String _nameOfRecipe = "";

setNameOfRecipe(String name){
  this._nameOfRecipe = name;
  notifyListeners();
}

String getNameRecipe(){
return this._nameOfRecipe;
}

  setIdofRecipe(int id){
    this._idofRecipe = id;
    notifyListeners();
  }

  int getIDofRecipe(){
    return this._idofRecipe;
  }

}