import 'dart:convert';
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:speech_to_text/speech_to_text.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:speech_to_text/speech_to_text.dart';


import '../../../Config/appConfig.dart';
import '../../../Model/Receita/Ingredient.dart';
import '../../../Model/Receita/RecipeIngredient.dart';
import '../../../Model/Receita/RecipeStepTimeout.dart';
import '../../../Model/Receita/RecipeSteps.dart';
import '../IngredientController.dart';
import '../index.dart';
import 'RecipeIngredient.dart';

class RenderWidgetRecipeEtapa extends StatefulWidget {

  int RecipeID=-1;

  TextEditingController _edit_step;
  List<Ingredient> _list_ingrediente;


  RenderWidgetRecipeEtapa(this._edit_step,this._list_ingrediente, this.RecipeID);

  @override
  State<RenderWidgetRecipeEtapa> createState() => _RenderWidgetRecipeEtapaState();
}

class _RenderWidgetRecipeEtapaState extends State<RenderWidgetRecipeEtapa> {

  bool listStarSelect =true;

  TextEditingController _edit_timer_name = new TextEditingController();
  TextEditingController _edit_medida = new TextEditingController();

  int Time_hour=0, Time_minute=0;

  List<DropdownMenuItem> all_Items = [];
  SpeechToText _speechToText = SpeechToText();
  bool _speechEnabled =false;

  int idmedidaGrama=0, idmedidaLiquido=0;
  bool novo = true;
  String lastStatus="",lastError="", error_medida="";
  InitialMic()async{
    _speechEnabled = await _speechToText.initialize();

  }

  String RenderMedidaGramas(){
    if(idmedidaGrama==0){
      return "Selecione";
    }else if(idmedidaGrama==1){
      return "Quilograma";
    }else if(idmedidaGrama==2){
      return "Hectograma";
    }else if(idmedidaGrama==3){
      return "Decagrama";
    }else if(idmedidaGrama==4){
      return "Grama";
    }else if(idmedidaGrama==5){
      return "Decigrama";
    }else if(idmedidaGrama==6){
      return "Centigrama";
    }else{
      return "Miligrama";
    }
  }
  String RenderMedidaGramasTag(){
    if(idmedidaGrama==1){
      return "kg";
    }else if(idmedidaGrama==2){
      return "hg";
    }else if(idmedidaGrama==3){
      return "dag";
    }else if(idmedidaGrama==4){
      return "g";
    }else if(idmedidaGrama==5){
      return "dg";
    }else if(idmedidaGrama==6){
      return "cg";
    }else{
      return "mg";
    }
  }

  String RenderMedidaLiquidosTag(){
    if(idmedidaLiquido==1){
      return "kl";
    }else if(idmedidaLiquido==2){
      return "hl";
    }else if(idmedidaLiquido==3){
      return "dal";
    }else if(idmedidaLiquido==4){
      return "l";
    }else if(idmedidaLiquido==5){
      return "dl";
    }else if(idmedidaLiquido==6){
      return "cl";
    }else{
      return "ml";
    }
  }

  String RenderMedidaLiquido(){
    if(idmedidaLiquido==0){
      return "Selecione";
    }else if(idmedidaLiquido==1){
      return "Quilolitro";
    }else if(idmedidaLiquido==2){
      return "Hectolitro";
    }else if(idmedidaLiquido==3){
      return "Decalitro";
    }else if(idmedidaLiquido==4){
      return "Litro";
    }else if(idmedidaLiquido==5){
      return "Decilitro";
    }else if(idmedidaLiquido==6){
      return "Centilitro";
    }else{
      return "Mililitro";
    }
  }



