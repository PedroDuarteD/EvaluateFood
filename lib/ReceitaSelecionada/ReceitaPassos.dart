import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:evaluatefood/Config/appConfig.dart';
import 'package:evaluatefood/Model/Receita/RecipeIngredient.dart';
import 'package:evaluatefood/Model/Receita/RecipeStepTimeout.dart';
import 'package:evaluatefood/Model/Receita/RecipeSteps.dart';
import 'package:http/http.dart' as http;
import 'package:evaluatefood/Providers/UpdatePeopeofRecipe.dart';
class ReceitaPassos extends StatefulWidget {

  double tamanhoLista = 300;

  String idRecipe="";
  ReceitaPassos(this.tamanhoLista, this.idRecipe);

  @override
  State<ReceitaPassos> createState() => _ReceitaPassosState();
}

class _ReceitaPassosState extends State<ReceitaPassos> {
  List<RecipeSteps> listSteps = [];

int progresso =0;
int numeroPessoas = 1;
int totalObrigatorios = 0;
int people=1;
  MethodChannel methodChannel = MethodChannel("evaluatefood");


//GetnumberofPeopleRecipe


Future<int> loadPeopleRecipe()async{
  int people =0;
    var response = await  http.get(Uri.parse("${Config.ipadress}/api/getPeopleRecipe/${widget.idRecipe}"));

  var response_convert = jsonDecode(response.body);
  if(response_convert["ans"]=="Success"){
    people = int.parse( response_convert["people"].toString());
  }


return people;


}

Future<List<RecipeSteps>> LoadAllSetps ()async{



  if(listSteps.isEmpty){
people = await loadPeopleRecipe();

  context.read<PeopleOfRecipe>().setPeople(people);

    Config.list_recipe_Step_TimeoutSelect.clear();
  var response = await  http.get(Uri.parse("${Config.ipadress}/api/ListAllSteps/${widget.idRecipe}"));

  var response_convert = jsonDecode(response.body);
  print("PEDRO load all steps ${people}");
  for(var step in response_convert["steps"]){
    RecipeSteps recipeSteps = new RecipeSteps(step["idStep"], Config.ConvertStringStepToListIngredients(step["idStep"],  step["step"]), 1, step["required"]==1? true : false);

    if(step["step"].toString().contains("TOUT") ){
      var timeout = step["step"].toString().split(" ")[0].replaceAll("TOUT", "").split(":");
      if((int.parse(timeout[0]))==(listSteps.length)){


      if((timeout[2].toString()=="0" && timeout[1].toString()!="0" ) || (timeout[2].toString()!="0" && timeout[1].toString()=="0")){


        Config.list_recipe_Step_TimeoutSelect.add( new RecipeStepTimeout( Config.list_recipe_Step_TimeoutSelect.isEmpty? Config.list_recipe_Step_TimeoutSelect.length : Config.list_recipe_Step_TimeoutSelect.length+1,(int.parse(timeout[0])),timeout[3].toString(), int.parse(timeout[1].toString()), int.parse(timeout[2].toString()) ));

      }

      }
    }
    listSteps.add(recipeSteps);
  }

  }else{
    progresso =0;
    totalObrigatorios =0;
      for(RecipeSteps step in listSteps){
    if(step.select && step.obrigatorio){
      progresso+=1;
    }
    if(step.obrigatorio){
      totalObrigatorios+=1;
    }
  }
  }

  return listSteps;
}

TextEditingController _editPeople = new TextEditingController();

  
  @override
  Widget build(BuildContext context) {
   return Column(
   crossAxisAlignment: CrossAxisAlignment.start,
   children: [
SizedBox(
  height: 15,
),
    Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text("Nº Pessoas:",textAlign: TextAlign.center,),
          Consumer<PeopleOfRecipe>(builder: (_, value, other){
            return 
          Text(" ${value.getPeople()}",textAlign: TextAlign.center,style: TextStyle(fontSize: 20),);
          })
        ],
      ),
    ),
     Row(
       mainAxisAlignment: MainAxisAlignment.spaceBetween,
       children: [
         Padding(
           padding: const EdgeInsets.only(top: 20.0,bottom: 20),
           child: Text("Passos para"),

         ),


  Consumer<PeopleOfRecipe>(builder: (_, value, other){
    if(numeroPessoas==1){
          numeroPessoas = value.getPeople()>0 ? value.getPeople() : numeroPessoas;
    }

            return 
            ElevatedButton(onPressed: (){
         setState(() {
                               numeroPessoas +=1;
                             });
         },onLongPress: (){
             _editPeople.text = numeroPessoas.toString();
            showDialog(context: context,
               builder: (_) => AlertDialog(

                 content: SizedBox(  height: 125,
                   child: Column(
                     children: [
                       Container(

                         child: TextField(
                           decoration: InputDecoration(
                             labelText: "Nº Pessoas"
                           ),
                           controller: _editPeople,

                           keyboardType: TextInputType.number,
                         ),
                       ),
                       Container(
                         width: MediaQuery.of(context).size.width,
                         child: ElevatedButton(onPressed: (){
                           if(_editPeople.text.isNotEmpty){
                             setState(() {
                               numeroPessoas = int.parse(_editPeople.text);
                             });
                             Navigator.pop(context);


                           }
                         }, child: Text("Salvar")),
                       )
                     ],
                   ),
                 ),
               ));
         }, child: Text("$numeroPessoas Pessoa"));
          })


       

       ],
     ),
   

       
         Container(
           margin: EdgeInsets.only(top: 20),
           height: widget.tamanhoLista,
           decoration: BoxDecoration(
         ),
           child: FutureBuilder<List<RecipeSteps>>(
             future: LoadAllSetps(),
             builder: (context, snapshot){
                 if(snapshot.connectionState==ConnectionState.done|| snapshot.connectionState==ConnectionState.active){
                     return Column(
                       crossAxisAlignment: CrossAxisAlignment.start,
                       children: [
                          Container(
                            margin: EdgeInsets.only(bottom: 20),
         child: Row(
           mainAxisAlignment: MainAxisAlignment.center,
           children: [
             Text( "Progresso "),
             Text((progresso==0? 0.toString():((progresso*100)/totalObrigatorios).toString()),style: TextStyle(color: Colors.green),),
             Text(" %")
           ],
         ),
       ) ,
                         ListView.builder(
                           itemCount: snapshot.data!.length,
             shrinkWrap: true,
               itemBuilder: (context, index) {
                    RecipeSteps recipeWord = snapshot.data![index];

                    bool showTimeout = false;

                    for(RecipeStepTimeout stepTimeout in Config.list_recipe_Step_TimeoutSelect){


                      if((stepTimeout.idStepbefore)==(index)){

                        showTimeout = true;


                        return Container(

                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                margin: EdgeInsets.only(bottom: 3),
                                padding: EdgeInsets.only(bottom: 10, top: 10),
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10)
                                ),
                                child: Column(
                                  children: [
                                    Row(
                                        children: [

                                          Padding(
                                            padding: const EdgeInsets.only(right: 10),
                                            child: recipeWord.obrigatorio ?Text(recipeWord.id.toString()): Container(),
                                          ) ,

                                          Row(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children:  recipeWord.frase.map<Widget>((e) {
                                              if(e.amount>0){
                                                return Container(
                                                    margin: EdgeInsets.only(right: 5,left: 5),
                                                    padding: EdgeInsets.all(5),
                                                    decoration: BoxDecoration(
                                                        color: Colors.blue
                                                    ),
                                                    child: Text(e.amount.toString()+" "+e.name,style: TextStyle(color: Colors.white),));
                                              }else{
                                                return Text(e.name);


                                              }
                                            },).toList(),
                                          ),




                                          recipeWord.obrigatorio ?
                                          Checkbox(value: recipeWord.select, onChanged: (valor){
                                            setState(() {
                                              recipeWord.select = valor!;
                                              print("Selecionado: "+valor.toString());
                                            });
                                          }) : Container()
                                        ]),


                                  ],
                                ),
                              ),
                              Row(
                                children: [
                                  Container(
                                    margin: EdgeInsets.only(right: 10,left: 10,top: 5,bottom: 5),
                                    padding: EdgeInsets.only(top: 10,right: 10,left: 10,bottom: 5),
                                    decoration: BoxDecoration(
                                        color: Colors.white38,
                                        borderRadius: BorderRadius.circular(5)
                                    ),
                                    child: Column(
                                      children: [
                                        Text(stepTimeout.name, style: TextStyle(color: Color.fromRGBO(0, 178, 255, 100), fontWeight: FontWeight.bold),),
                                        Text(stepTimeout.hour!=0? stepTimeout.hour.toString() : ""+(stepTimeout.hour!=0 ? " hora":"")+ ( stepTimeout.minute!=0?  stepTimeout.minute.toString() : "")+ ( stepTimeout.minute!=0 ? " minutos" :"" ),style: TextStyle(color: Colors.green))

                                      ],
                                    ),
                                  ),
                                  ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Color.fromRGBO(0, 178, 255, 100)
                                  )
                                  ,onPressed: (){
                      //  methodChannel.invokeMethod("notify");
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Ainda não disponivel !")));
                                  }, child: Row(children: [Icon(Icons.timer,color: Colors.white,), SizedBox(
                                    width: 10,
                                  ), Text("Iniciar",style: TextStyle(color: Colors.white),)],))
                                ],
                              )
                            ],
                          ),
                        );
                      }
                    }
                if(!showTimeout){
                  return Row(
                    children: [      Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child:   recipeWord.obrigatorio ?Text((index+1).toString()) : Container(),
                    ),
                      Container(
                        margin: EdgeInsets.only(bottom: 3),
                        padding: EdgeInsets.only(top: 10,bottom: 10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10)

                        ),
                        child: Row(
                            children: [


                              Row(
                                children:  recipeWord.frase.map<Widget>((e) {
                                  if(e.amount>0){
                                    return Container(
                                        margin: EdgeInsets.only(right: 5,left: 5),
                                        padding: EdgeInsets.all(5),
                                        decoration: BoxDecoration(
                                            color: Colors.blue
                                        ),
                                        child: Text(((numeroPessoas *e.amount)/people).toString()+" "+(e.measure=="Int" ? "" : e.measure.toString())+" "+e.name,style: TextStyle(color: Colors.white),));
                                  }else{
                                    return Text(e.name);


                                  }
                                },).toList(),
                              ),



                              recipeWord.obrigatorio ?
                              Checkbox(value: recipeWord.select, onChanged: (valor){
                                setState(() {
                                  recipeWord.select = valor!;
                                  print("Selecionado: "+valor.toString());
                                });
                              }) : Container()
                            ]),
                      ),
                    ],
                  );
                }
               },
           ),
                       ],
                     );
                 }else{
                   return Center(
                     child: CircularProgressIndicator(),
                   );
                 }
           })
         )
   ],
     );
  }
}