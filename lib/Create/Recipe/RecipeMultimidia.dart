import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:images_picker/images_picker.dart';
import 'package:http/http.dart' as http;
import 'package:evaluatefood/Config/appConfig.dart';
import 'index.dart';

class RecipeMultimidia extends StatefulWidget {

  int RecipeID =-1;

  RecipeMultimidia(this.RecipeID);

  @override
  State<RecipeMultimidia> createState() => _RecipeMultimidiaState();
}

class _RecipeMultimidiaState extends State<RecipeMultimidia> {

  @override
  Widget build(BuildContext context) {
    return  Column(
      children: [

        SizedBox(
          height: 40,
        ),
        Padding(
          padding: const EdgeInsets.only(right: 20, left: 20),
          child: Row(

            children: [
              Text("Multimídia",style: TextStyle(fontSize: 20),),
              Icon(Icons.videocam)
            ],
          ),
        ),

        SizedBox(
          height: 40,
        ),

        DottedBorder(
          color: Colors.black,
          radius: Radius.circular(50),
          child: Container(
            padding: EdgeInsets.only(top: 5,bottom: 5, right: 10, left: 10),
            decoration: BoxDecoration(
                color: Color.fromRGBO(255, 184, 0, .19)
            ),
            child: Wrap(
              children: [
                Text("Vídeo rápido,",style: TextStyle(fontWeight: FontWeight.bold),),
                Text("com "),
                Text("o resultado final", style: TextStyle(fontWeight: FontWeight.bold),),
              ],
            ),
          ),
        ),
        SizedBox(
          height: 10,
        ),
        Container(
          width: MediaQuery.of(context).size.width-40,
          child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                foregroundColor: Colors.green,
                side: BorderSide(color: Colors.green)
              ),
              onPressed: () async {
                await ImagesPicker.pick(
                  count: 1,
                  quality: 0.9,
                  pickType: PickType.video,
                ).then((value) {  
                  setState(() {
                    CreateReceita.trailer =value!;
                  });
                });
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,

                children: [
                  Text("*",style: TextStyle(color: Colors.red),),
                  SizedBox(width: 20,),
                  Text("Selecione Trailer",style: TextStyle( color: Colors.green),),
                ],
              )),
        ),

SizedBox(
  height: 5,
),
       CreateReceita.trailer.isNotEmpty? Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.done, color: Colors.blue,),
            Text("Vídeo Carregado",style: TextStyle(color: Colors.blue),),
          ],
        ) : Container(),
        SizedBox(
          height: 50,
        ),












        DottedBorder(
          color: Colors.black,
          radius: Radius.circular(50),
          child: Container(
            width: 200,
            padding: EdgeInsets.only(top: 5,bottom: 5, right: 10, left: 10),
            decoration: BoxDecoration(
                color: Color.fromRGBO(255, 184, 0, .19)
            ),
            child: Wrap(
              children: [
                Text("Vídeo com "),
                Text("todos os passos ",style: TextStyle(fontWeight: FontWeight.bold),),
                Text("para melhor compreensão"),
              ],
            ),
          ),
        ),
        SizedBox(
          height: 10,
        ),
        Container(
          width: MediaQuery.of(context).size.width-40,
          child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.green,
                  side: BorderSide(color: Colors.green)
              ),
              onPressed: () async {
                await ImagesPicker.pick(
                  count: 1,
                  quality: 0.9,
                  pickType: PickType.video,
                ).then((value) {
                  setState(() {
                    CreateReceita.ensinar =value!;
                  });
                });
              },
              child: Text("Selecione Vídeo",style: TextStyle( color: Colors.green),)),
        ),

        SizedBox(
          height: 5,
        ),


         CreateReceita.ensinar.isNotEmpty? Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.done, color: Colors.blue,),

            Text("Vídeo Carregado",style: TextStyle(color: Colors.blue),),
          ],
        ) : Container(),














/*

        Text("Vídeo com todos os passos para melhor compreensão"),
        SizedBox(
          height: 5,
        ),
        Container(
          width: MediaQuery.of(context).size.width,
          child:
          ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green
              ),
              onPressed: () async {
                await ImagesPicker.pick(
                  count: 1,
                  quality: 0.9,
                  pickType: PickType.video,
                ).then((value) {
                  setState(() {
                    CreateReceita.ensinar = value!;
                  });
                });

              },
              child: Text("Selecione Vídeo",style: TextStyle( color: Colors.black),)),

        ),
        CreateReceita.ensinar.isNotEmpty? Text("Vídeo selecionado !",style: TextStyle(color: Colors.green),) : Container(),*/
      ],
    );
  }
}
