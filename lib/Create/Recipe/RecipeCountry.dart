import 'package:evaluatefood/Create/Recipe/index.dart';
import 'package:flutter/material.dart';

import '../../Model/Receita/Country.dart';

class RecipeCountry extends StatefulWidget {
  const RecipeCountry({super.key});

  @override
  State<RecipeCountry> createState() => _RecipeCountryState();
}

class _RecipeCountryState extends State<RecipeCountry> {


  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 20,
        ),
        Text("Adicione País"),
        SizedBox(
          height: 20,
        ),
        ListView.builder(
          itemCount: CreateReceita.countries.length,
          shrinkWrap: true,
          itemBuilder: (_, position){
            return Row(
              children: [
                Text(CreateReceita.countries[position].name),
                Checkbox(value: CreateReceita.countries[position].selected, onChanged: (value){
                  setState(() {
                    CreateReceita.countries[position].selected = !CreateReceita.countries[position].selected;
                  });
                })
              ],
            );
          },
        )
      ],
    );
  }
}
