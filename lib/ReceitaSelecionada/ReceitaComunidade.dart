import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:evaluatefood/Config/appConfig.dart';
import 'package:evaluatefood/Create/Recipe/RecipeIngredientTree/RecipeIngredient.dart';
import 'package:evaluatefood/Model/Receita/RecipeComments.dart';
import 'package:evaluatefood/Model/Receita/RecipeIngredient.dart';
import 'package:evaluatefood/Model/Receita/RecipeSteps.dart';
import 'package:evaluatefood/Model/User/User.dart';
import 'package:evaluatefood/ReceitaSelecionada/Community/AddOneStep.dart';
import 'package:evaluatefood/ReceitaSelecionada/Community/ReplaceOneStep.dart';
import 'package:evaluatefood/ReceitaSelecionada/Community/detailsComment.dart';
import 'package:evaluatefood/ReceitaSelecionada/ReceitaPassos.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';

class ReceitaComunidade extends StatefulWidget {
  String idRecipe = "", nameRecipe = "";
  bool editSteps = false;

  ReceitaComunidade(this.idRecipe, this.nameRecipe, this.editSteps);

  @override
  State<ReceitaComunidade> createState() => _ReceitaComunidadeState();
}

class _ReceitaComunidadeState extends State<ReceitaComunidade> {
  TextEditingController edit_comentario = new TextEditingController();
  List<RecipeIngredientModel> list_ingrediente = [];

  Future<List<RecipeIngredientModel>> CarregarIngredientes() async {
    list_ingrediente.clear();
    var response =
        await http.get(Uri.parse(Config.ipadress + "/api/list_ingrediente"));

    for (var ingrediente in jsonDecode(response.body)) {
      list_ingrediente.add(RecipeIngredientModel.Ingredient(
          -1, -1, ingrediente["id"], 0, "Nn", ingrediente["nome"]));
    }
    return list_ingrediente;
  }

  List<bool> etapas = [false, false];

  String comentario = "";
  bool editar = false, selectSteps = false;

  Comment newComment = new Comment(1, -1, "", "", -1, 0, 0, 0, [], []);

  List<Comment> list_Messages = [];

  Future<List<RecipeSteps>> LoadAllSetps() async {
    if (Config.listStepsofRecipe.isEmpty) {
      var response = await http.get(
          Uri.parse("${Config.ipadress}/api/ListAllSteps/${widget.idRecipe}"));

      var response_convert = jsonDecode(response.body);
      print("load: ${response_convert.toString()}");
      for (var step in response_convert["steps"]) {
        RecipeSteps recipeSteps = new RecipeSteps(
            step["idStep"],
            Config.ConvertStringStepToListIngredients(
                step["idStep"], step["step"]),
            0,
            step["required"] == 1 ? true : false);
        Config.listStepsofRecipe.add(recipeSteps);
      }
    }

    return Config.listStepsofRecipe;
  }

  Future<List<Comment>> CarregarMensagensUsers() async {
    list_Messages.clear();

    final preferences = await SharedPreferences.getInstance();

    var res = await http.get(Uri.parse(
        "${Config.ipadress}/api/RecipeCommentList/${widget.idRecipe}/${preferences.containsKey("id") ? preferences.getInt("id").toString() : "-1"}"));

    for (var mensagem in jsonDecode(res.body)) {
      List<CommentStepState> allidsSteps = [];
      for (var item in mensagem["steps"]) {
        allidsSteps.add(CommentStepState(
            int.parse(
                item["idStep"] == null ? "-1" : item["idStep"].toString()),
            int.parse(item["editavel"].toString())));
      }

      List<CommentIngredientState> allingredients = [];
      for (var item in mensagem["ingredients"]) {
        allingredients.add(CommentIngredientState(
            int.parse(item["id"].toString()), item["name"]));
      }

      print("id ${mensagem["idUser"].toString()}");
      if (allidsSteps.isNotEmpty) {
        list_Messages.add(new Comment(
            mensagem["id"],
            int.parse(mensagem["idUser"].toString()),
            mensagem["name"],
            mensagem["message"],
            mensagem["user_selected"],
            mensagem["like"],
            mensagem["dislike"],
            mensagem["views"],
            allidsSteps,
            allingredients));
      } else {
        list_Messages.add(new Comment(
            mensagem["id"],
            int.parse(mensagem["idUser"].toString()),
            mensagem["name"],
            mensagem["message"],
            mensagem["user_selected"],
            mensagem["like"],
            mensagem["dislike"],
            mensagem["views"], [], []));
      }
    }
    return list_Messages;
  }

