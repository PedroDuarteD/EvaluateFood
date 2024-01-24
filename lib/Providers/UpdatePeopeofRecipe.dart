import 'package:flutter/material.dart';

class PeopleOfRecipe extends ChangeNotifier{

  int people =0;

  setPeople(int people){
    this.people = people;
    notifyListeners();
  }

  int getPeople(){
    return this.people;
  }
}