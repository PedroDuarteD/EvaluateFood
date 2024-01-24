class RecipeIngredientModel{

  String name="", measure="";

  int amount = 0;
  int id = -1,idfrase=-1,idItem=-1;

  bool active = false;
  int userID = -1;

  RecipeIngredientModel.Word(this.idfrase,this.name);
  RecipeIngredientModel.Ingredient(this.idfrase,this.idItem,this. id,this. amount,this.measure, this.name);
  RecipeIngredientModel.IngredientPreview(this. id,this. amount, this.measure,this.name);

  RecipeIngredientModel.Show(this.id,this.name, this.active, this.userID);

}