  Widget AlternarComentarioAndEtapas() {
    if (editar) {
      return Column(
        children: [
          selectSteps
              ? Container(
                  margin:
                      EdgeInsets.only(top: 20, bottom: 30, right: 20, left: 20),
                  child: Align(
                      alignment: Alignment.topLeft,
                      child: Text(
                        "Selecione etapas !",
                        style: TextStyle(fontSize: 15),
                      )))
              : Container(),
          selectSteps
              ? FutureBuilder<List<RecipeSteps>>(
                  future: LoadAllSetps(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.done ||
                        snapshot.connectionState == ConnectionState.active) {
                      return ListView.builder(
                        padding: EdgeInsets.only(right: 20, left: 20),
                        itemCount: snapshot.data!.length,
                        shrinkWrap: true,
                        itemBuilder: (context, index) {
                          RecipeSteps recipeWord = snapshot.data![index];

                          return Container(
                            color: Colors.white38,
                            child: Column(
                              children: [
                                Row(children: [
                                  Text(recipeWord.id.toString()),
                                  Spacer(
                                    flex: 3,
                                  ),
                                  Row(
                                    children: recipeWord.frase.map<Widget>(
                                      (e) {
                                        if (e.amount > 0) {
                                          return Container(
                                              margin: EdgeInsets.only(
                                                  right: 5, left: 5),
                                              padding: EdgeInsets.all(5),
                                              decoration: BoxDecoration(
                                                  color: Colors.blue),
                                              child: Text(
                                                e.amount.toString() +
                                                    " " +
                                                    e.name,
                                                style: TextStyle(
                                                    color: Colors.white),
                                              ));
                                        } else {
                                          return Text(e.name);
                                        }
                                      },
                                    ).toList(),
                                  ),
                                  Spacer(
                                    flex: 3,
                                  ),
                                  Checkbox(
                                      value: recipeWord.select,
                                      onChanged: (valor) {
                                        setState(() {
                                          recipeWord.select = valor!;
                                        });
                                      })
                                ]),
                              ],
                            ),
                          );
                        },
                      );
                    } else {
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                  })
              : ListView.builder(
                  itemCount: Config.listStepEdit.length,
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    RecipeSteps recipeWord = Config.listStepEdit[index];

                    return Container(
                      padding: EdgeInsets.only(top: 10,bottom: 10, ),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey)
                      ),
                      child: Column(
                        children: [
                          Row(children: [
                            Container(
                                margin: EdgeInsets.only(left: 10, right: 30),
                                child: Text((index + 1).toString())),
                            GestureDetector(
                              onLongPress: () {
                                Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                ReplaceOneStep(recipeWord)))
                                    .then((value) {
                                  setState(() {});
                                });
                              },
                              child: Row(
                                children: recipeWord.frase.map<Widget>(
                                  (e) {
                                    if (e.amount > 0) {
                                      return Container(
                                          margin: EdgeInsets.only(
                                              right: 5, left: 5, top: 10),
                                          padding: EdgeInsets.all(5),
                                          decoration:
                                              BoxDecoration(color: Colors.blue),
                                          child: Text(
                                            e.amount.toString() + " " + e.name,
                                            style:
                                                TextStyle(color: Colors.white),
                                          ));
                                    } else {
                                      return Text(e.name);
                                    }
                                  },
                                ).toList(),
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  ;
                                  Config.listStepEdit.removeAt(index);
                                });
                              },
                              child: Icon(
                                Icons.delete,
                                color: Colors.red,
                              ),
                            )
                          ]),
                        ],
                      ),
                    );
                  },
                )
        ],
      );
    } else {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FutureBuilder<List<Comment>>(
              future: CarregarMensagensUsers(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.active ||
                    snapshot.connectionState == ConnectionState.done) {
                  if (snapshot.requireData.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 20),
                      child: Center(
                        child: Text("Sem comentários "),
                      ),
                    );
                  } else {
                    return RenderChatCommunity(
                        widget.idRecipe, snapshot.data!, widget.nameRecipe);
                  }
                } else {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }
              }),
        ],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: AlternarComentarioAndEtapas(),
      ),
      // editar && selectSteps==false ?
      bottomSheet: Container(
        height: 70,
        padding: EdgeInsets.only(right: 20, left: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                !widget.editSteps
                    ? Container()
                    : GestureDetector(
                        child: Container(
                            height: 50,
                            width: 50,
                            decoration: BoxDecoration(
                                color: Color.fromRGBO(0, 178, 255, 1),
                                borderRadius: BorderRadius.circular(5)),
                            padding: EdgeInsets.all(5),
                            child: editar
                                ? Icon(Icons.close, color: Colors.white)
                                : Icon(
                                    Icons.edit,
                                    color: Colors.white,
                                    size: 30,
                                  )),
                        onTap: () async {
                          if (editar) {
                            setState(() {
                              comentario = edit_comentario.text;
                              editar = !editar;
                              selectSteps = false;
                            });
                          } else {
                            final account =
                                await SharedPreferences.getInstance();

                            if (edit_comentario.text.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text("Escreva comentário !")));
                            } else if (account.getInt("id") != null) {
                              setState(() {
                                editar = !editar;
                                selectSteps = true;
                              });
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text("Tens de ter conta !")));
                            }
                          }
                        },
                      ),
                selectSteps
                    ? Container()
                    : GestureDetector(
                        onTap: () async {
                          if (editar && selectSteps == false) {
                            final account =
                                await SharedPreferences.getInstance();
                            if (account.getInt("id") != null) {
                              Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => AddOneStep()))
                                  .then((value) {
                                setState(() {});
                              });
                            }
                          }
                        },
                        child: Container(
                          width: MediaQuery.of(context).size.width - 140,
                          height: 50,
                          child: TextField(
                            decoration: InputDecoration(
                                enabled: !editar,
                                fillColor: editar
                                    ? Color.fromRGBO(250, 250, 250, .03)
                                    : null,
                                filled: true,
                                suffixIcon: Icon(Icons.add,
                                    color: Color.fromRGBO(0, 178, 255, 1)),
                                border: OutlineInputBorder(
                                    borderSide: BorderSide.none),
                                label: Text(
                                  "Comentário",
                                  style: TextStyle(
                                      color:
                                          Color.fromRGBO(143, 143, 143, 100)),
                                )),
                            controller: edit_comentario,
                          ),
                        ),
                      ),
                selectSteps
                    ? Container()
                    : GestureDetector(
                        onTap: () async {
                          final account = await SharedPreferences.getInstance();

                          if (editar && account.getInt("id") != null) {
                            if (!edit_comentario.text.isEmpty) {
                              //Data for Recipe
                              String frases = "";

                              for (RecipeSteps recipeSteps
                                  in Config.listStepEdit) {
                                String frase = "=>" +
                                    ( recipeSteps.original == 2
                                        ? "-1"
                                        : recipeSteps.id.toString( )) +
                                    ":" +
                                    recipeSteps.original.toString() +
                                    "<-->";
                                if (!recipeSteps.frase.isEmpty) {
                                  for (RecipeIngredientModel recipeIngredientModel
                                      in recipeSteps.frase) {
                                    if (recipeIngredientModel.amount > 0) {
                                      frase += "?ID" +
                                          recipeIngredientModel.id.toString() +
                                          "*" +
                                          recipeIngredientModel.name +
                                          "*" +
                                          recipeIngredientModel.amount
                                              .toString() +
                                          "*" +
                                          recipeIngredientModel.measure +
                                          "? ";
                                    } else {
                                      frase += recipeIngredientModel.name + " ";
                                    }
                                  }
                                }
                                frase = frase.substring(0, frase.length - 1);
                                frases += frase + "#STEP#";
                              }
                              frases = frases.substring(0, frases.length - 6);

                              print("VERE" + frases.toString());
                              var response = await http.post(
                                  Uri.parse(
                                      "${Config.ipadress}/api/RecipeCommentCreate"),
                                  body: {
                                    "idRecipe": widget.idRecipe,
                                    "idUser": account.getInt("id").toString(),
                                    "comment": edit_comentario.text.toString(),
                                    "steps": frases.toString(),
                                  });
                              print("R: ${response.body}");
                              var men = jsonDecode(response.body)["ans"];
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(SnackBar(content: Text(men)));
                              edit_comentario.text = "";
                              setState(() {
                                editar = false;
                              });
                            }
                          } else {
                            var prefer = await SharedPreferences.getInstance();
                            if (prefer.getInt("id") != null) {
                              if (!edit_comentario.text.isEmpty) {
                                var response = await http.post(
                                    Uri.parse(
                                        "${Config.ipadress}/api/RecipeCommentCreate"),
                                    body: {
                                      "idRecipe": widget.idRecipe.toString(),
                                      "idUser": prefer.getInt("id").toString(),
                                      "comment": edit_comentario.text.toString()
                                    });
                                var men = jsonDecode(response.body)["ans"];
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(SnackBar(content: Text(men)));
                                edit_comentario.text = "";
                                setState(() {});
                              }
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content:
                                          Text("Tens de ter uma conta !")));
                            }
                          }
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
                            ))),
                selectSteps
                    ? SizedBox(
                        width: 20,
                      )
                    : Container(),
                selectSteps
                    ? Container(
                        width: 60.w,
                        height: 50,
                        child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    Color.fromRGBO(0, 178, 255, 1)),
                            onPressed: () {
                              Config.listStepEdit.clear();
                              for (RecipeSteps recipeSteps
                                  in Config.listStepsofRecipe) {
                                if (recipeSteps.select) {
                                  Config.listStepEdit.add(recipeSteps);
                                }
                              }

                              setState(() {
                                selectSteps = false;
                              });
                            },
                            child: Text("Próximo")),
                      )
                    : Container()
              ],
            ),

