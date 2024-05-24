import 'dart:developer';
import 'dart:ui';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:music_app/network/endpoint.dart';
import 'package:music_app/network/get_data.dart';

class AudioPlayerScreen extends StatefulWidget {
  const AudioPlayerScreen({super.key});

  @override
  State<AudioPlayerScreen> createState() => _AudioPlayerScreenState();
}

class _AudioPlayerScreenState extends State<AudioPlayerScreen> {
  List _musicList = [];

  final player = AudioPlayer();
  bool isPlay = false;
  bool _isLoading = true;

  Duration position = Duration.zero;

  playAudioFromUrl(String url) async {
    await player.play(UrlSource(url));
    debugPrint("positiononplay ${position.toString()}");
  }

  musicData() async {
    final response =
        await GetData().getJsonData(ApiEndPoint.baseUrl + ApiEndPoint.endPoint);
    setState(() {
      _musicList.addAll(response["music"]);
      _isLoading = false;
    });

  }

  String formatTime(int second) {
    return "${(Duration(seconds: second))}".split('.')[0].padLeft(8, '0');
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    musicData();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: _isLoading == true
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                      image: NetworkImage(_musicList[2]["image"]),
                      fit: BoxFit.cover),
                ),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    decoration: BoxDecoration(
                        color: Colors.transparent.withOpacity(0.2)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Center(child: Image.network(_musicList[2]["image"])),
                        const SizedBox(height: 15),
                        Text(
                          _musicList[2]["title"] ?? "",
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 25,
                              fontWeight: FontWeight.bold),
                          textAlign: TextAlign.start,
                        ),
                        const SizedBox(height: 5),
                        Text(
                          _musicList[2]["artist"] ?? "",
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 15),
                        Row(
                          children: [
                            Text(formatTime(position.inSeconds)),
                            Slider(
                              min: 0,
                              max: Duration(seconds: _musicList[2]["duration"])
                                  .inSeconds
                                  .toDouble(),
                              activeColor: Colors.red,
                              inactiveColor: Colors.white,
                              value: position.inSeconds.toDouble(),
                              onChanged: (value) {
                                position = Duration(seconds: value.toInt());
                                player.seek(position);
                                player.resume();
                                setState(() {});
                                debugPrint("position ${position.toString()}");
                              },
                            ),
                            Text(formatTime(_musicList[2]["duration"] -
                                position.inSeconds)),
                          ],
                        ),
                        const SizedBox(height: 15),
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.9,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Icon(Icons.skip_previous_rounded,
                                  color: Colors.white, size: 40),
                              const Icon(Icons.fast_rewind_rounded,
                                  color: Colors.white, size: 40),
                              GestureDetector(
                                onTap: () async {
                                  debugPrint("isPlay $isPlay");
                                  if (isPlay) {
                                    await player.pause();
                                    setState(() {
                                      isPlay = false;
                                    });
                                  } else {
                                    await playAudioFromUrl(
                                        _musicList[2]["source"]);

                                    setState(() {
                                      isPlay = true;
                                    });
                                  }

                                  player.onDurationChanged
                                      .listen((Duration newDuration) {
                                    setState(() {
                                      _musicList[2]["duration"] =
                                          newDuration.inSeconds;
                                    });
                                    debugPrint(
                                        _musicList[2]["duration"].toString());
                                  });

                                  player.onPositionChanged
                                      .listen((Duration newPosition) {
                                    setState(() {
                                      position = newPosition;
                                    });
                                  });
                                },
                                child: Container(
                                  height: 70,
                                  width: 70,
                                  decoration: const BoxDecoration(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(35)),
                                    color: Colors.white,
                                  ),
                                  child: Icon(
                                      isPlay ? Icons.pause : Icons.play_arrow,
                                      color: Colors.black,
                                      size: 40),
                                ),
                              ),
                              const Icon(Icons.fast_forward_rounded,
                                  color: Colors.white, size: 40),
                              const Icon(Icons.skip_next_rounded,
                                  color: Colors.white, size: 40),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}