  loadIngredients()async{
    final preferences = await SharedPreferences.getInstance();
    var all =     preferences.getString("ingredients");
    print("data: $all");

    if(all!=null){
      var convert = jsonDecode(all.toString());
      int row_p = 0;


      List<RecipeSteps> steps  = [];

      for(var row in convert){

        int row_p_ = 0;


        List<RecipeIngredientModel> ings = [];
        for(var ingredient in row){

          if(ingredient["amount"]>0){
            int id = -1;
            for(var ing in widget._list_ingrediente){
              if(ing.name==ingredient["word"]){
                id = ing.id;
              }
            }
            RecipeIngredientModel ingredients = new RecipeIngredientModel.Ingredient(row_p, row_p_, id, ingredient["amount"], ingredient["measure"], ingredient["word"]);
            ings.add(ingredients);
          }else{
            RecipeIngredientModel ingredientss = new RecipeIngredientModel.Word(row_p, ingredient["word"]);
            ings.add(ingredientss);

          }
          row_p_+=1;
        }
        RecipeSteps step = new RecipeSteps(row_p, ings, 0, true);
        steps.add(step);
        row_p+=1;
      }
      setState(() {
        CreateReceita.lista_passos.addAll(steps);
        editar = CreateReceita.lista_passos.length;
      });

    }



  }
  @override
  void initState(){
    super.initState();
    InitialMic();

    if(CreateReceita.lista_passos.length==0){
      //loadIngredients();
    }
    editar = CreateReceita.lista_passos.length;


  }

  void OnResult(SpeechRecognitionResult result){
    setState(() {
      widget._edit_step.text = result.recognizedWords;
    });
  }

  void statusListener(String status) {
    setState(() {
      lastStatus = status;
    });
  }

  int editar = 0;

