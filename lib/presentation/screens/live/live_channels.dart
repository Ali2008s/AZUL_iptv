part of '../screens.dart';

class LiveChannelsScreen extends StatefulWidget {
  const LiveChannelsScreen({super.key, required this.catyId});
  final String catyId;

  @override
  State<LiveChannelsScreen> createState() => _ListChannelsScreen();
}

class _ListChannelsScreen extends State<LiveChannelsScreen> {
  static const _kAccent = Color(0xFFFB772A);

  VlcPlayerController? _videoPlayerController;
  int? selectedVideo;
  String? selectedStreamId;
  ChannelLive? channelLive;
  String keySearch = "";
  String keyCatySearch = "";
  String selectedCatyId = "";

  final ScrollController _catyScrollCtrl = ScrollController();

  Future<void> _initialVideo(String streamId, UserModel user) async {
    if (_videoPlayerController != null &&
        _videoPlayerController!.value.isInitialized) {
      _videoPlayerController!.pause();
      _videoPlayerController!.stop();
      _videoPlayerController = null;
      await Future.delayed(const Duration(milliseconds: 300));
    } else {
      _videoPlayerController = null;
      if (mounted) setState(() {});
      await Future.delayed(const Duration(milliseconds: 300));
    }

    final videoUrl =
        "${user.serverInfo!.serverUrl}/${user.userInfo!.username}/${user.userInfo!.password}/$streamId";

    debugPrint("Load Video: $videoUrl");
    _videoPlayerController = VlcPlayerController.network(
      videoUrl,
      hwAcc: HwAcc.full,
      autoPlay: true,
      options: VlcPlayerOptions(
        advanced: VlcAdvancedOptions([
          VlcAdvancedOptions.networkCaching(2000),
          VlcAdvancedOptions.liveCaching(2000),
        ]),
        http: VlcHttpOptions([VlcHttpOptions.httpReconnect(true)]),
        rtp: VlcRtpOptions([VlcRtpOptions.rtpOverRtsp(true)]),
      ),
    );
    if (mounted) setState(() {});
  }

  void _loadCaty(String catyId) {
    setState(() {
      selectedCatyId = catyId;
      selectedVideo = null;
      channelLive = null;
      selectedStreamId = null;
      _videoPlayerController = null;
      keySearch = "";
    });
    context.read<ChannelsBloc>().add(GetLiveChannelsEvent(
          catyId: catyId,
          typeCategory: TypeCategory.live,
        ));
  }

  @override
  void initState() {
    selectedCatyId = widget.catyId;
    context.read<ChannelsBloc>().add(GetLiveChannelsEvent(
          catyId: widget.catyId,
          typeCategory: TypeCategory.live,
        ));
    super.initState();
  }

