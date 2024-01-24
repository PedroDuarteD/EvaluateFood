import 'dart:convert';
import 'package:evaluatefood/Account/Flag/index.dart';
import 'package:flutter/material.dart';
import 'package:evaluatefood/Config/appConfig.dart';
import 'package:evaluatefood/Create/Recipe/index.dart';
import 'package:evaluatefood/Model/Receita/Recipe.dart';
import 'package:evaluatefood/Model/User/User.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class Account extends StatefulWidget {
  int iduser, idRecipe;
  bool myUser= true;
  Account(this.iduser, this.myUser, this.idRecipe);

  @override
  State<Account> createState() => _AccountState();
}

class _AccountState extends State<Account> {

  bool mostrar = false;



  Future<List<Recipe>> UserRecipeList()async{
  var response = await http.get(Uri.parse("${Config.ipadress}/api/UserRecipeList/"+widget.iduser.toString()
  ));
  print("id user novo: ${widget.iduser}");
  var data = jsonDecode(response.body);
  
  List<Recipe> listMyRecipes = [];
  for(var recipe in data["ans"]){
    listMyRecipes.add(Recipe(recipe["id"],recipe["idUser"],recipe["name"], recipe["desc"], recipe["show"]==1? true : false, recipe["comments"]==0? true : false, recipe["edit_steps"]==0? true : false,recipe["likes"], recipe["like"],[]));
  }
  print("res: ${listMyRecipes.length}");
  return listMyRecipes;
  }

  Future UpdateShowRecipe(int idRecipe, bool show)async{
  var res =await  http.post(Uri.parse("${Config.ipadress}/api/UserUpdateShow/"+
   "1" 
   //{idUser}
   +"/${idRecipe}/"+(show.toString()=="true"? 1: 0).toString()));
  print("S: "+show.toString());
  var convert = jsonDecode(res.body);

  if(convert["ans"]){
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Success")));
  }else{
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error")));

  }


  }

  Future logout()async{
  SharedPreferences sharedPreferences =await SharedPreferences.getInstance();
  sharedPreferences.remove("id");
  sharedPreferences.remove("name");
  sharedPreferences.remove("email");
  sharedPreferences.remove("action");
  }

