import 'package:evaluatefood/Account/Account.dart';
import 'package:flick_video_player/flick_video_player.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:evaluatefood/VideoPlayerWidget.dart';
import 'package:sizer/sizer.dart';
import 'package:video_player/video_player.dart';

import '../Config/appConfig.dart';
import '../Model/Receita/Recipe.dart';
import '../Providers/UpdateRecipeSelect.dart';


class RecipeTrailerState extends StatelessWidget {
  late Recipe recipe;
  RecipeTrailerState(this.recipe);

  @override
  Widget build(BuildContext context) {
    return RecipeTrailer(recipe);
  }
}


class RecipeTrailer extends StatefulWidget {

  late Recipe recipe;
  RecipeTrailer(this.recipe);

  @override
  State<RecipeTrailer> createState() => _RecipeTrailerState();
}

class _RecipeTrailerState extends State<RecipeTrailer> {
/*
 late   VideoPlayerController  _controller = VideoPlayerController.network("http://${Config.ipadress}:${Config.ipadressPort}/uploads/receita/${widget.recipe.id}/trailer.mp4");

  late ChewieController    chewieController = ChewieController(
    videoPlayerController: _controller,
    autoPlay: true,
    looping: false,
    );


  void initVideoPlayer()async{


 await _controller.initialize().then((value) {
   setState(() {

   });
 });

 
   


   // chewieController.play();
  }*/

late FlickManager flickManager;


  @override
  void initState(){
  super.initState();
  flickManager = FlickManager(videoPlayerController: VideoPlayerController.networkUrl(Uri.parse("${Config.ipadress}/uploads/receita/${widget.recipe.id}/trailer.mp4"), videoPlayerOptions: VideoPlayerOptions()));
  }


  @override
  void dispose() {
  /*  _controller.dispose();
    chewieController.dispose();*/
    flickManager.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {


    return  /*_controller.value.isInitialized ? Chewie(controller: chewieController) : Center(
      child: CircularProgressIndicator()
    )*/ SizedBox(
        width: 100.w,
        height: 100.h,
        child: Stack(
          children: [
            AbsorbPointer(
              absorbing: true,
              child: SizedBox(
                  width: 100.w,
                  height: 100.h,
                  child: Center(child: FlickVideoPlayer(
                      flickManager: flickManager))),
            ),

            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                width: 100.w,
                height: 120,
                padding: EdgeInsets.only(top: 10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                      colors: [Colors.black.withOpacity(.8), Colors.black.withOpacity(.1)],
                ),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        SizedBox(width: 10),
                        Column(
                          children: [
                              GestureDetector(
                                onTap: (){
                                  Navigator.push(context, MaterialPageRoute(builder: (_) => Account(widget.recipe.idUser, false, widget.recipe.id)));
                                },
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(50),
                                  child: Container(
                                                      width: 50,
                                                      height: 50,
                                                      decoration: BoxDecoration(
                                                        borderRadius: BorderRadius.circular(50)
                                                      ),
                                                      child: Image.network("${Config.ipadress}/uploads/profiles/${widget.recipe.idUser.toString()}/profile.png", width: 50, height: 50, fit: BoxFit.cover,),
                                                    ),
                                ),
                              ),
                          SizedBox(height:  5,),

                        Row(children: [
                          SizedBox(width: 5,),

                          Text(widget.recipe.likes.toString(),style: TextStyle(color: Colors.red, fontSize: 10),),
                          SizedBox(width: 5,),
                          Icon(Icons.heart_broken, color: Colors.red,)
                        ],)
                          ]
                        ),

                        SizedBox(
                          width: 10,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(widget.recipe.name,style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),),
                            SizedBox(
                              height: 10,
                            ),
                            Text(widget.recipe.description.isEmpty ? "description": widget.recipe.description,style: TextStyle(color: Colors.white),),
                          ],
                        ),

                      ],
                    ),
                    Row(
                      children: widget.recipe.tags.map((e) {
                        return  Container(
                            padding: EdgeInsets.all(5),
                            child: Row(
                              children: [
                                Text("#",style: TextStyle(color: Colors.blue),),
                                Text(e.name,style: TextStyle(color: Colors.white),),
                              ],
                            ));
                      }).toList(),
                    )
                  ],
                ),
              ),
            )
          ],
        )) ;
  }
}

