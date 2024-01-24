import 'package:flutter/material.dart';

class FinishCreating extends ChangeNotifier{
  bool _processing = false;

  setProcess(bool value){
    this._processing = value;
    notifyListeners();
  }

  bool getProcess(){
    return this._processing;
  }

}