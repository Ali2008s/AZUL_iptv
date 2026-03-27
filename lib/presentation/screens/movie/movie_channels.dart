part of '../screens.dart';

class MovieChannels extends StatefulWidget {
  final String catyId;

  const MovieChannels({Key? key, required this.catyId}) : super(key: key);

  @override
  State<MovieChannels> createState() => _MovieChannelsState();
}

class _MovieChannelsState extends State<MovieChannels> {
  String keySearch = "";
  String keyCatySearch = "";
  String selectedCatyId = "";

  InterstitialAd? _interstitialAd;
  _loadIntel() async {
    if (!showAds) return;
    InterstitialAd.load(
        adUnitId: kInterstitial,
        request: const AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (InterstitialAd ad) {
            _interstitialAd = ad;
          },
          onAdFailedToLoad: (LoadAdError error) {
            debugPrint('InterstitialAd failed to load: $error');
          },
        ));
  }

  final ScrollController _catyScrollCtrl = ScrollController();
  final ScrollController _gridScrollCtrl = ScrollController();

  @override
  void initState() {
    _loadIntel();
    selectedCatyId = widget.catyId;
    context.read<ChannelsBloc>().add(GetLiveChannelsEvent(
          typeCategory: TypeCategory.movies,
          catyId: widget.catyId,
        ));
    super.initState();
  }

  @override
  void dispose() {
    _catyScrollCtrl.dispose();
    _gridScrollCtrl.dispose();
    super.dispose();
  }

  void _selectCaty(String catyId) {
    setState(() {
      selectedCatyId = catyId;
      keySearch = "";
    });
    context.read<ChannelsBloc>().add(GetLiveChannelsEvent(
          typeCategory: TypeCategory.movies,
          catyId: catyId,
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Ink(
        width: 100.w,
        height: 100.h,
        decoration: kDecorBackground,
        child: Row(
          children: [
            // ═══════════════════════════════════════════════════════
            // COLUMN 1 + 2 merged: Sidebar with back button
            // ═══════════════════════════════════════════════════════
            Container(
              width: 230,
              color: Colors.black12,
              padding: const EdgeInsets.symmetric(vertical: 14),
                child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Back button + Title
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 0, 12, 2),
                    child: Row(
                      children: [
                        InkWell(
                          onTap: () => Get.back(),
                          focusColor: kColorFocus,
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white10,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              FontAwesomeIcons.chevronRight,
                              color: Colors.white70,
                              size: 13,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          "movies".tr,
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18.sp,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Categories Search
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    child: Container(
                      height: 40,
                      decoration: BoxDecoration(
                        color: kColorCardLight,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: TextField(
                        onChanged: (v) => setState(() => keyCatySearch = v),
                        style:
                            const TextStyle(color: Colors.white, fontSize: 13),
                        decoration: InputDecoration(
                          hintText: "search_caty".tr,
                          hintStyle:
                              const TextStyle(color: Colors.white38, fontSize: 13),
                          prefixIcon: const Icon(FontAwesomeIcons.magnifyingGlass,
                              color: Colors.white38, size: 13),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.only(top: 8),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Cats List
                  Expanded(
                    child: BlocBuilder<MovieCatyBloc, MovieCatyState>(
                      builder: (context, state) {
                        if (state is! MovieCatySuccess) {
                          return const SizedBox();
                        }
                        final cats = state.categories;
                        final filtered = keyCatySearch.isEmpty
                            ? cats
                            : cats
                                .where((c) => c.categoryName!
                                    .toLowerCase()
                                    .contains(keyCatySearch.toLowerCase()))
                                .toList();

                        return ListView(
                          controller: _catyScrollCtrl,
                          padding: EdgeInsets.zero,
                          children: [
                            _buildCatyItem(
                              title: "all".tr,
                              isSelected: selectedCatyId == "",
                              onTap: () => _selectCaty(""),
                            ),
                            ...filtered.map((cat) => _buildCatyItem(
                                  title: cat.categoryName ?? "",
                                  isSelected: selectedCatyId == cat.categoryId,
                                  onTap: () =>
                                      _selectCaty(cat.categoryId ?? ""),
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
            Container(width: 1.2, color: Colors.white10),

            // ═══════════════════════════════════════════════════════
            // COLUMN 3: Content
            // ═══════════════════════════════════════════════════════
            Expanded(
              child: Column(
                children: [
                  // Search Bar top
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                    child: BlocBuilder<ChannelsBloc, ChannelsState>(
                      builder: (context, state) {
                        final count = state is ChannelsMovieSuccess
                            ? state.channels.length
                            : 0;
                        return Row(
                          children: [
                            Expanded(
                              child: Container(
                                height: 44,
                                decoration: BoxDecoration(
                                  color: kColorCardLight,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: TextField(
                                  onChanged: (v) =>
                                      setState(() => keySearch = v),
                                  style: const TextStyle(
                                      color: Colors.white, fontSize: 14),
                                  decoration: InputDecoration(
                                    hintText: "search_movies".tr,
                                    hintStyle: const TextStyle(color: Colors.white38),
                                    prefixIcon: const Icon(
                                        FontAwesomeIcons.magnifyingGlass,
                                        color: Colors.white38,
                                        size: 15),
                                    border: InputBorder.none,
                                    contentPadding: const EdgeInsets.only(top: 10),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 18, vertical: 10),
                              decoration: BoxDecoration(
                                color: const Color(0xFFB8860B),
                                borderRadius: BorderRadius.circular(25),
                                boxShadow: [
                                  BoxShadow(
                                      color: const Color(0xFFB8860B)
                                          .withOpacity(0.3),
                                      blurRadius: 10)
                                ],
                              ),
                              child: Text(
                                "$count فيلم",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12.sp,
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),

                  // Grid
                  Expanded(
                    child: BlocBuilder<ChannelsBloc, ChannelsState>(
                      builder: (context, state) {
                        if (state is ChannelsLoading) {
                          return const Center(
                              child: CircularProgressIndicator());
                        } else if (state is ChannelsMovieSuccess) {
                          final channels = state.channels;
                          final List<ChannelMovie> displayList =
                              keySearch.isEmpty
                                  ? channels
                                  : channels
                                      .where((e) => e.name!
                                          .toLowerCase()
                                          .contains(keySearch.toLowerCase()))
                                      .toList();

                          return GridView.builder(
                            controller: _gridScrollCtrl,
                            padding: const EdgeInsets.fromLTRB(16, 4, 16, 80),
                            itemCount: displayList.length,
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 6,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                              childAspectRatio: 0.65,
                            ),
                            itemBuilder: (_, i) {
                              final model = displayList[i];
                              return CardChannelMovieItem(
                                title: model.name,
                                image: model.streamIcon,
                                onTap: () {
                                  Get.to(() => MovieContent(
                                          channelMovie: model,
                                          videoId: model.streamId ?? ''))!
                                      .then((value) async {
                                    if (showAds && _interstitialAd != null) {
                                      _interstitialAd!.show();
                                      _loadIntel();
                                    }
                                  });
                                },
                              );
                            },
                          );
                        }
                        return const SizedBox();
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
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
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFB8860B) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.white70,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            fontSize: 13.5.sp,
          ),
        ),
      ),
    );
  }
}
