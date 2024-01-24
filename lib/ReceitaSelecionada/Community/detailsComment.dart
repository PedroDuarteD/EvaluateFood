import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:evaluatefood/Config/appConfig.dart';
import 'package:evaluatefood/Model/Receita/RecipeComments.dart';
import 'package:evaluatefood/Model/Receita/RecipeIngredient.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../Model/Receita/RecipeStepsComment.dart';

class DetailsComment extends StatelessWidget {

  String idRecipe="",idComment="", nameRecipe="", nameUser="";
  DetailsComment(this.idRecipe,this.idComment,this.nameUser , this.nameRecipe);

  int steps = 1;
  int views = 0;




  Future<CommentDetail> getCommentDetails()async{
    
    late CommentDetail comments;
    print("1");


    var preferences = await SharedPreferences.getInstance();
    var detailsrequest = await http.get(Uri.parse("${Config.ipadress}/api/RecipeCommentDetail/${idRecipe}/${idComment}/${preferences.containsKey("id")? preferences.getInt("id").toString() : -1}"));

    var convert = jsonDecode(detailsrequest.body);

    for(var detail in convert){

        List<RecipeStepsComment> allsteps = [];
        List<RecipeIngredientModel> steps = [];
        List<RecipeIngredientModel> steps_before = [];

int index =0;


      for(var d in detail["steps"]){
        int like =0,  dislike=0;
        int already = -1;
        if(index==d["index"]){
           for(var s in d["step"]){
             print("phrase: ${s["phrase"]}");
         List<RecipeIngredientModel> l =  Config.ConvertStringStepToListIngredients(d["idStep"]==null ? -1 : d["idStep"], s["phrase"])   ;
             like = s["like"];
             dislike = s["dislike"];
             if(s["already"]!=-1){
               already = s["already"];
             }
             steps.addAll(l) ;
             print("7");
          }

           print("8");


              for(var s in d["before"]){



               if(s["amount"]>0){
                 print("9");

            steps_before.add(new RecipeIngredientModel.Ingredient(0 , 0, s["id"], s["amount"], s["measure"], s["name"]));

          }else{
            steps_before.add(new RecipeIngredientModel.Word(0,s["name"]));

          }
          }

           print("10");

         allsteps.add(RecipeStepsComment(index,steps, steps_before, d["idStep"]==null ? -1:d["idStep"], d["modified"],  like, dislike, already));
        steps = [];
        steps_before=[];
        }

        print("11");



        index+=1;

      }
        print("12");



         comments= new CommentDetail(detail["id"], detail["views"], detail["idUser"], detail["message"], allsteps);

      print("13${comments.recipeSteps.isEmpty}");




    }
    print("14 ${comments.recipeSteps.length}");
    return comments;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(this.nameUser,style: TextStyle(fontSize: 15),),
            Text(this.nameRecipe,style: TextStyle(fontSize: 10),)
          ],
        ),
      ),
      body: FutureBuilder<CommentDetail>(
        future: getCommentDetails(),
        builder: (_, snapshot){
          if(snapshot.connectionState==ConnectionState.done || snapshot.connectionState==ConnectionState.active){
          if(snapshot.requireData.recipeSteps.isNotEmpty){
            return Padding(
              padding: const EdgeInsets.only( top: 15),
              child: Column(children: [
                Padding(
                  padding: const EdgeInsets.only(right: 20, left: 20,),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("${snapshot.data!.recipeSteps.length} Etapa${snapshot.data!.recipeSteps.length>1? 's': ''}"),
                      Row(children: [
                        Text("${snapshot.data!.view.toString()} ",style: TextStyle(fontSize: 10, color: Color.fromRGBO(0, 178, 255, 300)),),Icon(Icons.remove_red_eye, color: Color.fromRGBO(0, 178, 255, 300))
                      ],)
                    ],),
                ),
                SizedBox(
                    height: 15
                ),

                                 ListView.builder(
                                   shrinkWrap: true,
                                   itemCount: snapshot.data!.recipeSteps.length,
                                   itemBuilder: (_, position){
                                     return     RenderComment(
                                         position: position,

                                         commentDetail: new CommentDetail(snapshot.data!.id, snapshot.data!.view, snapshot.data!.idUser ,snapshot.data!.message,snapshot.data!.recipeSteps.map((comment) {
                                           return      RecipeStepsComment(comment.index,
                                               comment.now.map((e) {
                                                 if(e.amount>0){
                                                   return  RecipeIngredientModel.Ingredient(e.idfrase, e.idItem,e.id,e.amount,e.measure,e.name);
                                                 }else{
                                                   return RecipeIngredientModel.Word(e.idfrase, e.name);
                                                 }
                                               }).toList()
                                               ,      comment.before.map((e) {
                                                 if(e.amount>0){
                                                   return  RecipeIngredientModel.Ingredient(e.idfrase, e.idItem,e.id,e.amount,e.measure,e.name);
                                                 }else{
                                                   return RecipeIngredientModel.Word(e.idfrase, e.name);
                                                 }
                                               }).toList(), comment.idStep,comment.modified, comment.like, comment.dislike, comment.already);
                                         }).toList(),));
                                   },
                                 )






              ]),
            );
          }else{
            return Center(
              child: Text("Sem dados"),
            );
          }
          }else{
            return Center(child: CircularProgressIndicator(),);
          }
        },
      )
    );
  }
}

class RenderComment extends StatefulWidget {
  int position=0;
   late CommentDetail comment;

  RenderComment({required int position  ,required CommentDetail commentDetail}){
    this.position = position;
    this.comment = commentDetail;
  }

  @override
  State<RenderComment> createState() => _RenderCommentState();
}

