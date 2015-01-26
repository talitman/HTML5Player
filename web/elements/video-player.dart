library videoPlayer;
import 'package:polymer/polymer.dart';
import 'package:core_elements/core_icon.dart';
import 'video-stream.dart';
import 'dart:html';
import 'dart:async';

@CustomTag('video-player')
class VideoPlayer extends PolymerElement {
  
  //published attributes
  @published bool autoplay = false;
  @published double setProgress = 0.0;
  @published int duration = 1;
  @published double speed = 1.0;
  @published String quality = "sd";
  @published int volume = 80;
  
  @observable bool isPlaying = false;
  @observable int progressIndicator = 0;
  @observable bool isFullscreen = false;
  
  double startX;
  double startWidth;
  CoreIcon resizer = new Element.tag('core-icon');
  var mouseMoveListener;
  var mouseUpListener;
  
  //referenced elements
  ElementList<VideoStream> videoStreamList;

  @observable
  VideoPlayer.created() : super.created() { }
  
  @override
  void attached() {
    videoStreamList = this.querySelectorAll("video-stream");
    
    this.querySelector("video-stream:last-child").setAttribute("flex", "");
    
    progressIndicator = setProgress.floor();
    isPlaying = autoplay;

    resizer.icon = "polymer";
    resizer.id = "resizer";
    this.insertBefore(resizer, videoStreamList[0].nextNode);
    resizer.onMouseDown.listen(initDrag);
    
    videoStreamList.forEach((stream) => stream.resize());
    
    new Timer.periodic(const Duration(milliseconds: 500), (timer) {
      progressIndicator = videoStreamList[0].getProgress().floor();
      isPlaying = videoStreamList[0].isPlaying();
    });
  }
  
  void initDrag([MouseEvent e]){
    startX = e.client.x;
    startWidth = double.parse( videoStreamList[0].getComputedStyle().width.replaceAll('px', '') );
    mouseUpListener = window.onMouseUp.listen(stopDrag);
    mouseMoveListener = window.onMouseMove.listen(doDrag);
  }
  
  void doDrag([MouseEvent e]){
    videoStreamList[0].style.width = (startWidth + e.client.x - startX).toString() + "px";
    videoStreamList.forEach((stream) => stream.resize());
  }
  
  void stopDrag([MouseEvent e]){
    mouseMoveListener.cancel();
    mouseUpListener.cancel();
  }
  
  //PlayPause
  void isPlayingChanged([Event e]){
    if(isPlaying){
      play();
    }
    else{
      pause();
    }
  }
  
  void play([Event e]){
    videoStreamList.forEach(
        (stream) => stream.play()
    );
    isPlaying = true;
  }
  
  void pause([Event e]){
    videoStreamList.forEach(
        (stream) => stream.pause()
    );
    isPlaying = false;
  }
  
  //Progress
  void setProgressChanged(){
    videoStreamList.forEach(
      (stream) => stream.setProgress(setProgress)
    );
  }
  
  //Speed  
  void speedChanged() {
    videoStreamList.forEach(
      (stream) => stream.setSpeed(speed)
    );
  }
  
  //Volume
  void volumeChanged(){
    videoStreamList.forEach(
      (stream) => stream.setVolume(volume)
    );
  }
  
}

