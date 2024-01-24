import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:evaluatefood/Config/appConfig.dart';
import 'package:evaluatefood/Model/Receita/RecipeIngredient.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
class IngredientController extends StatefulWidget {

  @override
  State<IngredientController> createState() => _IngredientControllerState();
}

class _IngredientControllerState extends State<IngredientController> {
 late   SharedPreferences sharedPreferences ;

 Future Instanciar()async{
  sharedPreferences = await SharedPreferences.getInstance();
 }
  bool sim =true;
 @override
 void initState(){
  super.initState();
  Instanciar();
 }
    List<RecipeIngredientModel> list = [];

  Future<List<RecipeIngredientModel>> ListAllIngredient()async{

         list.clear();



    var data = await http.get(Uri.parse(Config.ipadress+"/api/list_ingredient_preview"));
    var data_c = jsonDecode(data.body);

    for(var ing in data_c){
      
     RecipeIngredientModel r= new RecipeIngredientModel.Show(ing["id"], ing["nome"], ing["verificado"] ==1 ? true : false, ing["userID"]);
     if(_edit_ing_search.text==""){
      list.add(r);
      print("add");
     }else{
      if(r.name.toLowerCase().contains(_edit_ing_search.text.toLowerCase())){
      list.add(r);

      }
     }
    
    }

    return list;

  }

  TextEditingController _edit_ing = new TextEditingController();
  TextEditingController _edit_ing_search = new TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Ingredientes"),
      ),
      body: Container(
        margin: EdgeInsets.only(right: 10,left: 10,top: 20),
        child: Column(
          children: [

              Container(
                height: 45,
                child: TextField(
                  controller: _edit_ing_search,
                  onChanged: (value) {
                    setState(() {

                    });
                  },
                  decoration: InputDecoration(
                    label: Text("Procurar ingrediente: "),
                    filled: true,
                    fillColor: Color.fromRGBO(222, 222, 222, .100),
                    border: OutlineInputBorder()
                  ),
                ),
              ),
      
            FutureBuilder<List<RecipeIngredientModel>>(
              future: ListAllIngredient(),
              builder: ((context, snapshot) {
                if(snapshot.connectionState==ConnectionState.done || snapshot.connectionState==ConnectionState.active){
      
                  if(snapshot.data!.isEmpty){
                    return Container(
                      margin: EdgeInsets.only(top: 20),
                      child: Center(
                        child: Text("Ainda não tem ingredientes !"),
                      ),
                    );
                  }else{
                       return ListView.builder(
                    shrinkWrap: true,
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, position){
                        RecipeIngredientModel ing = snapshot.data![position];
                        if(!ing.active){
                           return Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                               children: [
                                 Text(ing.name , style: TextStyle(color: ing.active? Colors.blue: Colors.black),),




                                 sharedPreferences.getString("action") !="low" && !ing.active ?
                                 ElevatedButton(
                                     style: ElevatedButton.styleFrom(
                                       backgroundColor: Colors.white,
                                       foregroundColor: Colors.green,
                                       side: BorderSide(color: Colors.green)
                                     ),
                                     onPressed: ()async{
                                    var res = await http.post(Uri.parse("${Config.ipadress}/api/udpate_verify_ingrediente"),body: {
                                      "id" : ing.id.toString()
                                    });
                                    if(jsonDecode(res.body)["res"]=="Sucesso"){
                                      setState(() {
                                        
                                      });
                                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Sucesso")));
                                    }else{
                                         ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Ingrediente não foi encontrado")));
                                    }
                                 }, child: Text("Verificar",style: TextStyle(color: Colors.green),)) : Container(
                                   width: 20,
                                   height: 20,
                                   decoration: BoxDecoration(
                                     borderRadius: BorderRadius.circular(10),
                                     color: ing.active ? Colors.green : Colors.grey,

                                   ),
                                 ),



                                 IconButton(
                                     style: IconButton.styleFrom(
                                       backgroundColor: Colors.white,
                                       side: BorderSide(color: Colors.red)
                                     ),
                                     onPressed: ()async{
                                    var data = await http.post(Uri.parse(Config.ipadress+"/api/delete_ingrediente"),body: {
                                      "id" : ing.id.toString(),
                                      "nome" : ing.name
                                    });
      
                                    if(jsonDecode(data.body)["res"]=="Sucesso"){
                                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Sucesso")));
                                      setState(() {
                                            list.clear();
                                        });
                                    }else{
                                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(jsonDecode(data.body)["ans"])));
                                    }
                                 }, icon: Icon(Icons.delete,color: Colors.red,))
                               ],
                             );
                        }else{
                        return Text(ing.name , style: TextStyle(color: ing.active? Colors.blue: Colors.black));


                        }
                  });
                  }
               
                }else{
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }
              }),
          ),
          ],
        ),
      ),floatingActionButton: FloatingActionButton(onPressed: ()async{

      return showDialog(context: context, builder: (context) {
          return AlertDialog(
            title: Text("Adicionar"),
            content: Container(
              height: 118,
              child: Column(
                children: [
                  Container(
                    margin: EdgeInsets.only(bottom: 10),
                    child: TextField(
                      controller: _edit_ing,
                      decoration: InputDecoration(
                        label: Text("Nome")
                      ),
                    ),
                  ),
                      
                  Container(
                    width: MediaQuery.of(context).size.width,
                    child: ElevatedButton(onPressed: ()async{
                      if(_edit_ing.text.isEmpty){
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Tem de escrever o nome !")));
                      }else{
                        var caractere = _edit_ing.text.characters.first;
                        String lastLetters = "";
                        if(_edit_ing.text.characters.last==" "){

                        lastLetters =  _edit_ing.text.substring(1, _edit_ing.text.length);
                        }else{
                          lastLetters = _edit_ing.text.substring(1);
                        }

                         var data =  await  http.post(Uri.parse("${Config.ipadress}/api/create_ingrediente"), body: {
                      "nome" : caractere.toUpperCase()+lastLetters,
                      "userid" : sharedPreferences.getInt("id").toString()
                      });
                        
                                  if(jsonDecode(data.body)["res"]=="Sucesso"){
                    Navigator.pop(context);
                    _edit_ing.text="";
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Sucesso")));
                        setState(() {
                        list.clear();
                        });
                                  }else{
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error")));
                        
                                  }
                      }
                                 
                        
                        
                    }, child: Text("Adicionar")),
                  )
                ],
              ),
            ),
          
            
          );
      });
    
    },child: Icon(Icons.add),),);
  }
}