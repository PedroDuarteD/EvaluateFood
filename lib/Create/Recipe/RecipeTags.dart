import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import 'index.dart';

class RecipeTags extends StatefulWidget {
  const RecipeTags({super.key});

  @override
  State<RecipeTags> createState() => _RecipeTagsState();
}

class _RecipeTagsState extends State<RecipeTags> {

   TextEditingController tag = new TextEditingController();

  @override
  Widget build(BuildContext context) {
    return  Column(
        children: [
  SizedBox(
    height: 20,
  ),
          Container(
            margin: EdgeInsets.only(left: 20),
            child: Row(
            children: [
              Text("Adicione Tags",style: TextStyle(color: Colors.black,fontSize: 20),),
              Text("#",style: TextStyle(color: Colors.blue, fontSize: 20),)
            ],
        ),
          ),
          SizedBox(
            height: 20,
          ),
        DottedBorder(
        color: Colors.black,
        radius: Radius.circular(50),
        child: Container(
          padding: EdgeInsets.only(top: 5,bottom: 5, right: 10, left: 10),
          decoration: BoxDecoration(
              color: Color.fromRGBO(255, 184, 0, .19)
          ),
          child:  Text("Pode adicionar tags para ajudar a encontrar a receita"),
        ),
      ),

          SizedBox(
            height: 20,
          ),
          Container(
            width: 80.w,
            height: 200,
            padding: EdgeInsets.all(5),
            decoration: BoxDecoration(
              border: Border.all(color: Color.fromRGBO(0, 0, 0, .10))
            ),
            child: Wrap(
              children: CreateReceita.tags.map((e) {
                return Container(
                  padding: EdgeInsets.all(5),
                  margin: EdgeInsets.only(right: 5),
                  decoration: BoxDecoration(
                      border: Border.all(color: Colors.black),
                      borderRadius: BorderRadius.circular(10)
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text("#",style: TextStyle(color: Colors.blue),),
                      Text(e)
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
          SizedBox(
            height: 20,
          ),
          Container(
            margin: EdgeInsets.only(left: 20, right: 20),
            height: 45,
            child: TextField(
              keyboardType:  TextInputType.text,

              decoration: InputDecoration(
                  labelText: "Tag",
                  prefixIcon: Icon( Icons.tag,color: Colors.blue,),
                  border: OutlineInputBorder(
                  )
              ),
              controller:  tag,
            ),
          ),

              Container(
                margin: EdgeInsets.only(right: 20,left: 20,top: 20),
                width: 100.w,
                height: 40,
                child: ElevatedButton(onPressed: (){
                if(tag.text.isEmpty){
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Não tem nada na Tag !")));
                }else{
                  setState(() {
                    CreateReceita.tags.add(tag.text);
                  });
                  tag.text="";

                }
                }, child: Text("Guardar")),
              ),

        ],

    );
  }
}
