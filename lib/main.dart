import 'package:evaluatefood/Create/Recipe/StateManager/FinishCreating.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:evaluatefood/Providers/UpdatePeopeofRecipe.dart';
import 'package:evaluatefood/splashScreen.dart';
import 'package:sizer/sizer.dart';
import 'Providers/UpdateRecipeSelect.dart';
import 'ReceitaSelecionada/StateManger/FavoriteConsumer.dart';

void main() async{

//WidgetsFlutterBinding.ensureInitialized();


// await  MobileAds.instance.initialize();
//var devices = ["3B0E2D1F08C779BA9880AB56DEC8AFC2"];testDeviceIds: devices

 //RequestConfiguration config = new RequestConfiguration();

// MobileAds.instance.updateRequestConfiguration(config);

  runApp( MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UpdateRecipeSelect()),
        ChangeNotifierProvider(create: (_) => PeopleOfRecipe()),
        ChangeNotifierProvider(create: (_) => FavoriteCosumer()),
        ChangeNotifierProvider(create: (_) => FinishCreating()),
      ],
      child:
      Sizer(
        builder: (_, ori, device){
          return MaterialApp(home: SplashScreen());
        }
      )
      ));
}

