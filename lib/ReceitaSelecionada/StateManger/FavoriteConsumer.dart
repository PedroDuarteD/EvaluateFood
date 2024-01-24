import 'package:flutter/material.dart';

class FavoriteCosumer extends ChangeNotifier{
  bool _favorite = false;

  setFavorite(bool value){
    this._favorite = value;
    notifyListeners();
  }

  bool getFavorite(){
    return this._favorite;
  }
}