import 'package:flick_video_player/flick_video_player.dart';
import 'package:flutter/material.dart';
import 'package:evaluatefood/Config/appConfig.dart';
import 'package:evaluatefood/Model/Receita/RecipeSteps.dart';
import 'package:evaluatefood/ReceitaSelecionada/ReceitaPassos.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:video_player/video_player.dart';

import '../Ads/AdHelper.dart';

class ReceitaCozinhar extends StatefulWidget {

String idRecipe="";
ReceitaCozinhar(this.idRecipe);

  @override
  State<ReceitaCozinhar> createState() => _ReceitaCozinharState();
}

class _ReceitaCozinharState extends State<ReceitaCozinhar> {

   late BannerAd _bannerAd;
   bool load = false;

  @override
  void initState(){
super.initState();

   _bannerAd =  BannerAd(
      adUnitId: AdHelper.bannerAdUnitId,
      request: AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          setState(() {
            load = true;
          });
        },
        onAdFailedToLoad: (ad, err) {
          print('Failed to load a banner ad: ${err.message}');
          ad.dispose();
        },
      ),
    );

   _bannerAd.load();
  }

  @override
  void dispose() {
   // _bannerAd?.dispose();

    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          margin: EdgeInsets.only(right: 20,left: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

            ReceitaPassos(450, widget.idRecipe),


              Center(
                child: ElevatedButton(child: Text("Aprender com Vídeo"),onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => EnsinarReceitaVideo(widget.idRecipe)));

                },),
              ),

       load? AdWidget(ad: _bannerAd!) : Container()


            ],
          ),
        ),
      ),

    );
  }
}

class EnsinarReceitaVideo extends StatefulWidget {
String idRecipe ="";

  EnsinarReceitaVideo(this.idRecipe);

  @override
  State<EnsinarReceitaVideo> createState() => _EnsinarReceitaVideoState();
}

class _EnsinarReceitaVideoState extends State<EnsinarReceitaVideo> {


 late FlickManager flickManager;
  
  @override
  void initState(){
    super.initState();

    flickManager  =  FlickManager(
 onVideoEnd: (){

 },
  autoPlay: true,
  autoInitialize: true,
  videoPlayerController: VideoPlayerController.network("${Config.ipadress}/uploads/receita/${widget.idRecipe}/ensinar.mp4"));

  }

  @override
  void dispose(){
    flickManager.dispose();

    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:  FlickVideoPlayer(flickManager: flickManager,));
  }
}