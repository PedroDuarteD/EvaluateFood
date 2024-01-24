import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:evaluatefood/Config/appConfig.dart';
import 'package:evaluatefood/Create/Recipe/index.dart';
import 'package:evaluatefood/Model/Receita/RecipeIngredient.dart';
import 'package:evaluatefood/Model/Receita/RecipeSteps.dart';
import 'package:http/http.dart' as http;
import 'package:sizer/sizer.dart';
import '../../Model/Receita/Ingredient.dart';







class AddOneStep extends StatelessWidget {


    List<Ingredient> list_ingrediente = [];

 Future<List<Ingredient>> CarregarIngredientes()  async {
list_ingrediente.clear();
    var response = await http
        .get(Uri.parse(Config.ipadress+"/api/list_ingrediente"));

    for (var ingrediente in jsonDecode(response.body)) {
      list_ingrediente.add(Ingredient(ingrediente["id"],ingrediente["nome"]));
    }
    return list_ingrediente;
  }




  TextEditingController edit_step = new TextEditingController();


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Adicionar Etapa")),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          RecipeEtapa(edit_step,list_ingrediente),
    
         
    
          FutureBuilder<List<Ingredient>>(
            future: CarregarIngredientes(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done ||
                  snapshot.connectionState == ConnectionState.active) {
    
                return Container(
                  width: MediaQuery.of(context).size.width-1,
                  height: 35,
                  margin: EdgeInsets.only(left: 20,right: 20,top: 10),
                  child: ListView.builder(
                    shrinkWrap: true,
                    scrollDirection: Axis.horizontal,
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      Ingredient recipeIngredientModel =
                      snapshot.data![index];
                      return Container(
                        margin: EdgeInsets.only(right: 10),
                        child: TextButton(
                            onPressed: () {
                          
                          
                          if( edit_step.text!="" && edit_step.text.characters.last!=" "){
                      edit_step.text += " "+recipeIngredientModel.name;
                          }else{
                         edit_step.text += recipeIngredientModel.name;
                          }
    
                  edit_step.selection = TextSelection.fromPosition(TextPosition(offset: edit_step.text.length));
                            },
                            child: Text(recipeIngredientModel.name)),
                      );
                    },
                  ),
                );
              } else {
                return Center(
                  child: CircularProgressIndicator(),
                );
              }
            },
          ),
        ],
      ),
    );
 
  }
}



class RecipeEtapa extends StatefulWidget {
  TextEditingController _edit_step;
 List<Ingredient> _list_ingrediente;

   RecipeEtapa(this._edit_step,this._list_ingrediente);

  @override
  State<RecipeEtapa> createState() => _RecipeEtapaState();
}

class _RecipeEtapaState extends State<RecipeEtapa> {


  RecipeSteps passo = new RecipeSteps(-1, [], 0, false);

  bool required = true;

  @override
  Widget build(BuildContext context) {

  return Container(
      margin: const EdgeInsets.only( top: 10, left: 10,right: 10),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 280,
          margin: EdgeInsets.only(bottom: 30, top: 30),
          width: MediaQuery.of(context).size.width,
          child:  Container(
                  padding: EdgeInsets.all(5),
                  child: Center(
                    child: Wrap(children: passo.frase.map<Widget>((e){

                            if(e.amount>0){
                      return Container(
                        margin: EdgeInsets.only(right: 5,left: 5),
                        child: ElevatedButton(
                          onPressed: (){
                            setState(() {
                                passo.frase[passo.frase.indexOf(e)].amount +=1;

                            });
                          },
                          child: Text(e.amount.toString()+" "+e.name,style: TextStyle(fontWeight: FontWeight.bold),),
                        ),
                      );

                      }else{
                      return Text(" "+e.name);

                      }



                    }).toList()),
                  ),
                )
          
           
        ),
   
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                  onTap: () {
                   setState(() {
                     required = !required;
                   });
                  },
                  child: Container(
    height: 50,
                      width: 50,
    decoration: BoxDecoration(
    color: Color.fromRGBO(0, 178, 255, 1),
    borderRadius: BorderRadius.circular(5)),
    padding: EdgeInsets.all(5),
    child: Icon( Icons.star, color: required?Colors.yellow : Colors.black))),
              Container(
                width: 60.w,
                height: 50,
                child: TextField(
                  decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      label: Text("Frase")),
                  controller: widget._edit_step,
                  onChanged: (frase) {
                    List<RecipeIngredientModel> renderWords = [];

                    for(var word in frase.split(" ")){

                      int isIngredient = -1;
                      for(Ingredient ingredient in widget._list_ingrediente){
                        if(ingredient.name.toLowerCase()==word.toLowerCase()){
                          isIngredient = ingredient.id;
                        }
                      }
                      if(isIngredient!=-1){
                        renderWords.add(RecipeIngredientModel.IngredientPreview(isIngredient,1, "Int",word.substring(0,1).toUpperCase()+word.substring(1, word.length)));
                      }else{
                        renderWords.add(RecipeIngredientModel.Word(-1, word));
                      }

                    }
                    setState(() {

                          //get current state of words in phrase
                          for(var item in renderWords){
                            for(var phrase in passo.frase){
                              if(item.id == phrase.id && item.idItem == phrase.idItem){
                                if(phrase.amount>0){
                                  item.amount = phrase.amount;
                                }
                              }
                            }
                          }
                          passo.frase.clear();
                          passo.id = Config.listStepEdit.length+1;
                          passo.frase.addAll(renderWords);
                          passo.original = 2;
                          passo.obrigatorio = required;

                    });
                  },
                ),
              ),
              GestureDetector(
                onTap: (){
                  Config.listStepEdit.add(passo);
                  Navigator.pop(context);
                },
                 child: Container(
                      height: 50,
                     width: 50,

                     decoration: BoxDecoration(
                          color: Color.fromRGBO(0, 178, 255, 1),
                          borderRadius: BorderRadius.circular(5)),
                      padding: EdgeInsets.all(5),
                      child: Icon(
                        Icons.send,
                        color: Colors.white,
                        size: 30,
                      )))
            ],
          )
      ],
    ),
  );
  }
}