  @override
  void dispose() {
    _catyScrollCtrl.dispose();
    if (_videoPlayerController != null &&
        _videoPlayerController!.value.isInitialized) {
      _videoPlayerController!.stop();
      _videoPlayerController!.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<VideoCubit, VideoState>(
      builder: (context, stateVideo) {
        return WillPopScope(
          onWillPop: () async {
            if (stateVideo.isFull) {
              context.read<VideoCubit>().changeUrlVideo(false);
              return Future.value(false);
            }
            return Future.value(true);
          },
          child: BlocBuilder<AuthBloc, AuthState>(
            builder: (context, stateAuth) {
              if (stateAuth is! AuthSuccess) return const Scaffold();
              final userAuth = stateAuth.user;

              return Scaffold(
                body: Ink(
                  width: 100.w,
                  height: 100.h,
                  decoration: kDecorBackground,
                      child: stateVideo.isFull
                          ? StreamPlayerPage(
                              controller: _videoPlayerController,
                              isLive: true,
                              url: channelLive == null
                                  ? null
                                  : kIsWeb
                                      ? "${userAuth.serverInfo!.serverUrl}/live/${userAuth.userInfo!.username}/${userAuth.userInfo!.password}/${channelLive!.streamId}.m3u8"
                                      : "${userAuth.serverInfo!.serverUrl}/${userAuth.userInfo!.username}/${userAuth.userInfo!.password}/${channelLive!.streamId}",
                            )
                      : Row(
                          children: [
                            // ══════════════════════════════════════
                            // SIDEBAR: Back button + Categories
                            // ══════════════════════════════════════
                            Container(
                              width: 230,
                              color: Colors.black12,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  // Back button row
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                        10, 14, 10, 4),
                                    child: Row(
                                      children: [
                                        InkWell(
                                          onTap: () => Get.back(),
                                          focusColor: kColorFocus,
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          child: Container(
                                            padding: const EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                              color: Colors.white10,
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: const Icon(
                                              FontAwesomeIcons.chevronRight,
                                              color: Colors.white70,
                                              size: 14,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        Text(
                                          "live_tv".tr,
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 17.sp,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  // Category Search
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                        10, 8, 10, 0),
                                    child: Container(
                                      height: 38,
                                      decoration: BoxDecoration(
                                        color: kColorCardLight,
                                        borderRadius:
                                            BorderRadius.circular(10),
                                      ),
                                      child: TextField(
                                        onChanged: (v) => setState(
                                            () => keyCatySearch = v),
                                        style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 12),
                                        decoration: InputDecoration(
                                          hintText: "search_caty".tr,
                                          hintStyle: const TextStyle(
                                              color: Colors.white38,
                                              fontSize: 12),
                                          prefixIcon: const Icon(
                                              FontAwesomeIcons
                                                  .magnifyingGlass,
                                              color: Colors.white38,
                                              size: 12),
                                          border: InputBorder.none,
                                          contentPadding:
                                              const EdgeInsets.only(top: 8),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  // Categories List
                                  Expanded(
                                    child: BlocBuilder<LiveCatyBloc,
                                        LiveCatyState>(
                                      builder: (context, state) {
                                        if (state is! LiveCatySuccess) {
                                          return const SizedBox();
                                        }
                                        final cats = state.categories
                                            .where((c) =>
                                                keyCatySearch.isEmpty ||
                                                c.categoryName!
                                                    .toLowerCase()
                                                    .contains(keyCatySearch
                                                        .toLowerCase()))
                                            .toList();
                                        return ListView(
                                          controller: _catyScrollCtrl,
                                          padding: EdgeInsets.zero,
                                          children: [
                                            _buildCatyItem(
                                              title: "all".tr,
                                              isSelected:
                                                  selectedCatyId == "",
                                              onTap: () => _loadCaty(""),
                                            ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.fromLTRB(
                                                      16, 8, 16, 4),
                                              child: Text(
                                                "favorites".tr,
                                                style: TextStyle(
                                                  color: Colors.white54,
                                                  fontSize: 11.sp,
                                                ),
                                              ),
                                            ),
                                            ...cats.map((cat) =>
                                                _buildCatyItem(
                                                  title:
                                                      cat.categoryName ?? "",
                                                  isSelected:
                                                      selectedCatyId ==
                                                          cat.categoryId,
                                                  onTap: () => _loadCaty(
                                                      cat.categoryId ?? ""),
                                                )),
                                          ],
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // DIVIDER
                            Container(
                                width: 1,
                                color: Colors.white10),

                            // ══════════════════════════════════════
                            // COLUMN 2: Channel List
                            // ══════════════════════════════════════
                            SizedBox(
                              width: 300,
                              child: Column(
                                children: [
                                  // Search bar
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                        10, 14, 10, 8),
                                    child: Container(
                                      height: 38,
                                      decoration: BoxDecoration(
                                        color: kColorCardLight,
                                        borderRadius:
                                            BorderRadius.circular(10),
                                      ),
                                      child: TextField(
                                        onChanged: (v) =>
                                            setState(() => keySearch = v),
                                        style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 13),
                                        decoration: InputDecoration(
                                          hintText: "search_channels".tr,
                                          hintStyle: const TextStyle(
                                              color: Colors.white38,
                                              fontSize: 13),
                                          prefixIcon: const Icon(
                                              FontAwesomeIcons
                                                  .magnifyingGlass,
                                              color: Colors.white38,
                                              size: 13),
                                          border: InputBorder.none,
                                          contentPadding:
                                              const EdgeInsets.only(top: 8),
                                        ),
                                      ),
                                    ),
                                  ),
                                  // Channel list
                                  Expanded(
                                    child: BlocConsumer<ChannelsBloc,
                                        ChannelsState>(
                                      listener: (context, state) {
                                        if (state is ChannelsLiveSuccess) {
                                          if (state.channels.isNotEmpty && selectedVideo == null) {
                                            final firstChannel = state.channels.first;
                                            _initialVideo(firstChannel.streamId.toString(), userAuth);
                                            setState(() {
                                              selectedVideo = 0;
                                              channelLive = firstChannel;
                                              selectedStreamId = firstChannel.streamId;
                                            });
                                          }
                                        }
                                      },
                                      builder: (context, state) {
                                        if (state is ChannelsLoading) {
                                          return const Center(
                                              child:
                                                  CircularProgressIndicator());
                                        }
                                        if (state is ChannelsLiveSuccess) {
                                          final all = state.channels;
                                          final display = keySearch.isEmpty
                                              ? all
                                              : all
                                                  .where((e) => (e.name ??
                                                          "")
                                                      .toLowerCase()
                                                      .contains(keySearch
                                                          .toLowerCase()))
                                                  .toList();
                                          return ListView.builder(
                                            padding:
                                                const EdgeInsets.only(
                                                    bottom: 60),
                                            itemCount: display.length,
                                            itemBuilder: (_, i) {
                                              final model = display[i];
                                              return _buildChannelRow(
                                                index: i + 1,
                                                model: model,
                                                isSelected:
                                                    selectedVideo == i,
                                                onTap: () async {
                                                  if (selectedVideo ==
                                                          i &&
                                                      _videoPlayerController !=
                                                          null) {
                                                    context
                                                        .read<VideoCubit>()
                                                        .changeUrlVideo(
                                                            true);
                                                  } else {
                                                    await _initialVideo(
                                                        model.streamId
                                                                .toString(),
                                                        userAuth);
                                                    setState(() {
                                                      selectedVideo = i;
                                                      channelLive = model;
                                                      selectedStreamId =
                                                          model.streamId;
                                                    });
                                                  }
                                                },
                                              );
                                            },
                                          );
                                        }
                                        return const Center(
                                            child: Text(
                                            "ماكو قنوات هنو..",
                                            style: TextStyle(
                                                color: Colors.white54)));
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // DIVIDER
                            Container(
                                width: 1,
                                color: Colors.white10),

                            // ══════════════════════════════════════
                            // COLUMN 3: Video Player
                            // ══════════════════════════════════════
                            Expanded(
                              child: selectedVideo == null
                                  ? Center(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          const Icon(FontAwesomeIcons.tv,
                                              color: Colors.white12,
                                              size: 52),
                                          const SizedBox(height: 16),
                                          Text(
                                            "اختر قناة لبدء المشاهدة",
                                            style: TextStyle(
                                                color: Colors.white30,
                                                fontSize: 14.sp),
                                          ),
                                        ],
                                      ),
                                    )
                                  : Column(
                                      children: [
                                        // Now watching label
                                        Padding(
                                          padding:
                                              const EdgeInsets.fromLTRB(
                                                  10, 10, 10, 0),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            children: [
                                              Text(
                                                "now_watching".tr,
                                                style: TextStyle(
                                                    color: Colors.white38,
                                                    fontSize: 11.sp),
                                              ),
                                              const SizedBox(width: 8),
                                              Text(
                                                channelLive?.name ?? "",
                                                style: TextStyle(
                                                    color: _kAccent,
                                                    fontWeight:
                                                        FontWeight.bold,
                                                    fontSize: 12.sp),
                                              ),
                                            ],
                                          ),
                                        ),
                                        // Player
                                        Expanded(
                                          flex: 7,
                                          child: Padding(
                                            padding:
                                                const EdgeInsets.all(10),
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      14),
                                              child: Container(
                                                color: Colors.black,
                                                child: StreamPlayerPage(
                                                  controller:
                                                      _videoPlayerController,
                                                  url: channelLive == null
                                                      ? null
                                                      : kIsWeb
                                                          ? "${userAuth.serverInfo!.serverUrl}/live/${userAuth.userInfo!.username}/${userAuth.userInfo!.password}/${channelLive!.streamId}.m3u8"
                                                          : "${userAuth.serverInfo!.serverUrl}/${userAuth.userInfo!.username}/${userAuth.userInfo!.password}/${channelLive!.streamId}",
                                                  isLive: true,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        // Info + Favorite
                                        Container(
                                          margin: const EdgeInsets.fromLTRB(
                                              10, 0, 10, 4),
                                          padding:
                                              const EdgeInsets.symmetric(
                                                  horizontal: 18,
                                                  vertical: 12),
                                          decoration: BoxDecoration(
                                            color: kColorCardLight,
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          child:
                                              BlocBuilder<FavoritesCubit,
                                                  FavoritesState>(
                                            builder:
                                                (context, favState) {
                                              final isLiked = favState
                                                  .lives
                                                  .any((l) =>
                                                      l.streamId ==
                                                      channelLive
                                                          ?.streamId);
                                              return Row(
                                                children: [
                                                  Expanded(
                                                    child: Text(
                                                      channelLive?.name ??
                                                          "",
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 15.sp,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                  ),
                                                  InkWell(
                                                    onTap: () {
                                                      context
                                                          .read<
                                                              FavoritesCubit>()
                                                          .addLive(
                                                              channelLive,
                                                              isAdd:
                                                                  !isLiked);
                                                    },
                                                    child: Icon(
                                                      isLiked
                                                          ? FontAwesomeIcons
                                                              .solidHeart
                                                          : FontAwesomeIcons
                                                              .heart,
                                                      color: isLiked
                                                          ? Colors.red
                                                          : Colors.white38,
                                                      size: 18.sp,
                                                    ),
                                                  ),
                                                ],
                                              );
                                            },
                                          ),
                                        ),
                                        // EPG
                                        CardEpgStream(
                                            streamId: selectedStreamId),
                                        // Help
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              bottom: 10, top: 4),
                                          child: Text(
                                            "full_screen_hint".tr,
                                            style: TextStyle(
                                                color: _kAccent,
                                                fontSize: 11.sp),
                                          ),
                                        ),
                                      ],
                                    ),
                            ),
                          ],
                        ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildCatyItem({
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      focusColor: kColorFocus,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
        padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        decoration: BoxDecoration(
          color: isSelected ? _kAccent : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.white70,
            fontWeight:
                isSelected ? FontWeight.bold : FontWeight.w500,
            fontSize: 13.sp,
          ),
        ),
      ),
    );
  }

  Widget _buildChannelRow({
    required int index,
    required ChannelLive model,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return BlocBuilder<FavoritesCubit, FavoritesState>(
      builder: (context, favState) {
        final isLiked = favState.lives
            .any((l) => l.streamId == model.streamId);
        return InkWell(
          onTap: onTap,
          focusColor: kColorFocus,
          borderRadius: BorderRadius.circular(10),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin:
                const EdgeInsets.symmetric(vertical: 3, horizontal: 8),
            padding: const EdgeInsets.symmetric(
                horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected
                  ? _kAccent
                  : kColorCardLight.withOpacity(0.45),
              borderRadius: BorderRadius.circular(10),
              border: isSelected
                  ? null
                  : Border.all(color: Colors.white10),
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 28,
                  child: Text(
                    "$index",
                    style: TextStyle(
                      color: isSelected
                          ? Colors.white
                          : Colors.white24,
                      fontSize: 11.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.black26,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: model.streamIcon != null &&
                          model.streamIcon!.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: model.streamIcon!,
                          fit: BoxFit.contain,
                          errorWidget: (_, __, ___) => const Icon(
                              FontAwesomeIcons.tv,
                              color: Colors.white12,
                              size: 16),
                        )
                      : const Icon(FontAwesomeIcons.tv,
                          color: Colors.white12, size: 16),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    model.name ?? "",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: isSelected
                          ? Colors.white
                          : Colors.white70,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                      fontSize: 13.sp,
                    ),
                  ),
                ),
                Icon(
                  isLiked
                      ? FontAwesomeIcons.solidHeart
                      : FontAwesomeIcons.heart,
                  color: isSelected
                      ? Colors.white
                      : (isLiked ? Colors.red : Colors.white24),
                  size: 13.sp,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class CardEpgStream extends StatelessWidget {
  const CardEpgStream({super.key, required this.streamId});
  final String? streamId;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: streamId == null
          ? const SizedBox()
          : FutureBuilder<List<EpgModel>>(
              future: IpTvApi.getEPGbyStreamId(streamId ?? ""),
              builder: (context, snapshot) {
                if (snapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const Center(
                      child: SizedBox(
                          width: 28,
                          height: 28,
                          child: CircularProgressIndicator()));
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const SizedBox();
                }
                final list = snapshot.data!;
                return Container(
                  margin: const EdgeInsets.fromLTRB(10, 4, 10, 0),
                  decoration: BoxDecoration(
                    color: kColorCardLight,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(
                        vertical: 8, horizontal: 10),
                    itemCount: list.length,
                    itemBuilder: (_, i) {
                      final model = list[i];
                      final desc = utf8
                          .decode(base64.decode(model.description ?? ""));
                      final title = utf8
                          .decode(base64.decode(model.title ?? ""));
                      return CardEpg(
                        title:
                            "${getTimeFromDate(model.start ?? "")} - ${getTimeFromDate(model.end ?? "")}  $title",
                        description: desc,
                        isSameTime: checkEpgTimeIsNow(
                            model.start ?? "", model.end ?? ""),
                      );
                    },
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: 6),
                  ),
                );
              }),
    );
  }
}

class CardEpg extends StatelessWidget {
  const CardEpg(
      {super.key,
      required this.title,
      required this.description,
      required this.isSameTime});
  final String title;
  final String description;
  final bool isSameTime;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Get.textTheme.bodyLarge!.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: 13.sp,
            color: isSameTime ? kColorPrimaryDark : Colors.white,
          ),
        ),
        if (description.isNotEmpty)
          Text(
            description,
            style: Get.textTheme.bodyMedium!.copyWith(
              color: Colors.white54,
              fontSize: 11.sp,
            ),
          ),
      ],
    );
  }
}
