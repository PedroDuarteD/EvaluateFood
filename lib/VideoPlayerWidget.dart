import 'package:video_player/video_player.dart';
import "package:flutter/material.dart";
/// Stateful widget to fetch and then display video content.
class VideoPlayerWidget extends StatefulWidget {

    VideoPlayerController controller;

  VideoPlayerWidget({Key? key,   required this.controller}) : super(key: key);

  @override
  _VideoPlayerWidgetState createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {


  int posicao=0;
  @override
  Widget build(BuildContext context) {
    return  widget.controller.value.isInitialized
              ? AspectRatio(
            aspectRatio: widget.controller.value.aspectRatio,
            child: VideoPlayer(widget.controller),
          )
              : Container();
  }

  @override
  void dispose() {
    super.dispose();
    widget.controller.dispose();
  }
}