//list_Messages.last. ?

/*:

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


                      if( edit_comentario.text!="" && edit_comentario.text.characters.last!=" "){
                  edit_comentario.text += " "+recipeIngredientModel.name;
                      }else{
                     edit_comentario.text += recipeIngredientModel.name;
                      }

              edit_comentario.selection = TextSelection.fromPosition(TextPosition(offset: edit_comentario.text.length));
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
      ),*/
          ],
        ),
      ),
    );
  }
}

class MensagemUser extends StatelessWidget {
  String idRecipe = "", nameRecipe = "";
  Comment message_user;
  Function update;
  List<Comment> comments;

  MensagemUser(this.comments, this.idRecipe, this.message_user, this.nameRecipe,
      this.update);

  @override
  Widget build(BuildContext context) {
    print("id user -${message_user.idUser}.");
    return GestureDetector(
      onTap: () async {
        if (message_user.recipeSteps.length > 0) {
          var res = await http.post(Uri.parse(
              "${Config.ipadress}/api/updateViewRecipeComment/${message_user.id}"));
          if (jsonDecode(res.body)["ans"] == "Success") {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => DetailsComment(
                        this.idRecipe,
                        message_user.id.toString(),
                        message_user.name,
                        this.nameRecipe)));
          }
        }
      },
      child: Container(
        width: MediaQuery.of(context).size.width,
        margin: EdgeInsets.only(bottom: 15),
        height: 160,
        color: Color.fromRGBO(239, 239, 239, 300),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                child: Image.network(
                    "${Config.ipadress}/uploads/profiles/${message_user.idUser}/profile.png",
                    width: 65,
                    height: 160,
                    fit: BoxFit.cover),
              ),
              SizedBox(width: 10),
              Container(
                height: 140,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 15),
                    Text(
                      message_user.name,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 15),
                    Container(
                        width: MediaQuery.of(context).size.width - 150,
                        decoration: BoxDecoration(),
                        child: Text(
                          message_user.message,
                          style: TextStyle(fontSize: 10),
                        )),
                    message_user.recipeSteps.length > 0
                        ? Spacer(
                            flex: 1,
                          )
                        : SizedBox(height: 10),
                    message_user.recipeSteps.length > 0
                        ? Column(
                            children: [
                              Row(
                                children:
                                    message_user.recipeSteps.map<Widget>((e) {
                                  return GestureDetector(
                                    onTap: () {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                              SnackBar(content: Text("step")));
                                    },
                                    child: Container(
                                      padding: EdgeInsets.only(
                                          top: 2.5,
                                          bottom: 2.5,
                                          right: 10,
                                          left: 10),
                                      margin: EdgeInsets.only(left: 3),
                                      decoration: BoxDecoration(
                                          color: e.state==0? Color.fromRGBO(144, 238, 144, 1)
                                              : Color.fromARGB(
                                              217, 209, 209, 208),
                                          borderRadius:
                                              BorderRadius.circular(5)),
                                      child: Text(
                                        e.id.toString(),
                                        style: TextStyle(fontSize: 10),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              )
                            ],
                          )
                        : SizedBox(),
                    message_user.ingredients.length > 0
                        ? Column(
                            children: [
                              SizedBox(height: 5),
                              Row(
                                children:
                                    message_user.ingredients.map<Widget>((e) {
                                  return GestureDetector(
                                    onTap: () {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(SnackBar(
                                              content: Text("ingrediente")));
                                    },
                                    child: Container(
                                      padding: EdgeInsets.only(
                                          top: 2.5,
                                          bottom: 2.5,
                                          right: 10,
                                          left: 10),
                                      margin: EdgeInsets.only(left: 3),
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(5),
                                          color: Colors.white),
                                      child: Text(
                                        e.name.toString(),
                                        style: TextStyle(fontSize: 15),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              )
                            ],
                          )
                        : SizedBox(),
                    message_user.recipeSteps.length > 0
                        ? Container()
                        : Spacer(
                            flex: 1,
                          ),
                    message_user.recipeSteps.length > 0
                        ? Container()
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                height: 30,
                                width: 150,
                                child: GestureDetector(
                                  onTap: () async {
                                    final preferences =
                                        await SharedPreferences.getInstance();

                                    if (preferences.containsKey("id") &&
                                        comments
                                                .elementAt(comments
                                                    .indexOf(message_user))
                                                .alreadySelected !=
                                            0) {
                                      var favorite = await http.post(
                                          Uri.parse(
                                              "${Config.ipadress}/api/likerecipe_comment_create"),
                                          body: {
                                            "idcomment":
                                                message_user.id.toString(),
                                            "type": "0",
                                            "iduser": preferences
                                                .getInt("id")
                                                .toString(),
                                          });
                                      print("res: ${favorite.body}");
                                      if (favorite.statusCode == 200) {
                                        if (comments
                                                .elementAt(comments
                                                    .indexOf(message_user))
                                                .alreadySelected ==
                                            1) {
                                          comments
                                              .elementAt(comments
                                                  .indexOf(message_user))
                                              .like -= 1;
                                        }
                                        comments
                                            .elementAt(
                                                comments.indexOf(message_user))
                                            .dislike += 1;
                                        comments
                                            .elementAt(
                                                comments.indexOf(message_user))
                                            .alreadySelected = 0;

                                        this.update();
                                      }
                                    } else if (!preferences.containsKey("id")) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(SnackBar(
                                              content: Text(
                                                  "Tens de criar conta !")));
                                    }
                                  },
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.thumb_down,
                                        color: comments
                                                    .elementAt(comments
                                                        .indexOf(message_user))
                                                    .alreadySelected ==
                                                0
                                            ? Colors.red
                                            : Colors.grey,
                                      ),
                                      SizedBox(
                                        width: 5,
                                      ),
                                      Text(message_user.dislike.toString()),
                                    ],
                                  ),
                                ),
                              ),
                              Container(
                                height: 30,
                                margin: EdgeInsets.only(left: 100),
                                child: GestureDetector(
                                  onTap: () async {
                                    final preferences =
                                        await SharedPreferences.getInstance();

                                    if (preferences.containsKey("id") &&
                                        comments
                                                .elementAt(comments
                                                    .indexOf(message_user))
                                                .alreadySelected !=
                                            1) {
                                      var favorite = await http.post(
                                          Uri.parse(
                                              "${Config.ipadress}/api/likerecipe_comment_create"),
                                          body: {
                                            "idcomment":
                                                message_user.id.toString(),
                                            "type": "1",
                                            "iduser": preferences
                                                .getInt("id")
                                                .toString(),
                                          });
                                      if (favorite.statusCode == 200) {
                                        if (comments
                                                .elementAt(comments
                                                    .indexOf(message_user))
                                                .alreadySelected ==
                                            0) {
                                          comments
                                              .elementAt(comments
                                                  .indexOf(message_user))
                                              .dislike -= 1;
                                        }
                                        comments
                                            .elementAt(
                                                comments.indexOf(message_user))
                                            .like += 1;
                                        comments
                                            .elementAt(
                                                comments.indexOf(message_user))
                                            .alreadySelected = 1;

                                        this.update();
                                      }
                                    } else if (!preferences.containsKey("id")) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(SnackBar(
                                              content: Text(
                                                  "Tens de criar conta !")));
                                    }
                                  },
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.thumb_up,
                                        color: comments
                                                    .elementAt(comments
                                                        .indexOf(message_user))
                                                    .alreadySelected ==
                                                1
                                            ? Colors.blue
                                            : Colors.grey,
                                      ),
                                      SizedBox(
                                        width: 5,
                                      ),
                                      Text(message_user.like.toString()),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          )
                  ],
                ),
              ),
              message_user.recipeSteps.length > 0
                  ? Container(
                      height: 100,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Text(message_user.view.toString(),
                                  style: TextStyle(color: Colors.blue)),
                              SizedBox(
                                width: 5,
                              ),
                              Icon(
                                Icons.remove_red_eye,
                                color: Colors.blue,
                              )
                            ],
                          ),
                        ],
                      ),
                    )
                  : Container()
            ],
          ),
        ]),
      ),
    );
  }
}

class RenderChatCommunity extends StatefulWidget {
  String idRecipe = "", nameRecipe = "";
  List<Comment> comments = [];

  RenderChatCommunity(this.idRecipe, this.comments, this.nameRecipe);

  @override
  State<RenderChatCommunity> createState() => _RenderChatCommunityState();
}

class _RenderChatCommunityState extends State<RenderChatCommunity> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: 515,
      child: SingleChildScrollView(
        child: Column(
          children: widget.comments.map<Widget>((e) {
            return MensagemUser(
                widget.comments, widget.idRecipe, e, widget.nameRecipe, () {
              setState(() {});
            });
          }).toList(),
        ),
      ),
    );
  }
}
