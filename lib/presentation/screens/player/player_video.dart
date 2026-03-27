part of '../screens.dart';

class StreamPlayerPage extends StatefulWidget {
  const StreamPlayerPage({
    super.key,
    this.controller,
    this.url,
    this.isLive = false,
  });
  final VlcPlayerController? controller;
  final String? url;
  final bool isLive;

  @override
  State<StreamPlayerPage> createState() => _StreamPlayerPageState();
}

class _StreamPlayerPageState extends State<StreamPlayerPage> {
  bool isPlayed = true;
  bool showControllersVideo = true;
  late Timer timer;
  PodPlayerController? _podController;

  @override
  void initState() {
    WakelockPlus.enable();
    super.initState();
    if (kIsWeb && widget.url != null) {
      _podController = PodPlayerController(
        playVideoFrom: widget.isLive
            ? PlayVideoFrom.network(widget.url!) // standard network for live if possible
            : PlayVideoFrom.network(widget.url!),
        podPlayerConfig: const PodPlayerConfig(
          autoPlay: true,
          isLooping: false,
          videoQualityPriority: [720, 1080, 360],
        ),
      )..initialise();
    }

    timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (showControllersVideo) {
        if (mounted) {
          setState(() {
            showControllersVideo = false;
          });
        }
      }
    });
  }

  @override
  void didUpdateWidget(StreamPlayerPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (kIsWeb && oldWidget.url != widget.url && widget.url != null) {
      _podController?.changeVideo(
        playVideoFrom: PlayVideoFrom.network(widget.url!),
      );
    }
  }

  @override
  void dispose() {
    timer.cancel();
    _podController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      if (widget.url == null) {
        return const Center(child: Text('اختر قناة...', style: TextStyle(color: Colors.grey)));
      }
      return PodVideoPlayer(
        controller: _podController!,
        alwaysShowProgressBar: false,
      );
    }

    if (widget.controller == null) {
      return const Center(
        child: Text(
          'Select a player...',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }
    return Ink(
      color: Colors.black,
      width: getSize(context).width,
      height: getSize(context).height,
      child: Stack(
        alignment: Alignment.center,
        children: [
          VlcPlayer(
            controller: widget.controller!,
            aspectRatio: 16 / 9,
            placeholder: const Center(child: CircularProgressIndicator()),
          ),

          GestureDetector(
            onTap: () {
              debugPrint("click");
              setState(() {
                showControllersVideo = !showControllersVideo;
              });
            },
            child: Container(
              width: getSize(context).width,
              height: getSize(context).height,
              color: Colors.transparent,
            ),
          ),

          ///Controllers
          BlocBuilder<VideoCubit, VideoState>(
            builder: (context, state) {
              if (!state.isFull) {
                return const SizedBox();
              }

              return SizedBox(
                width: getSize(context).width,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 400),
                  child: !showControllersVideo
                      ? const SizedBox()
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 10,
                                  ),
                                  child: IconButton(
                                    focusColor: kColorFocus,
                                    onPressed: () {
                                      context
                                          .read<VideoCubit>()
                                          .changeUrlVideo(false);
                                      //Get.back();
                                    },
                                    icon: const Icon(
                                        FontAwesomeIcons.chevronRight),
                                  ),
                                ),
                              ],
                            ),
                            IconButton(
                              focusColor: kColorFocus,
                              onPressed: () {
                                if (isPlayed) {
                                  widget.controller!.pause();
                                  isPlayed = false;
                                } else {
                                  widget.controller!.play();
                                  isPlayed = true;
                                }
                                setState(() {});
                              },
                              icon: Icon(
                                isPlayed
                                    ? FontAwesomeIcons.pause
                                    : FontAwesomeIcons.play,
                                size: 24.sp,
                              ),
                            ),
                            const SizedBox(height: 30),
                          ],
                        ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
