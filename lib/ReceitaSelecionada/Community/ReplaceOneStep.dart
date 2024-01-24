import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:evaluatefood/Config/appConfig.dart';
import 'package:evaluatefood/Create/Recipe/index.dart';
import 'package:evaluatefood/Model/Receita/RecipeIngredient.dart';
import 'package:evaluatefood/Model/Receita/RecipeSteps.dart';
import 'package:evaluatefood/Model/Receita/Recipe.dart';
import 'package:http/http.dart' as http;
import 'package:sizer/sizer.dart';






class ReplaceOneStep extends StatelessWidget {
RecipeSteps oldRecipeStep;
ReplaceOneStep(this.oldRecipeStep);

    List<RecipeIngredientModel> list_ingrediente = [];

 Future<List<RecipeIngredientModel>> CarregarIngredientes()  async {
list_ingrediente.clear();
    var response = await http
        .get(Uri.parse(Config.ipadress+"/api/list_ingrediente"));

    for (var ingrediente in jsonDecode(response.body)) {
      list_ingrediente.add(RecipeIngredientModel.Ingredient(-1,-1,ingrediente["id"],0,"Nn", ingrediente["nome"]));
    }
    return list_ingrediente;
  }




  TextEditingController edit_step = new TextEditingController();

  RecipeSteps passo = new RecipeSteps(-1, [],0, true);

  @override
  Widget build(BuildContext context) {

    String words = "";
   for(var word in oldRecipeStep.frase){
      words +=word.name+" ";
    }

    edit_step.text = words;
    return Scaffold(
      appBar: AppBar(title: Text("Substituir Etapa")),
      body: Container(
        margin: EdgeInsets.only(right: 10,left: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 20,
            ),
            Text("Frase anterior: "),
            SizedBox(
              height: 10,
            ),
            Wrap(children: oldRecipeStep.frase.map<Widget>((e){


                            if(e.amount>0){
                      return Container(
                        margin: EdgeInsets.only(right: 5,left: 5),
                        child: Text(e.amount.toString()+" "+e.name,style: TextStyle(fontWeight: FontWeight.bold),));

                      }else{
                      return Text(" "+e.name);

                      }


                    }).toList()),
            SizedBox(
              height: 40,
            ),
            Row(
              children: [
                Text("Nova ",style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),),
                Text("Frase:",style: TextStyle(fontWeight: FontWeight.bold),),
              ],
            ),
            RecipeEtapa(this.oldRecipeStep,edit_step,list_ingrediente,passo),



            FutureBuilder<List<RecipeIngredientModel>>(
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
                        RecipeIngredientModel recipeIngredientModel =
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
      ),
    );
 
  }
}



class RecipeEtapa extends StatefulWidget {

  TextEditingController _edit_step;
 List<RecipeIngredientModel> _list_ingrediente;
 RecipeSteps passo;
 RecipeSteps old;

   RecipeEtapa(this.old,this._edit_step,this._list_ingrediente,this.passo);

  @override
  State<RecipeEtapa> createState() => _RecipeEtapaState();
}

class _RecipeEtapaState extends State<RecipeEtapa> {

  List<RecipeIngredientModel> lista_ingredientes_encontrados=[];

  int editar = 0;

  bool required = true;

  @override
  Widget build(BuildContext context) {



  return Container(
      margin: const EdgeInsets.only( top: 10,),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 100,
          margin: EdgeInsets.only(bottom: 30),
          width: MediaQuery.of(context).size.width,
          child:  Container(
                  padding: EdgeInsets.all(5),
                  child: Wrap(children: widget.passo.frase.map<Widget>((e){

                    if(e.idfrase==editar){
                          if(e.amount>0){
                    return Container(
                      margin: EdgeInsets.only(right: 5,left: 5),
                      child: ElevatedButton(
                        onPressed: (){
                          setState(() {
                            print("Linha: id: "+e.idfrase.toString()+" I: "+e.idItem.toString());
                              widget.passo.frase[e.idItem].amount +=1; 
                            
                          });
                        },
                        child: Text(e.amount.toString()+" "+e.name,style: TextStyle(fontWeight: FontWeight.bold),),
                      ),
                    );
                          
                    }else{
                    return Text(" "+e.name);
                          
                    }
                    }else{
                          if(e.amount>0){
                    return Container(
                      margin: EdgeInsets.only(right: 5,left: 5),
                      child: Text(e.amount.toString()+" "+e.name,style: TextStyle(fontWeight: FontWeight.bold),));
                      
                    
                          
                    }else{
                    return Text(" "+e.name);
                          
                    }
                    }

                
                  }).toList()),
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
                  decoration: InputDecoration(label: Text("Frase")),
                  controller: widget._edit_step,
                  onChanged: (frase) {
                    setState(() {
                      


List<RecipeIngredientModel> list = [];

  int indexf=editar,indexi=0;
                       for(String palavra in frase.split(" ")){
                        bool ingrediente = false;
                      for(RecipeIngredientModel ingrediente_receita in widget._list_ingrediente){
  
  
                       if(ingrediente_receita.name.toLowerCase()==palavra.toLowerCase()){
                        ingrediente = true;
                   
                   int _amount =1;

                  
                        for(RecipeIngredientModel recipeSteps in widget.old.frase){
                          if(ingrediente_receita.name.toLowerCase()==recipeSteps.name.toLowerCase()){
                                _amount=recipeSteps.amount;
                          }
                        } 
                        
                        
                       if(_amount>0){
                          list.add(new RecipeIngredientModel.Ingredient(indexf,indexi,ingrediente_receita.id,_amount,"Nn", ingrediente_receita.name));

                        }

  indexi+=1;
                     
                       }
  
                      }
                      
                      if(!ingrediente){
                         list.add(new RecipeIngredientModel.Word(indexf,palavra));
indexi+=1;
                      }
  
  
                      }

   widget.passo.frase.clear();

   
    widget.passo=RecipeSteps(widget.old.id,list,widget.old.original==0 ? 1 : 2,required );

                       });
                  },
                ),
              ),
              GestureDetector(
                  onTap: () {
                    setState(() {
                      int position = 0;
                      for(RecipeSteps verifyStepOld in Config.listStepEdit){
                        if(verifyStepOld.id==widget.passo.id){
                          RecipeSteps r = widget.passo;
                          for( RecipeSteps oldrecipe in Config.listStepsofRecipe){
                            if(widget.passo.id==oldrecipe.id){
                              r.original = widget.old.original==0 ? 1 : 2;
                            }
                          }

                          Config.listStepEdit[position] = r;
                        }else{
                          position+=1;
                        }
                      }
                    });


                   
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
