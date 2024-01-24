import 'dart:convert';
import 'dart:io';
import 'package:evaluatefood/Create/Recipe/StateManager/FinishCreating.dart';
import 'package:flutter/material.dart';
import 'package:images_picker/images_picker.dart';
import 'package:http/http.dart' as http;
import 'package:evaluatefood/Create/Recipe/index.dart';
import 'package:evaluatefood/Model/Receita/RecipeIngredient.dart';
import 'package:evaluatefood/Model/Receita/RecipeStepTimeout.dart';
import 'package:evaluatefood/Model/Receita/RecipeSteps.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../Config/appConfig.dart';
import '../../Model/Receita/RecipeSettings.dart';

class RecipeFinish extends StatefulWidget {

  int RecipeID=-1;

   RecipeFinish(this.RecipeID);

  @override
  State<RecipeFinish> createState() => _RecipeFinishState();
}

class _RecipeFinishState extends State<RecipeFinish> {

 List<RecipeSettings> list_Settings = [
   RecipeSettings(1,"Não visivel", false),
   RecipeSettings(2,"Comentários", true),
   RecipeSettings(3,"Editar passos", true),
   RecipeSettings(4,"Permitir exportar para outras receitas", false)
 ];

 bool precessing = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(right: 15,left: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
   SizedBox(
                  height: 25,),
          Text("Obrigado",textAlign: TextAlign.center,style: TextStyle(fontSize: 30),),
   SizedBox(
                  height: 15,),
          Text("Sua nova Receita vai ser criada !"),
          Text("Não pode eliminar Receita",style: TextStyle(color: Colors.red),),
   SizedBox(
                  height: 25,),
          SizedBox(
            height: 30,
          ),
            Row(
              children: [
                Icon(Icons.arrow_forward),
                Text("Opções adicionais")
              ],
            ),

        ListView(
          shrinkWrap: true,
          children: list_Settings.map<Widget>((e) {
            return Row(
              children: [
                Checkbox(value: e.check, onChanged: (value){
                  setState(() {
                    list_Settings.elementAt(list_Settings.indexOf(e)).check = value!;
                  });
                }),
                Text(e.text)
              ],
            );
          }).toList()
        )   ,
          SizedBox(
            height: 20,
          ),
          Consumer<FinishCreating>(
            builder: (BuildContext context, FinishCreating value, Widget? child) {
             return  Column(
               children: [
                 AbsorbPointer(
                   absorbing: value.getProcess(),
                   child: Container(
                      width: MediaQuery.of(context).size.width,
                      child: ElevatedButton(child: Text( widget.RecipeID==-1? "Finalizar" : "Atualizar")

                        ,onPressed: ()async{
                          String falta = "";

                          if(CreateReceita.lista_passos.isEmpty){
                            falta = "as várias etapas para a receita ";
                          }
                          if(widget.RecipeID==-1){
                            if( CreateReceita.trailer.isEmpty){
                              falta = "um vídeo curto para o Trailer";
                            }
                          }


                          if(CreateReceita.edit_description.text.isEmpty){
                            falta ="a descrição !";
                          }
                          if(CreateReceita.edit_name.text.isEmpty){
                            falta ="o nome !";
                          }

                          if(CreateReceita.sop_selected==0){
                            falta ="uma categoria !";
                          }


                          if(falta!=""){
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text( "Falta "+falta)));
                          }else{
var pref = await SharedPreferences.getInstance();
bool go = true;
   /* if(pref.getString("action")=="low"){
       var response = await http.get(Uri.parse("${Config.ipadress}/api/UserRecipeList/"+pref.getInt("id").toString()));
  var data = jsonDecode(response.body);
  int amo = 0;
  for(var item in data){
    amo+=1;
  }
  if(amo>1){
    go = false;
    context.read<FinishCreating>().setProcess(false);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Lamento mas só pode ter 1 Receia !"), action: SnackBarAction(textColor: Colors.green, label: 'Comprar', onPressed: (){
      showDialog(context: context, builder: (_)=> SizedBox(
        height: 200,
        child: AlertDialog(
          title: Text("Comprar"),
          content: Center(
            child: Text("Vamos comparar !"),
          ),
        ),
      ));
    },),),);
  }
    }*/

    if(go){

                            bool createReceipe = false, uploadTrailer = false, uploadLearn=false, enableTags = false;
                            context.read<FinishCreating>().setProcess(true);


                            //Data for Recipe
                            String frases = "";

                            for(RecipeSteps recipeSteps in CreateReceita.lista_passos){
                              String frase = "STAR"
                                  +(recipeSteps.obrigatorio? "1" : "0")
                                  +"STAR";

                              for(RecipeStepTimeout timeout in Config.list_recipe_Step_Timeout){
                                if(timeout.idStepbefore==(recipeSteps.id)){
                                  frase+="TOUT"+timeout.idStepbefore.toString()+":"+timeout.hour.toString()+":"+timeout.minute.toString()+":"+timeout.name+"TOUT ";
                                }
                              }

                              if(!recipeSteps.frase.isEmpty){


                                for(RecipeIngredientModel recipeIngredientModel in recipeSteps.frase){
                                  if(recipeIngredientModel.amount>0){
                                    frase+="?ID"+recipeIngredientModel.id.toString()+"*"+recipeIngredientModel.name+"*"+recipeIngredientModel.amount.toString()+"*"+recipeIngredientModel.measure.toString()+"? ";
                                  }else{
                                    frase+=recipeIngredientModel.name+" ";
                                  }

                                }  }
                              frase= frase.substring(0,frase.length-1);
                              frases+= frase+"#STEP#";
                            }
                            frases= frases.substring(0,frases.length-6);


                            if(widget.RecipeID==-1){

                              var prefer = await SharedPreferences.getInstance();

                              list_Settings[1].check= !list_Settings[1].check;
                              list_Settings[2].check= !list_Settings[2].check;

                              http.Response res= await http.post(Uri.parse("${Config.ipadress}/api/createRecipe"),body: {



                                "name": CreateReceita.edit_name.text,
                                "idUser": prefer.getInt("id").toString(),
                                "description": CreateReceita.edit_description.text,
                                "category": CreateReceita.sop_selected.toString(),
                                "steps" : frases,
                                "people" : CreateReceita.edit_people.text.toString(),
                                "show" : list_Settings[0].check.toString(),
                                "comments" : list_Settings[1].check.toString(),
                                "edit_steps" : list_Settings[2].check.toString(),
                                "exports" : list_Settings[3].check.toString(),
                              });

                              var response = jsonDecode( res.body);

                              if(response["ans"]=="Sucess"){
                                createReceipe= true;

                              }


                              //Trailer
                              print("id of new recipe ${response["id"]}");


                              if(CreateReceita.tags.isNotEmpty){
                                String alltags ="";

                                for(var item in CreateReceita.tags){
                                  alltags+=item+",";
                                }
                                alltags =    alltags.substring(0, alltags.length-1);
                                http.Response resss= await http.post(Uri.parse("${Config.ipadress}/api/tags"),body: {
                                  "idRecipe": response["id"].toString(),
                                  "tags" : alltags
                                });
                                if(jsonDecode(resss.body)["ans"]=="Success"){
                                  enableTags = true;
                                }
                              }
                              Media media = CreateReceita.trailer.last;

                              if(media.path!=""){
                                print("iniciando upload trailer 1");
                                var request = http.MultipartRequest('POST', Uri.parse(Config.ipadress+"/api/uploadfile"));

                                request.fields["name"]=response["id"].toString();

                                request.fields["type"]="recipe";

                                request.files.add(
                                    http.MultipartFile(
                                        'file',
                                        File(media.path).readAsBytes().asStream(),
                                        File(media.path).lengthSync(),
                                        filename: "trailer"+".mp4"
                                    )
                                );
                                http.StreamedResponse res = await request.send();
                                if(res.statusCode==200){
                                  print("SUCESSO");
                                  uploadTrailer = true;




                                  //Ensinar
                                  if(CreateReceita.ensinar.isNotEmpty){
                                    Media learn = CreateReceita.ensinar.last;

                                    if(learn.path!=""){
                                      var request = http.MultipartRequest('POST', Uri.parse(Config.ipadress+"/api/uploadfile"));

                                      request.fields["name"]=response["id"].toString();
                                      request.fields["type"]="recipe";

                                      request.files.add(
                                          http.MultipartFile(
                                              'file',
                                              File(learn.path).readAsBytes().asStream(),
                                              File(learn.path).lengthSync(),
                                              filename: "ensinar"+".mp4"
                                          )
                                      );
                                      var res = await request.send();
                                      if(res.statusCode==200){
                                        uploadLearn = true;
                                        print("success learn ");
                                      }else{
                                        print("error learn ");

                                      }
                                    }
                                  }
                                }else{
                                  print("erroe "+res.reasonPhrase.toString());
                                }

                                createReceipe= true;

                              }










                              if(createReceipe  && uploadTrailer ){
                                CreateReceita.sop_selected = 0;
                                CreateReceita.edit_name.text = "";
                                CreateReceita.edit_description.text ="";
                                CreateReceita.trailer.clear();
                                CreateReceita.ensinar.clear();
                                CreateReceita.lista_passos.clear();
                                CreateReceita.tags.clear();

                                final preferences = await SharedPreferences.getInstance();
                                preferences.remove("ingredients");
                                Navigator.pop(context);
                              }else{
                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text( !createReceipe? "Erro ao criar receita" : !uploadLearn ? "Erro upload mídia learn" : !uploadTrailer ? "Erro upload mídia trailer" :"Success")));

                              }
                            }else{
                              http.Response res= await http.post(Uri.parse("${Config.ipadress}/api/updateRecipe"),body: {
                                "id" : widget.RecipeID.toString(),
                                "name": CreateReceita.edit_name.text,
                                "description": CreateReceita.edit_description.text,
                                "category": CreateReceita.sop_selected.toString(),
                                "steps" : frases,
                                "people" : CreateReceita.edit_people.text.toString(),
                                "show" : list_Settings[0].check.toString(),
                                "comments" : list_Settings[1].check.toString(),
                                "edit_steps" : list_Settings[2].check.toString(),
                                "exports" : list_Settings[3].check.toString(),
                              });

                              var response = jsonDecode( res.body);

                              if(response["ans"]=="Sucess"){
                                createReceipe= true;

                              }


                              //Trailer

                              if(CreateReceita.trailer.isNotEmpty){

                                Media media = CreateReceita.trailer.last;

                                if(media.path!=""){

                                  var deleteFile = await   http.post(Uri.parse(Config.ipadress+"/api/deletefile"), body: {
                                    "name" : widget.RecipeID,
                                    "file" : "trailer.mp4"
                                  });

                                  var convert = jsonDecode(deleteFile.body);
                                  if(convert["ans"].toString()=="Success"){
                                    var request = http.MultipartRequest('POST', Uri.parse(Config.ipadress+"/api/uploadfile"));

                                    request.fields["name"]=response["id"].toString();

                                    request.fields["type"]="recipe";
                                    request.fields["action"]="update";

                                    request.files.add(
                                        http.MultipartFile(
                                            'file',
                                            File(media.path).readAsBytes().asStream(),
                                            File(media.path).lengthSync(),
                                            filename: "trailer"+".mp4"
                                        )
                                    );
                                    http.StreamedResponse res = await request.send();
                                    if(res.statusCode==200){
                                      uploadTrailer = true;
                                    }
                                    createReceipe= true;

                                  }else{
                                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Não foi possivel elimianr T")));
                                  }
                                }
                              }else{
                                uploadTrailer = true;
                              }



                              Media learn;

                              //Ensinar
                              if(CreateReceita.ensinar.isNotEmpty){
                                learn   = CreateReceita.ensinar.last;

                                if(learn.path!=""){


                                  var deleteFile = await   http.post(Uri.parse(Config.ipadress+"/api/deletefile"), body: {
                                    "name" : widget.RecipeID,
                                    "file" : "ensinar.mp4"
                                  });

                                  var convert = jsonDecode(deleteFile.body);
                                  if(convert["ans"].toString()=="Success"){
                                    var request = http.MultipartRequest('POST', Uri.parse(Config.ipadress+"/api/uploadfile"));

                                    request.fields["name"]=response["id"].toString();
                                    request.fields["type"]="recipe";
                                    request.fields["action"]="update";

                                    request.files.add(
                                        http.MultipartFile(
                                            'file',
                                            File(learn.path).readAsBytes().asStream(),
                                            File(learn.path).lengthSync(),
                                            filename: "ensinar"+".mp4"
                                        )
                                    );
                                    var res = await request.send();
                                    if(res.statusCode==200){
                                      uploadLearn = true;
                                    }
                                  }else{
                                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Não foi possivel elimianr E")));

                                  }

                                }
                              }else{
                                uploadLearn = true;
                              }






                              if(createReceipe  && uploadTrailer){
                                context.read<FinishCreating>().setProcess(false);

                                final preferences = await SharedPreferences.getInstance();
                                preferences.remove("ingredients");

                                CreateReceita.sop_selected = 0;
                                CreateReceita.edit_name.text = "";
                                CreateReceita.edit_description.text ="";
                                CreateReceita.trailer.clear();
                                CreateReceita.ensinar.clear();
                                CreateReceita.lista_passos.clear();
                                Navigator.pop(context);
                              }else{
                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text( !createReceipe? "Erro ao criar receita" : !uploadLearn ? "Erro upload mídia learn" : !uploadTrailer ? "Erro upload mídia trailer" :"Success")));

                              }
                            }

    }
                          }

                        },),
                    ),
                 ),
                 value.getProcess()? CircularProgressIndicator(): Container()
               ],
             );
            },

          ),
        ],
      ),
    );
  }
}