  int selecionado = -1;

 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(241, 239, 239, 1),
      appBar: AppBar(title: Text("Evaluate Food"),actions: [
           ElevatedButton(onPressed: (){ 
             if(widget.myUser){
                 Navigator.pop(context);
    logout();
             } else{
                Navigator.push(context, MaterialPageRoute(builder: (_) => AccountFlag(widget.iduser, widget.idRecipe)));
             }
            }, child: Icon( widget.myUser? Icons.logout : Icons.flag,color: Colors.red,))

      ],),
      body: Column(children: [
        Container(
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
            color: Color.fromRGBO(0, 0, 0, 36),
            borderRadius: BorderRadius.only(bottomRight: Radius.circular(25), bottomLeft: Radius.circular(25))
          ),
          child: SizedBox(
             height: 200,
              width: 150,
            child: Image.network("${Config.ipadress}/uploads/profiles/${widget.iduser}/profile.png"),
          ),
        ),
      
      
        Container(
            color: Color.fromRGBO(151, 151, 151, 0.098),
          padding: EdgeInsets.only(left: 20,right: 20,bottom: 10),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 10, bottom: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text( widget.myUser?"Minhas Receitas": "Receitas",style: TextStyle(fontWeight: FontWeight.bold)),
                 widget.myUser?   ElevatedButton(onPressed: (){
                       Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=> CreateReceita(user: widget.iduser)));
                    }, child: Row(
                      children: [
                        Text("Nova"),
                        Icon(Icons.add)
                      ],
                    )) : Container()
                  ],
                ),
              ),

 

            ],
          ),
        ),
        
       Container(
          padding: EdgeInsets.only(right: 20,left: 20),
          child: FutureBuilder<List<Recipe>>(
            future: UserRecipeList(),
            builder: (context,data){
              if(data.connectionState==ConnectionState.active|| data.connectionState==ConnectionState.done){
                if(data.requireData.isEmpty){
                  return Center(
                    child: Text("Ainda não tem receitas !"),
                  );
                }else{
                    return Column(
                      children: [
                        SingleChildScrollView(
                          child: SizedBox(
                              width: MediaQuery.of(context).size.width,
                        height: 400,
                            child: ListView.builder(

                              itemCount: data.data!.length,
                                      shrinkWrap: true,
                                      itemBuilder: (context, index) {

                                        Recipe recipe = data.data![index];
                                        return Container(
                                          margin: EdgeInsets.only(top: 20),
                                          child: GestureDetector(
                                            onTap: () {
                                               if(widget.myUser){

                                              
                                              setState(() {
                                                if(selecionado==-1){
                                                  selecionado = recipe.id;

                                                }else{
                                                  selecionado = -1;
                                                }
                                              });}
                                            },
                                            child: Container(
                                                                decoration: BoxDecoration(
                                                                  color: Colors.white,
                                                                  borderRadius: BorderRadius.circular(5),
                                                                  border: Border.all(color: selecionado== recipe.id ? Colors.green : Colors.white)
                                                                ),
                                              child: Column(
                                                              children: [
                                                                Container(
                                              padding: EdgeInsets.all(8),

                                                                  child: Column(
                                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                                    children: [
                                                                      SizedBox(height: 10,),

                                                                       Text(recipe.name,style: TextStyle(fontWeight: FontWeight.bold,fontSize: 20),),
                                                                      SizedBox(height: 10,),
                                                                      Row(
                                                                        mainAxisAlignment: MainAxisAlignment.start,
                                                                        children: [

                                                                        Container(
                                          child: Row(children: [
                                            Text(recipe.likes.toString(),style: TextStyle( color: Color.fromRGBO(0, 178, 255, 100),),),
                                            Icon(Icons.thumb_up, color: Color.fromRGBO(0, 178, 255, 100),),
                                          ]),
                                                                        ),








                                                                      ]),
                                                                    ],
                                                                  ),
                                                                ),
                                                                selecionado == recipe.id?
                                                                Container(
                                                                  color: Color.fromRGBO(151, 151, 151, 0.098),
                                                                  padding: EdgeInsets.only(right: 5,left: 5),
                                                                  child: Row(
                                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                    children: [
                                                                        ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.white
                                          ),
                                          onPressed: (){
                                            if(widget.myUser){
                                                setState(() {
                                              selecionado = 0;
                                            });
                                            UpdateShowRecipe(recipe.id, !recipe.show);
                                            }
                                          
                                          }, child: Row(children: [
                                          Text("Mostrar ",style: TextStyle(color: recipe.show? Color.fromRGBO(0, 178, 255, 100) : Colors.black),),
                                          Icon(Icons.remove_red_eye,color: recipe.show? Color.fromRGBO(0, 178, 255, 100) : Colors.black)
                                                                        ],)),
                                          ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.blue,
                                            foregroundColor: Colors.white,
                                          ),
                                          onPressed: (){
                                            Navigator.push(context, MaterialPageRoute(builder: (_)=> CreateReceita(user: widget.iduser,recipeId: recipe.id,)));
                                          }, child: Row(children: [
                                          Text("Editar ",style: TextStyle(color: Colors.white),),
                                          Icon(Icons.edit,color: Colors.white)
                                                                        ],))
                                                                    ],
                                                                  ),
                                                                ) : Container()
                                                              ],
                                              ),
                                            ),
                                          ),
                                        );
                                      },

                                    ),
                          ),
                        ),
                        Container(
                            padding: EdgeInsets.only(top: 5,bottom: 5, right: 10, left: 10),
                            decoration: BoxDecoration(
                              color: Colors.orange,
                            ),
                            child: Text("Pressione uma receita para mais opções"))
                      ],
                    );
                }
              
              }else{
                return Center(
                  child: CircularProgressIndicator(),
                );
              }
            }),
        ),

        
      
      ],),
    );
  }
}