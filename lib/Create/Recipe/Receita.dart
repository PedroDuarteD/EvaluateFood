import "package:dotted_border/dotted_border.dart";
import "package:flutter/material.dart";
import 'package:evaluatefood/Create/Recipe/RecipeIngredientTree/RecipeIngredient.dart';
import "package:evaluatefood/Create/Recipe/index.dart";
import 'package:images_picker/images_picker.dart';
import 'package:evaluatefood/Create/Recipe/index.dart';


class ReceitaApresentacao extends StatefulWidget {



  @override
  State<ReceitaApresentacao> createState() => _ReceitaApresentacaoState();
}

class _ReceitaApresentacaoState extends State<ReceitaApresentacao> {

  List<String> TextFieldHelper =[
    "Categoria pertence a receita",
    "Para quantas pessoas foi feita a receita",
    "O nome que vai ser atribuido a receita",
    "Qual a descrição que melhor a descreve"
  ];

  int renderWidget =0;

  List<bool> statusWidgetRender = [
    false,
    false,
    false,
    false
  ];

  FocusNode textfieldFocus = new FocusNode();
  Widget RenderTextFieldWithHelper(int type){
    return  Column(
      children: [
        DottedBorder(
          color: Colors.black,
          radius: Radius.circular(50),
          child: Container(
            padding: EdgeInsets.only(top: 5,bottom: 5, right: 10, left: 10),
            decoration: BoxDecoration(
              color: Color.fromRGBO(255, 184, 0, .19)
            ),
            child: Text(TextFieldHelper[type]),
          ),
        ),
        SizedBox(
          height: 5,
        ),
      type == 0 ?      Container(
    color: Color.fromRGBO(241, 239, 239, 1),
    width: MediaQuery.of(context).size.width,
    child: DropdownButton(
    iconEnabledColor: Colors.blue,
    value:  CreateReceita.sop_selected ,
    items: [
    DropdownMenuItem(child: Text("Categoria"),value: 0,),
    DropdownMenuItem(child: Text("Sopa"),value: 1,),

    DropdownMenuItem(child: Text("Prato"),value: 2,),
    DropdownMenuItem(child: Text("Sobremesa"),value: 3,)],
    onChanged: (item){
    setState(() {
    CreateReceita.sop_selected = item!;
    if(item==0){
      statusWidgetRender[renderWidget] = false;

    }else{
      statusWidgetRender[renderWidget] = true;

    }
    });
    }),
    ):  Container(
        margin: EdgeInsets.only(top: 20),
          height: 45,
          child: TextField(
            focusNode: textfieldFocus,
            keyboardType: renderWidget == 1 ?  TextInputType.number : TextInputType.text,

            decoration: InputDecoration(
                labelText:  type==1? "Numero Pessoas" : type ==2? "Nome" : "Descrição",
                filled: true,
                prefixIcon: Icon(type == 1? Icons.people : type==2? Icons.person : Icons.description),
                fillColor: Color.fromRGBO(241, 239, 239, 1),
                border: OutlineInputBorder(
                    borderSide: BorderSide.none
                )
            ),
            onChanged: (text){
              setState(() {
                if(text.isEmpty){
                  statusWidgetRender[renderWidget] = false;
                }else{
                  statusWidgetRender[renderWidget] = true;
                }
              });

            },
            controller: type==1? CreateReceita.edit_people : type ==2? CreateReceita.edit_name : CreateReceita.edit_description,
          ),
        ),
      ],
    );
  }



  @override
  Widget build(BuildContext context) {



    return Container(
       margin: EdgeInsets.only(top: 25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
          children: [


            Padding(
              padding: const EdgeInsets.only(right: 20, left: 20),
              child: Text("Dados Gerais",style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),),
            ),

            SizedBox(
              height: 20,
            ),

            Container(
          padding: EdgeInsets.only(top: 10, bottom: 10, right: 20, left: 20),
          decoration: BoxDecoration(
            color: Color.fromRGBO(230, 230, 230, 300)
          ),
          child: Column(

            children: [
              Row(

                children: [
                  Icon(Icons.done, color: statusWidgetRender[0] ? Colors.blue : Colors.grey,),
                  SizedBox(
                    width: 10,
                  ),
                  Text("Categoria")
                ],
              ),

              Row(

                children: [
                  Icon(Icons.done, color: statusWidgetRender[1] ? Colors.blue : Colors.grey,),
                  SizedBox(
                    width: 10,
                  ),
                  Text("Quantidade Pessoas")
                ],
              ),


              Row(

                children: [
                  Icon(Icons.done, color: statusWidgetRender[2] ? Colors.blue : Colors.grey,),
                  SizedBox(
                    width: 10,
                  ),
                  Text("Nome")
                ],
              ),

              Row(

                children: [
                  Icon(Icons.done, color: statusWidgetRender[3] ? Colors.blue : Colors.grey,),
                  SizedBox(
                    width: 10,
                  ),
                  Text("Descrição")
                ],
              ),
            ],
          ),
        ),


            Padding(
              padding: const EdgeInsets.only(right: 20, left: 20, top: 20),
              child: RenderTextFieldWithHelper(renderWidget),
            ),

            Padding(
              padding: const EdgeInsets.only(right: 20, left: 20, top: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                    ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor:  Colors.white,
                        foregroundColor: Colors.green,
                        side: BorderSide(color: Colors.green)
                    ),
                    onPressed: renderWidget ==0 ? null: (){
                      if(renderWidget!=0){
                        setState(() {
                          FocusManager.instance.primaryFocus?.unfocus();


                          renderWidget -= 1;
                          Future.delayed(Duration(seconds: 1), (){
                            textfieldFocus.requestFocus();
                          });
                        });
                      }
                    }, child: Row(children: [Icon(Icons.arrow_back), Text("Anterior")],)),
                  Text("${renderWidget+1} de 4"),
                  ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                          foregroundColor: Colors.green,
                          side: BorderSide(color: Colors.green)


                      ),
                      onPressed: renderWidget==3 ? null :  (){

                        if(renderWidget!=3){
                          setState(() {
                            FocusManager.instance.primaryFocus?.unfocus();

                            renderWidget +=1;
                            Future.delayed(Duration(seconds: 1), (){
                              textfieldFocus.requestFocus();
                            });
                          });
                        }
                      }, child: Row(children: [ Text("Próximo"),Icon(Icons.arrow_forward),],)),
                ],
              ),
            ),

        statusWidgetRender[0] && statusWidgetRender[1] && statusWidgetRender[2] && statusWidgetRender[3] ?
            Container(
              margin: EdgeInsets.only(top: 10),
              decoration: BoxDecoration(
                color: Colors.blue
              ),
              child: Padding(
                padding: const EdgeInsets.only(right: 20, left: 20, top: 10,bottom: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                  Text("Deslize para a direita",style: TextStyle(fontSize: 15, color: Colors.white),),
                  Icon(Icons.back_hand, color: Colors.white,)
                ], ),
              ),
            ) : Container()

          ])
      );
  }
}
