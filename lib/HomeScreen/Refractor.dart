import 'package:evaluatefood/Model/Receita/Ingredient.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Config/appConfig.dart';
import '../Model/Receita/RecipeIngredient.dart';
import '../Model/Receita/RecipeStepTimeout.dart';
import '../Model/Receita/RecipeSteps.dart';

class Refractor extends StatefulWidget {
  int RecipeID = -1;
  Refractor(this.RecipeID);

  @override
  State<Refractor> createState() => _RefractorState();
}

class _RefractorState extends State<Refractor> {

  List<RecipeSteps> steps = [];
  int editar = 0;
  bool listStarSelect = false;
  List<Ingredient> ingredients = [
    Ingredient(1, "Arroz"),
    Ingredient(2, "Leite"),
  ];

  TextEditingController passo = new TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          SizedBox(
            height: 300,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: steps.length,
              itemBuilder: (_, position){
                RecipeSteps recipeSteps = steps.elementAt(position);
                bool showtimeout = false;

                for(RecipeStepTimeout timeout in Config.list_recipe_Step_Timeout){
                  if(timeout.idStepbefore==recipeSteps.id){
                    showtimeout = true;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          margin: EdgeInsets.only(right: 10,left: 10),
                          padding: EdgeInsets.only(top: 10,right: 10,left: 10,bottom: 5),

                          child: Wrap(children: recipeSteps.frase.map<Widget>((e){

                            if(e.idfrase==editar){
                              if(e.amount>0){

                                return Container(
                                  margin: EdgeInsets.only(right: 5,left: 5),
                                  child: ElevatedButton(
                                    onPressed: (){
                                      setState(() {
                                        steps[e.idfrase].frase[e.idItem].amount +=1;

                                      });
                                    },
                                    child: Text(e.amount.toString()+" "+e.name,style: TextStyle(fontWeight: FontWeight.bold),),
                                  ),
                                );

                              }else{


                                return Text(" "+e.name,);

                              }
                            }else{
                              if(e.amount>0){

                                return Container(
                                    margin: EdgeInsets.only(right: 5,left: 5),
                                    child: Text(e.amount.toString()+e.name,style: TextStyle(fontWeight: FontWeight.bold),));



                              }else{
                                return Text(" "+e.name);

                              }
                            }


                          }).toList()),
                        ),
                        GestureDetector(
                          onLongPress: (){
                            setState(() {
                              Config.list_recipe_Step_Timeout.removeAt(Config.list_recipe_Step_Timeout.indexOf(timeout));

                            });
                          },
                          child: Container(
                            margin: EdgeInsets.only(right: 10,left: 10,top: 5,bottom: 5),
                            padding: EdgeInsets.only(top: 10,right: 10,left: 10,bottom: 5),
                            decoration: BoxDecoration(
                                color: Color.fromRGBO(0, 178, 255, 100),

                                borderRadius: BorderRadius.circular(5)
                            ),
                            child: Row(
                              children: [
                                Spacer(
                                  flex: 2,
                                ),
                                Text(timeout.name, style: TextStyle(color: Colors.white),),
                                Spacer(
                                  flex: 2,
                                ),
                                Text(timeout.hour!=0? timeout.hour.toString() : ""+(timeout.hour!=0 ? " hora":"")+ ( timeout.minute!=0?  timeout.minute.toString() : "")+ ( timeout.minute!=0 ? " minutos" :"" ),style: TextStyle(color: Colors.white),)
                                ,  Icon(Icons.timer, color: Colors.white,),

                              ],
                            ),
                          ),
                        )
                      ],
                    );
                  }
                }
                if(!showtimeout){
                  return GestureDetector(
                    onTap: (){
                      setState(() {
                        editar = recipeSteps.id;
                        //  posicaoAtual = recipeSteps.id-1;
                        String step = "";
                        for(var word in recipeSteps.frase){
                          step+= word.name+" ";
                        }
                        step.substring(0,step.length-1);
                     passo.text = step;
                      });
                    },
                    onLongPress: (){
                      setState(() {

                        int actualPositionDelete = steps.indexOf(recipeSteps);
                        steps.removeAt(actualPositionDelete);

                        int p =0;

                        for(RecipeSteps recipe in steps){
                          int position = steps.indexOf(recipe);
                          if(position>=actualPositionDelete){
                           steps[position].id = p;
                          }
                          p +=1;
                        }

                        
                        editar=steps.length;


                      });
                    },
                    child: Row(
                      children: [
                        editar == position ?Icon(Icons.forward, color: Color.fromRGBO(255, 184, 0, 1),) : Container(),
                        SizedBox(
                          width: MediaQuery.of(context).size.width-40,
                          child: Container(


                            decoration: BoxDecoration(
                                border: Border.all(color: recipeSteps.obrigatorio? Colors.green : Colors.white),
                                borderRadius: BorderRadius.circular(5)
                            ),
                            child: Container(
                              padding: EdgeInsets.only(top: 10,bottom: 5),

                              child: Wrap(children: recipeSteps.frase.map<Widget>((e){

                                if(recipeSteps.id==(editar) ){
                                  if(e.amount>0){
                                    return Container(
                                      child: ElevatedButton(
                                        onPressed: (){
                                          setState(() {
                                            int p = recipeSteps.frase.indexOf(e);
                                          steps[editar].frase[p].amount +=1;
                                          });
                                        },
                                        child: Text(e.amount.toString()+(e.measure!="Int"?" "+e.measure : "")+" "+e.name,style: TextStyle(fontWeight: FontWeight.bold),),
                                      ),
                                    );

                                  }else{
                                    return Text(" "+e.name,);

                                  }
                                }else{

                                  return e.amount>0 ? Container(
                                      margin: EdgeInsets.only(right: 5,left: 5),
                                      child: Text(e.amount.toString()+" "+(e.measure!="Int"? e.measure : "")+" "+e.name,style: TextStyle(fontWeight: FontWeight.bold),)):  Text(" "+e.name);

                                }


                              }).toList()),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }

              },
            ),
          ),
        SizedBox(
          height: 20,
        ),

          Container(
            width: MediaQuery.of(context).size.width,
            child: TextField(
              maxLength: 47,
              decoration: InputDecoration(
                  prefixIcon: GestureDetector(
                      onTap: (){
                        setState(() {
                          listStarSelect=!listStarSelect;

                        });
                      },
                      child: Icon(Icons.star , color: listStarSelect ? Color.fromRGBO(0, 178, 255, 100) : Colors.black,)),
                  suffixIcon: GestureDetector(
                      onTap: ()async{
                        setState(() {
                          editar=steps.length;
                          passo.text = "";
                        });

                        String list ="[";

                        for(RecipeSteps r in steps){

                          list+="[";
                          for(RecipeIngredientModel ingredient  in r.frase){

                            list+="{ \"id_ing\" : "+ingredient.idItem.toString()+"  , \"word\" : \""+ingredient.name+"\", \"amount\" : "+ingredient.amount.toString()+", \"measure\" : \""+ingredient.measure+"\" }";



                            int r_p_ = r.frase.indexOf(ingredient);
                            if(r_p_<r.frase.length-1){
                              list+=", ";

                            }else{
                              list+="]";

                            }
                          }
                          int r_p = steps.indexOf(r);
                          if(r_p!=steps.length-1){
                            list+=", ";
                          }else{
                            list+="]";

                          }
                        }

                        final preferences = await SharedPreferences.getInstance();
                        preferences.setString("ingredients", list);

                      },
                      child: Icon(Icons.send)),
                  label: Text("Frase")),
              controller: passo,
              onChanged: (frase) {

                List<RecipeIngredientModel> renderWords = [];

             for(var word in frase.split(" ")){

               int isIngredient = -1;
               for(Ingredient ingredient in ingredients){
                 if(ingredient.name.toLowerCase()==word.toLowerCase()){
                  isIngredient = ingredient.id;
                 }
               }
               if(isIngredient!=-1){
                 renderWords.add(RecipeIngredientModel.IngredientPreview(isIngredient,1, "Int",word.substring(0,1).toUpperCase()+word.substring(1, word.length)));
               }else{
                 renderWords.add(RecipeIngredientModel.Word(editar, word));
               }

             }
             setState(() {
               try{
                 if(steps.elementAt(editar).id!=-1){

                   //get current state of words in phrase
                   for(var item in renderWords){
                     for(var phrase in steps[editar].frase){
                       if(item.id == phrase.id && item.idItem == phrase.idItem){
                         if(phrase.amount>0){
                           item.amount = phrase.amount;
                         }
                       }
                     }
                   }
                   steps[editar]= (RecipeSteps(editar, renderWords, 0, listStarSelect));

                 }
               }catch(erro){
                 steps.add(RecipeSteps(editar, renderWords, 0, listStarSelect));

               }
             });
              },
            ),
          )
        ],
      ),
    );
  }
}