class _RenderCommentState extends State<RenderComment> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border(left: BorderSide(width: 5,color: widget.comment.recipeSteps[widget.position].modified== 0? Colors.green :widget.comment.recipeSteps[widget.position].modified== 1? Colors.yellow :  Color.fromRGBO(239, 239, 239, 300)))
      ,    color: Color.fromRGBO(239, 239, 239, 300),

      ),
      margin: EdgeInsets.only(bottom: 15),
      padding: EdgeInsets.only(right: 20, left: 20, bottom: 8),
      child: Column(children: [
        Container(
          padding: EdgeInsets.only(top: 13,bottom: 13),

          child: Row(
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text("${(widget.position+1)}",style: TextStyle(fontSize: 15),),
                ],
              ),
              SizedBox(
                  width: 10
              ),

              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  widget.comment.recipeSteps[widget.position].before.length>0 ?      Opacity(
                    opacity: 0.5,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [   Text(widget.comment.recipeSteps[widget.position].idStep.toString()),
                        Container(
                          margin: EdgeInsets.only(left: 15),
                          child: Row(
                            children: widget.comment.recipeSteps[widget.position].before.map<Widget>((e){
                              // if(comment.recipeSteps[position].index==index){

                              if(e.amount>0){
                                return Container(
                                    color: Color.fromRGBO(0, 178, 255, 300),
                                    margin: EdgeInsets.only(right: 2,left: 2),
                                    padding: EdgeInsets.only(top: 5,bottom: 5,right: 10,left: 10),
                                    child: Text(e.amount.toString()+" "+e.name+" ",style: TextStyle(fontSize: 12, color: Colors.white)));

                              }else{
                                return Text(e.name+" ",style: TextStyle(fontSize: 12, color: Colors.black),);

                              }   /*  }else{
                                        return Container();
                                      }*/
                            }).toList(),
                          ),
                        ),

                      ],
                    ),
                  ) : Container(),
                  widget.comment.recipeSteps[widget.position].before.length>0 ?   SizedBox(
                      height: 10
                  ) : Container(),
                  Container(
                    margin: EdgeInsets.only(left: 15),
                    child: Row(
                      children: widget.comment.recipeSteps[widget.position].now.map<Widget>((e){

                        if(e.amount>0){
                          return Container(
                              color: Color.fromRGBO(0, 178, 255, 300),
                              margin: EdgeInsets.only(right: 2,left: 2),
                              padding: EdgeInsets.only(top: 5,bottom: 5,right: 10,left: 10),
                              child: Text(e.amount.toString()+" "+e.name+" ",style: TextStyle(fontSize: 12, color: Colors.black),));

                        }else{
                          return Text(e.name+" ",style: TextStyle(fontSize: 12, color: Colors.black),);

                        }

                      }).toList(),
                    ),
                  )
                ],
              )


            ],),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween
          ,children: [
          ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: Color.fromRGBO(217, 217, 217, 300)
              ),
              onPressed: ()async{

                var preferences = await SharedPreferences.getInstance();
                if(preferences.containsKey("id") ){

                  if(widget.comment.recipeSteps[widget.position].already!=0){
                    var addislike = await http.post(Uri.parse("${Config.ipadress}/api/likerecipe_commentStep_create"),body: {
                      "idCommentStep" :widget. comment.recipeSteps[widget.position].idStep.toString(),
                      "type": "0",
                      "iduser" : preferences.getInt("id").toString()
                    });

                    if(addislike.statusCode==200 && jsonDecode(addislike.body)["ans"]=="Success"){
                      setState(() {
                        if(widget.comment.recipeSteps[widget.position].already==1){
                          widget.comment.recipeSteps[widget.position].like -= 1;

                        }
                        widget.comment.recipeSteps[widget.position].dislike += 1;
                        widget.comment.recipeSteps[widget.position].already=0;
                      });
                    }
                  }
                }else{
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Necessário criar conta !")));
                }



              }, child: Row(
            children: [
              Text("${widget.comment.recipeSteps[widget.position].dislike}",style: TextStyle( color: Colors.white,),),
              SizedBox(width: 10,),
              Icon(Icons.thumb_down, color:widget. comment.recipeSteps[widget.position].already==0? Colors.red: Colors.white,)
            ],
          )),
          ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Color.fromRGBO(217, 217, 217, 300),
                //backgroundColor: Color.fromRGBO(0, 178,255,300)
              ),
              onPressed: ()async{
                var preferences = await SharedPreferences.getInstance();
                if(preferences.containsKey("id") ){
             if(widget.comment.recipeSteps[widget.position].already!=1){
               var addislike = await http.post(Uri.parse("${Config.ipadress}/api/likerecipe_commentStep_create"),body: {
                 "idCommentStep" :widget. comment.recipeSteps[widget.position].idStep.toString(),
                 "type": "1",
                 "iduser" : preferences.getInt("id").toString()
               });
               print("res: ${addislike.body}");
               if(addislike.statusCode==200 && jsonDecode(addislike.body)["ans"]=="Success"){
                 setState(() {
                   if(widget.comment.recipeSteps[widget.position].already==0){
                     widget.comment.recipeSteps[widget.position].dislike -= 1;

                   }
                   widget.comment.recipeSteps[widget.position].like += 1;
                   widget.comment.recipeSteps[widget.position].already=1;
                 });
               }
             }
                }else {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Necessário criar conta !")));
                }
              }, child: Row(
            children: [
              Text("${widget.comment.recipeSteps[widget.position].like}",style: TextStyle( color: Colors.white,),),
              SizedBox(width: 10,),

              Icon(Icons.thumb_up, color: widget.comment.recipeSteps[widget.position].already==1? Colors.red: Colors.white,)
            ],
          ))
        ],)

      ]),
    );
  }
}
