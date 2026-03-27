part of 'screens.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  InterstitialAd? _interstitialAd;
  bool _isAdLoaded = false;

  Future<void> _loadIntel() async {
    if (!showAds) return;
    InterstitialAd.load(
        adUnitId: kInterstitial,
        request: const AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (InterstitialAd ad) {
            _interstitialAd = ad;
            _isAdLoaded = true;
          },
          onAdFailedToLoad: (LoadAdError error) {
            _isAdLoaded = false;
            debugPrint('InterstitialAd failed to load: $error');
          },
        ));
  }

  @override
  void initState() {
    context.read<FavoritesCubit>().initialData();
    context.read<WatchingCubit>().initialData();
    _loadIntel();
    super.initState();
  }

  Future<void> _onNavigate(String route) async {
    await Get.toNamed(route);
    if (showAds && _isAdLoaded && _interstitialAd != null) {
      debugPrint("show interstitial");
      await _interstitialAd!.show();
      await _loadIntel();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Ink(
        width: getSize(context).width,
        height: getSize(context).height,
        decoration: kDecorBackground,
        padding: const EdgeInsets.only(left: 10, right: 10, top: 15),
        child: Column(
          children: [
            const AppBarWelcome(),
            const SizedBox(height: 10),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Row(
                  children: [
                    // ── LIVE TV ──────────────────────────────────────
                    Expanded(
                      child: BlocBuilder<LiveCatyBloc, LiveCatyState>(
                        builder: (context, state) {
                          final sub = state is LiveCatySuccess
                              ? "${state.categories.length} قناة"
                              : "";
                          if (state is LiveCatyLoading) {
                            return const Center(
                                child: CircularProgressIndicator());
                          }
                          return CardWelcomeTv(
                            title: "live_tv".tr,
                            autoFocus: true,
                            subTitle: sub,
                            icon: kIconLive,
                            onTap: () => _onNavigate(screenLiveCategories),
                          );
                        },
                      ),
                    ),
                    SizedBox(width: 2.w),
                    // ── MOVIES ───────────────────────────────────────
                    Expanded(
                      child: BlocBuilder<MovieCatyBloc, MovieCatyState>(
                        builder: (context, state) {
                          final sub = state is MovieCatySuccess
                              ? "${state.categories.length} فيلم"
                              : "";
                          if (state is MovieCatyLoading) {
                            return const Center(
                                child: CircularProgressIndicator());
                          }
                          return CardWelcomeTv(
                            title: "movies".tr,
                            subTitle: sub,
                            icon: kIconMovies,
                            onTap: () => _onNavigate(screenMovieCategories),
                          );
                        },
                      ),
                    ),
                    SizedBox(width: 2.w),
                    // ── SERIES ───────────────────────────────────────
                    Expanded(
                      child: BlocBuilder<SeriesCatyBloc, SeriesCatyState>(
                        builder: (context, state) {
                          final sub = state is SeriesCatySuccess
                              ? "${state.categories.length} مسلسل"
                              : "";
                          if (state is SeriesCatyLoading) {
                            return const Center(
                                child: CircularProgressIndicator());
                          }
                          return CardWelcomeTv(
                            title: "series".tr,
                            subTitle: sub,
                            icon: kIconSeries,
                            onTap: () => _onNavigate(screenSeriesCategories),
                          );
                        },
                      ),
                    ),
                    SizedBox(width: 2.w),
                    // ── SIDE BUTTONS ─────────────────────────────────
                    SizedBox(
                      width: 20.w,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          CardWelcomeSetting(
                            title: 'الأرشيف',
                            icon: FontAwesomeIcons.rotate,
                            onTap: () => Get.toNamed(screenCatchUp),
                          ),
                          CardWelcomeSetting(
                            title: 'favorites'.tr,
                            icon: FontAwesomeIcons.heart,
                            onTap: () => Get.toNamed(screenFavourite),
                          ),
                          CardWelcomeSetting(
                            title: 'settings'.tr,
                            icon: FontAwesomeIcons.gear,
                            onTap: () => Get.toNamed(screenSettings),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'باستخدامك للتطبيق، انت موافق على ',
                  style: Get.textTheme.titleSmall!.copyWith(
                    fontSize: 12.sp,
                    color: Colors.grey,
                  ),
                ),
                InkWell(
                  onTap: () async {
                    await launchUrlString(kPrivacy);
                  },
                  child: Text(
                    ' شروط الخدمة.',
                    style: Get.textTheme.titleSmall!.copyWith(
                      fontSize: 12.sp,
                      color: Colors.blue,
                    ),
                  ),
                ),
              ],
            ),
            AdmobWidget.getBanner(),
          ],
        ),
      ),
    );
  }
}