  void errorListener(SpeechRecognitionError error) {
    setState(() {
      lastError = '${error.errorMsg} - ${error.permanent}';
    });
  }
  @override
  Widget build(BuildContext context) {

    all_Items.clear();
    for(int i= 0; i<=60; i++){
      all_Items.add(DropdownMenuItem(child: Text(i.toString()),value: i,));
    }


    return Container(
      margin: const EdgeInsets.only(right: 5, left: 5, top: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 250,
            margin: EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(
                border: Border.all(color: Color.fromRGBO(241, 239, 239, 1),width: 3),
                borderRadius: BorderRadius.circular(10)
            ),
            width: MediaQuery.of(context).size.width,
            child: Builder(
              builder: (context) {
                return ListView.builder(
                  shrinkWrap: true,
                  itemCount: CreateReceita.lista_passos.length,
                  itemBuilder: (_, position){
                    RecipeSteps recipeSteps = CreateReceita.lista_passos.elementAt(position);
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
                                            CreateReceita.lista_passos[e.idfrase].frase[e.idItem].amount +=1;

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
                                    Text(timeout.hour!=0? timeout.hour.toString() +" hora"+(timeout.hour>1? "s":""): ""+(timeout.hour!=0 ? " hora":"")+ ( timeout.minute!=0?  timeout.minute.toString() : "")+ ( timeout.minute!=0 ? " minutos" :"" ),style: TextStyle(color: Colors.white),)
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
                       /*   setState(() {
                            editar = recipeSteps.id;
                            //  posicaoAtual = recipeSteps.id-1;
                            String step = "";
                            for(var word in recipeSteps.frase){
                              step+= word.name+" ";
                            }
                            step.substring(0,step.length-1);
                            widget._edit_step.text = step;
                          });*/
                          print("data: ${recipeSteps.id}");
                        },
                        onLongPress: (){
                          setState(() {

                            int actualPositionDelete = CreateReceita.lista_passos.indexOf(recipeSteps);
                            CreateReceita.lista_passos.removeAt(actualPositionDelete);

                            int p =0;

                            for(RecipeSteps recipe in CreateReceita.lista_passos){
                              int position = CreateReceita.lista_passos.indexOf(recipe);
                              if(position>=actualPositionDelete){
                                CreateReceita.lista_passos[position].id = p;
                              }
                              p +=1;
                            }

                            editar=CreateReceita.lista_passos.length;


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
                                                print("id frase: "+(CreateReceita.lista_passos.length-1).toString());
                                                CreateReceita.lista_passos[CreateReceita.lista_passos.length-1].frase[e.idfrase].amount +=1;

                                              });
                                            },
                                            onLongPress: (){
                                              print("long press");
                                              _edit_medida.text = CreateReceita.lista_passos[CreateReceita.lista_passos.length-1].frase[e.idfrase].amount.toString();
                                              showDialog(context: context, builder: (_) => AlertDialog(
                                                title: Text("Ingrediente"),
                                                content: StatefulBuilder(
                                                  builder: (_, updateState){
                                                    return Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        Text("Se não tiver gramas e liquidos será numeros inteiros."),

                                                        Text("Gramas: "+RenderMedidaGramas()),

                                                        Slider(value: idmedidaGrama.toDouble(),
                                                            max: 7,
                                                            divisions: 8,
                                                            label: RenderMedidaGramas(),
                                                            onChanged: (value){
                                                              updateState((){
                                                                idmedidaGrama = value.toInt();
                                                                idmedidaLiquido=0;
                                                              });
                                                            }),

                                                        Text("Liguidos: "+RenderMedidaLiquido()),

                                                        Slider(value: idmedidaLiquido.toDouble(),
                                                            max: 7,
                                                            divisions: 8,
                                                            label: RenderMedidaLiquido(),
                                                            onChanged: (value){
                                                              updateState((){
                                                                idmedidaLiquido = value.toInt();
                                                                idmedidaGrama =0;
                                                              });
                                                            }),

                                                        SizedBox(
                                                          height: 15,
                                                        ),

                                                        Container(
                                                          child: TextField(
                                                            controller: _edit_medida,
                                                            keyboardType:  TextInputType.number,
                                                            decoration: InputDecoration(
                                                                label: Text("Quantidade"),
                                                                border: OutlineInputBorder(

                                                                )
                                                            ),
                                                          ),
                                                        ),

                                                        ElevatedButton(onPressed: (){
                                                          if(idmedidaGrama==0 && idmedidaLiquido==0 && _edit_medida.text.isNotEmpty){
                                                            Navigator.pop(context);

                                                            Future.delayed(Duration(seconds: 1),(){
                                                              setState(() {
                                                                CreateReceita.lista_passos[CreateReceita.lista_passos.length-1].frase[e.idfrase].amount = int.parse(_edit_medida.text.toString());
                                                                CreateReceita.lista_passos[CreateReceita.lista_passos.length-1].frase[e.idfrase].measure = "Int";

                                                              });

                                                            });



                                                          }else if(idmedidaGrama!=0 || idmedidaLiquido!=0 && _edit_medida.text.isNotEmpty){

                                                            Navigator.pop(context);

                                                              Future.delayed(Duration(seconds: 1),(){
                                                                setState(() {
                                                                  CreateReceita.lista_passos[CreateReceita.lista_passos.length-1].frase[e.idfrase].amount = int.parse(_edit_medida.text.toString());
                                                                  CreateReceita.lista_passos[CreateReceita.lista_passos.length-1].frase[e.idfrase].measure =(idmedidaGrama!=0? RenderMedidaGramasTag() : RenderMedidaLiquidosTag());

                                                                });

                                                              });


                                                          }else if(_edit_medida.text.isEmpty){
                                                            error_medida  ="Tem de ter quantidade";
                                                            Navigator.pop(context);

                                                          }

                                                        }, child: Text("Save")),

                                                        error_medida.isEmpty ? Container(): Text(error_medida,style: TextStyle(color: Colors.red),)

                                                      ],
                                                    );
                                                  },
                                                ),
                                              ));
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
                );
              },
            ),
          ),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [


          /*    ElevatedButton(
                  style: ElevatedButton.styleFrom(

                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: ()async {
                    await      showDialog(context: context, builder: (_)=> AlertDialog(
                      title: Text("Adicionar tempo espera"),
                      content: SizedBox(
                        height: 150,
                        child: Column(
                          children: [
                            Container(
                              child: TextField(
                                controller: _edit_timer_name,
                                decoration: InputDecoration(
                                    labelText: "Nome",
                                    border: OutlineInputBorder()
                                ),
                              ),
                            ),
                            Container(
                              width: MediaQuery.of(context).size.width,
                              child: ElevatedButton(onPressed: (){
                                Navigator.pop(context);
                              }, child: Text("Seguinte")),
                            )
                          ],
                        ),
                      ),
                    ));

                    if(_edit_timer_name.text.isNotEmpty){
                      showDialog(context: context, builder: (_)=> AlertDialog(
                        title: Text("Selecionar Tempo"),
                        content: StatefulBuilder(
                          builder: (_, setUpdate){
                            return SizedBox(
                              height: 150,
                              child: Column(
                                children: [
                                  Row(

                                    children: [
                                      Column(
                                        children: [
                                          Text("Horas"),
                                          DropdownButton(
                                              value: Time_hour,
                                              items:  all_Items,
                                              onChanged: (value){
                                                setUpdate((){
                                                  Time_hour = value!;
                                                });

                                              })
                                        ],
                                      ),

                                      Column(
                                        children: [
                                          Text("Minutos"),
                                          DropdownButton(
                                              value: Time_minute,
                                              items: all_Items, onChanged: (value){
                                            setUpdate((){
                                              Time_minute = value!;

                                            });

                                          })
                                        ],
                                      )
                                    ],
                                  ),
                                  Container(
                                    width: MediaQuery.of(context).size.width,
                                    child: ElevatedButton(

                                        onPressed: (){

                                          if(Time_hour!=0 || Time_minute!=0 && CreateReceita.lista_passos.length>0){
                                            setState(() {
                                              Config.list_recipe_Step_Timeout.add(RecipeStepTimeout(Config.list_recipe_Step_Timeout.length+1, CreateReceita.lista_passos.last.id, _edit_timer_name.text, Time_hour, Time_minute));

                                            });
                                            Navigator.pop(context);
                                          }else if(CreateReceita.lista_passos.length==0){
                                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Ainda não tem etapas !")));
                                          }else{
                                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("A hora / minutos diferentes de 0")));
                                          }

                                        }, child: Text("Adicionar")),
                                  )
                                ],
                              ),
                            );
                          },
                        ),
                      ));
                    }
                  },
                  child: Row(
                    children: [
                      Text("Tempo", style: TextStyle(color: Colors.white),),
                      Icon(Icons.timer, color: Colors.white,),
                    ],
                  )),*/
              ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.green,
                      side: BorderSide(color: Colors.green)

                  )
                  ,onPressed: (){
                Navigator.push(context, MaterialPageRoute(builder: (context)=> IngredientController()));
              }, child: Row(
                children: [
                  Text("Alimento"),
                  Icon(Icons.add)
                ],
              )),
              ElevatedButton(onPressed: ()async{

                if(_speechEnabled){
                  stt.SpeechToText speech = stt.SpeechToText();

                  await speech.initialize( onStatus: statusListener, onError: errorListener );

                  speech.listen( onResult: OnResult);

                  /*  // some time later...
        speech.stop();*/
                }else{
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Microfone indisponível !")));
                }



              }, child: Row(
                children: [
                  Text("Microfone", style: TextStyle(color: Colors.white),),
                  Icon(Icons.mic, color: Colors.white,),
                ],
              ))
            ],
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
                          editar=CreateReceita.lista_passos.length;
                          widget._edit_step.text = "";
                        });

                        String list ="[";

                        for(RecipeSteps r in CreateReceita.lista_passos){

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
                          int r_p = CreateReceita.lista_passos.indexOf(r);
                          if(r_p!=CreateReceita.lista_passos.length-1){
                            list+=", ";
                          }else{
                            list+="]";

                          }
                        }

                   /*     final preferences = await SharedPreferences.getInstance();
                        preferences.setString("ingredients", list);*/

                      },
                      child: Icon(Icons.send)),
                  label: Text("Frase")),
              controller: widget._edit_step,
              onChanged: (frase) {

                List<RecipeIngredientModel> renderWords = [];
                int idfrase = 0;
                for(var word in frase.split(" ")){

                  int isIngredient = -1;
                  for(Ingredient ingredient in widget._list_ingrediente){
                    if(ingredient.name.toLowerCase()==word.toLowerCase()){
                      isIngredient = ingredient.id;
                    }
                  }
                  if(isIngredient!=-1){
                  var preview = RecipeIngredientModel.IngredientPreview(isIngredient,1, "Int",word.substring(0,1).toUpperCase()+word.substring(1, word.length));
                  preview.idfrase = idfrase;
                  renderWords.add(preview);
                  }else{
                    renderWords.add(RecipeIngredientModel.Word(-1, word));
                  }
idfrase+=1;
                }

                setState(() {
                  try{
                    if(CreateReceita.lista_passos.elementAt(editar).id!=-1){

                      //get current state of words in phrase
                      for(var item in renderWords){
                        for(var phrase in CreateReceita.lista_passos[editar].frase){
                          if(item.id == phrase.id && item.idItem == phrase.idItem){
                            if(phrase.amount>0){
                              item.amount = phrase.amount;
                              item.measure = phrase.measure;
                            }
                          }
                        }
                      }
                      CreateReceita.lista_passos[editar]= (RecipeSteps(editar, renderWords, 0, listStarSelect));

                    }
                  }catch(erro){
                    CreateReceita.lista_passos.add(RecipeSteps(editar, renderWords, 0, listStarSelect));

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