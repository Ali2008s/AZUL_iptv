part of '../screens.dart';

class LiveCategoriesScreen extends StatefulWidget {
  const LiveCategoriesScreen({super.key});

  @override
  State<LiveCategoriesScreen> createState() => _LiveCategoriesScreenState();
}

class _LiveCategoriesScreenState extends State<LiveCategoriesScreen> {
  final ScrollController _hideButtonController = ScrollController();
  bool _hideButton = true;
  String keySearch = "";

  InterstitialAd? _interstitialAd;
  _loadIntel() async {
    if (!showAds) {
      return;
    }
    InterstitialAd.load(
        adUnitId: kInterstitial,
        request: const AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (InterstitialAd ad) {
            debugPrint("Ads is Loaded");
            _interstitialAd = ad;
          },
          onAdFailedToLoad: (LoadAdError error) {
            debugPrint('InterstitialAd failed to load: $error');
          },
        ));
  }

  @override
  void initState() {
    //WakelockPlus.enable();
    _loadIntel();
    _hideButtonController.addListener(() {
      if (_hideButtonController.position.userScrollDirection ==
          ScrollDirection.reverse) {
        if (_hideButton == true) {
          setState(() {
            _hideButton = false;
          });
        }
      } else {
        if (_hideButtonController.position.userScrollDirection ==
            ScrollDirection.forward) {
          if (_hideButton == false) {
            setState(() {
              _hideButton = true;
            });
          }
        }
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          Ink(
            width: 100.w,
            height: 100.h,
            decoration: kDecorBackground,
            child: Column(
              children: [
                // ─── AppBar ───────────────────────────────────────────────
                Padding(
                  padding: EdgeInsets.only(
                      top: 2.h, left: 16, right: 16, bottom: 8),
                  child: Row(
                    children: [
                      // Back button
                      InkWell(
                        onTap: () => Get.back(),
                        focusColor: kColorFocus,
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: kColorCardLight,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(FontAwesomeIcons.chevronRight,
                              color: Colors.white, size: 16),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Text(
                        "البث المباشر",
                        style: Get.textTheme.headlineMedium!.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const Spacer(),
                      // Search bar
                      SizedBox(
                        width: 32.w,
                        height: 40,
                        child: TextField(
                          onChanged: (value) {
                            setState(() {
                              keySearch = value.toLowerCase();
                            });
                          },
                          style: const TextStyle(
                              color: Colors.white, fontSize: 13),
                          decoration: InputDecoration(
                            hintText: "البحث في الفئات",
                            hintStyle:
                                const TextStyle(color: Colors.white54),
                            prefixIcon: const Icon(
                                FontAwesomeIcons.magnifyingGlass,
                                color: Colors.white54,
                                size: 14),
                            filled: true,
                            fillColor: kColorCardLight,
                            contentPadding: EdgeInsets.zero,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // ─── Body ─────────────────────────────────────────────────
                Expanded(
                  child: BlocBuilder<LiveCatyBloc, LiveCatyState>(
                    builder: (context, state) {
                      if (state is LiveCatyLoading) {
                        return const Center(
                            child: CircularProgressIndicator());
                      } else if (state is LiveCatySuccess) {
                        final categories = state.categories;

                        List<CategoryModel> searchCaty = keySearch.isEmpty
                            ? categories
                            : categories
                                .where((element) => element.categoryName!
                                    .toLowerCase()
                                    .contains(keySearch))
                                .toList();

                        return GridView.builder(
                          controller: _hideButtonController,
                          padding: const EdgeInsets.only(
                            left: 16,
                            right: 16,
                            top: 4,
                            bottom: 80,
                          ),
                          itemCount: searchCaty.length,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 4,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                            childAspectRatio: 3.8,
                          ),
                          itemBuilder: (_, i) {
                            final model = searchCaty[i];

                            return CardLiveItem(
                              title: model.categoryName ?? "",
                              onTap: () {
                                /// OPEN Channels
                                Get.to(() => LiveChannelsScreen(
                                        catyId:
                                            model.categoryId ?? ''))!
                                    .then((value) async {
                                  if (showAds && _interstitialAd != null) {
                                    await _interstitialAd!.show();
                                    await _loadIntel();
                                  }
                                });
                              },
                            );
                          },
                        );
                      }

                      return const Center(
                        child: Text("Failed to load data..."),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          AdmobWidget.getBanner(),
        ],
      ),
    );
  }
}
