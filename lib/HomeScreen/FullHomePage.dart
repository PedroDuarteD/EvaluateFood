import 'dart:convert';

import 'package:evaluatefood/HomeScreen/HomeScreen.dart';
import 'package:evaluatefood/Model/Receita/Ingredient.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:http/http.dart' as http;

import '../Config/appConfig.dart';
class Settings extends StatefulWidget {
  Function update;

  Settings(this.update);

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {

  Future<List<Ingredient>> CarregarIngredientes()  async {
    if(HomeScreen.ingredients.isEmpty){


    var response = await http
        .get(Uri.parse(Config.ipadress+"/api/list_ingrediente"));

    for (var ingrediente in jsonDecode(response.body)) {
     HomeScreen.ingredients.add(Ingredient(ingrediente["id"], ingrediente["nome"]));
    } }
    return  HomeScreen.ingredients;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(

     width: 100.w,
      height: 100.h,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: EdgeInsets.only(right: 10,left: 10, top: 20, bottom: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Procura por:"),
                  SizedBox(
                    height: 10,
                  ),
                  Text("Nome",style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 20),),
                  SizedBox(
                    height: 5,
                  ),
                  Container(
                      child: TextField(
                        controller: HomeScreen.name,
                        decoration: InputDecoration(

                            border: OutlineInputBorder()
                        ),

                      )),
                  SizedBox(
                    height: 20,
                  ),
                  Text("Categoria",style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 20),),
                  SizedBox(
                    height: 5,
                  ),

                DropdownButton(
                    value: HomeScreen.cat,
                    items: [
                      DropdownMenuItem(child: Text("Categoria"),value: 0,),
                      DropdownMenuItem(child: Text("Sopa"),value: 1,),

                      DropdownMenuItem(child: Text("Prato"),value: 2,),
                      DropdownMenuItem(child: Text("Sobremesa"),value: 3,)],

                    onChanged: (v){
setState(() {
  HomeScreen.cat = v!;
});
                }), SizedBox(
                    height: 20,
                  ),
                  Text("Ingredientes",style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 20),),
                  SizedBox(
                    height: 5,
                  ),

                  FutureBuilder<List<Ingredient>>(
                      future: CarregarIngredientes(),
                      builder: (_, snapshot){
                        if(snapshot.connectionState==ConnectionState.done || snapshot.connectionState==ConnectionState.active){
                          if(snapshot.requireData.isEmpty){
                            return Center(
                              child: Text("Sem ingredientes !"),
                            );
                          }else{
                        return RenderIngre(snapshot.requireData);
                          }
                        }else{
                          return CircularProgressIndicator();
                        }
                      })

                ],
              ),
            ),

            Container(
              width: 100.w,
              child: ElevatedButton(
                onPressed: (){
                  widget.update();
                },
                child: Text("Procurar"),
              ),
            )

          ],
        ),
      ),
    );
  }
}


class RenderIngre extends StatefulWidget {
  List<Ingredient> ings;
  RenderIngre(this.ings);

  @override
  State<RenderIngre> createState() => _RenderIngreState();
}

class _RenderIngreState extends State<RenderIngre> {
  @override
  Widget build(BuildContext context) {
         return SizedBox(
      height: 300,
      child: ListView.builder(
          shrinkWrap: true,
          itemCount: widget.ings.length,
          itemBuilder: (_, position){
            Ingredient ing = widget.ings[position];
            return   Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(ing.name),
                Spacer(),
                Checkbox(value: ing.active, onChanged: (v){
                  setState(() {
                    HomeScreen.ingredients[HomeScreen.ingredients.indexOf(ing)].active = v!;
                  });

                })
              ],
            );
          }
      ),
    );;
  }
}
