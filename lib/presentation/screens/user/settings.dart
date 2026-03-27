part of '../screens.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  int _selectedIndex = 0;
  int _focusedMenuIndex = -1;
  final ScrollController _contentScroll = ScrollController();

  final List<Map<String, dynamic>> _menuItems = [
    {'title': 'معلومات الحساب', 'icon': Icons.person_outline_rounded},
    {'title': 'الرقابة الأبوية', 'icon': Icons.security_rounded},
    {'title': 'إجراءات النظام', 'icon': Icons.auto_fix_high_rounded},
    {'title': 'حول التطبيق', 'icon': Icons.info_outline_rounded},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: 100.w,
        height: 100.h,
        decoration: kDecorBackground,
        child: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            if (state is AuthSuccess) {
              final userInfo = state.user;
              return Row(
                children: [
                  // Sidebar on Left
                  _buildSidebar(),
                  // Content Area
                  Expanded(
                    child: Container(
                      margin: EdgeInsets.all(1.5.w),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(20),
                        border:
                            Border.all(color: Colors.white.withOpacity(0.1)),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: SingleChildScrollView(
                          controller: _contentScroll,
                          padding: EdgeInsets.all(2.w),
                          child: _buildContent(userInfo),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }
            return const Center(child: CircularProgressIndicator());
          },
        ),
      ),
    );
  }

  Widget _buildSidebar() {
    return Container(
      width: 25.w,
      padding: EdgeInsets.symmetric(vertical: 4.h, horizontal: 1.w),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.2),
        border: Border(right: BorderSide(color: Colors.white.withOpacity(0.1))),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 1.w),
            child: Row(
              children: [
                IconButton(
                  onPressed: () => Get.back(),
                  icon: const Icon(Icons.arrow_back_ios_new_rounded,
                      color: Colors.white, size: 20),
                ),
                Text(
                  "الإعدادات",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 5.h),
          Expanded(
            child: ListView.separated(
              itemCount: _menuItems.length,
              separatorBuilder: (context, index) => SizedBox(height: 1.h),
              itemBuilder: (context, index) {
                final item = _menuItems[index];
                return _buildMenuTile(
                  index: index,
                  title: item['title'],
                  icon: item['icon'],
                  isSelected: _selectedIndex == index,
                  onTap: () => setState(() => _selectedIndex = index),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuTile({
    required int index,
    required String title,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    bool isFocused = _focusedMenuIndex == index;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: EdgeInsets.symmetric(horizontal: 1.w),
      decoration: BoxDecoration(
        color: isSelected
            ? kColorPrimary
            : (isFocused ? Colors.white.withOpacity(0.1) : Colors.transparent),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: isFocused ? Colors.white : Colors.transparent,
          width: 2,
        ),
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: kColorPrimary.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                )
              ]
            : [],
      ),
      child: InkWell(
        onTap: onTap,
        onFocusChange: (val) {
          if (val) setState(() => _focusedMenuIndex = index);
        },
        focusColor: Colors.transparent,
        borderRadius: BorderRadius.circular(15),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 1.2.w, vertical: 1.8.h),
          child: Row(
            children: [
              Icon(
                icon,
                color:
                    (isSelected || isFocused) ? Colors.white : Colors.white60,
                size: 16.sp,
              ),
              SizedBox(width: 1.w),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: (isSelected || isFocused)
                        ? Colors.white
                        : Colors.white60,
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                    fontSize: 12.sp,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (isSelected)
                const Icon(Icons.chevron_right_rounded,
                    color: Colors.white, size: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent(UserModel userInfo) {
    switch (_selectedIndex) {
      case 0:
        return _buildAccountInfo(userInfo);
      case 1:
        return _buildParentalControl();
      case 2:
        return _buildGeneralSettings();
      case 3:
        return _buildAbout();
      default:
        return const SizedBox();
    }
  }

  Widget _buildAccountInfo(UserModel userInfo) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader("تفاصيل الحساب", Icons.badge_outlined),
        SizedBox(height: 4.h),
        Row(
          children: [
            _buildInfoCard("اسم المستخدم", userInfo.userInfo!.username ?? "N/A",
                Icons.alternate_email_rounded),
            _buildInfoCard("حالة الاشتراك", "نشط", Icons.verified_user_rounded,
                isStatus: true),
          ],
        ),
        SizedBox(height: 2.h),
        Row(
          children: [
            _buildInfoCard(
                "تاريخ الانتهاء",
                expirationDate(userInfo.userInfo!.expDate),
                Icons.calendar_today_rounded),
            _buildInfoCard("سيرفر الاتصال",
                userInfo.serverInfo!.serverUrl ?? "N/A", Icons.dns_rounded),
          ],
        ),
      ],
    );
  }

  Widget _buildInfoCard(String label, String value, IconData icon,
      {bool isStatus = false}) {
    return Expanded(
      child: Container(
        margin: EdgeInsets.all(0.5.w),
        padding: EdgeInsets.all(1.w),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.03),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(0.8.w),
              decoration: BoxDecoration(
                color: kColorPrimary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: kColorPrimary, size: 16.sp),
            ),
            SizedBox(width: 1.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(label,
                      style: TextStyle(color: Colors.white60, fontSize: 10.sp),
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: TextStyle(
                      color: isStatus ? Colors.greenAccent : Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 11.sp,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildParentalControl() {
    bool isEnabled = LocaleApi.getAdultFilter();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader("الرقابة الأبوية", Icons.family_restroom_rounded),
        SizedBox(height: 4.h),
        Container(
          padding: EdgeInsets.all(1.w),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.03),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            children: [
              _buildToggleSetting(
                title: "فلتر المحتوى للبالغين",
                subtitle:
                    "إخفاء القنوات والأفلام التي تحتوي على محتوى للكبار تلقائياً",
                value: isEnabled,
                onChanged: (val) {
                  _handleAdultFilterToggle(val);
                },
              ),
              const Divider(color: Colors.white10),
              _buildActionTile(
                title: "تغيير رمز الحماية (PIN)",
                subtitle: "تعيين رمز سري لمنع تغيير الإعدادات",
                icon: Icons.password_rounded,
                onTap: () => _handleSetPin(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _handleAdultFilterToggle(bool newVal) async {
    String? pin = await LocaleApi.getPin();
    if (pin == null || pin.isEmpty) {
      // Step 1: Force set a PIN first if not exists
      _showSetPinDialog((success) async {
        if (success) {
          await LocaleApi.setAdultFilter(newVal);
          _refreshData();
        }
      });
    } else {
      // Verify existing PIN
      _showVerifyPinDialog(pin, (success) async {
        if (success) {
          await LocaleApi.setAdultFilter(newVal);
          _refreshData();
        }
      });
    }
  }

  void _handleSetPin() async {
    String? pin = await LocaleApi.getPin();
    if (pin != null && pin.isNotEmpty) {
      _showVerifyPinDialog(pin, (success) {
        if (success) _showSetPinDialog((_) => null);
      });
    } else {
      _showSetPinDialog((_) => null);
    }
  }

  void _refreshData() {
    setState(() {});
    context.read<LiveCatyBloc>().add(GetLiveCategories());
    context.read<MovieCatyBloc>().add(GetMovieCategories());
    context.read<SeriesCatyBloc>().add(GetSeriesCategories());
  }

  void _showSetPinDialog(Function(bool) onComplete) {
    final controller = TextEditingController();
    Get.dialog(
      AlertDialog(
        backgroundColor: kColorBackDark,
        title: const Text("ضبط رمز الحماية (PIN)",
            style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("أدخل رمزاً مكوناً من 4 أرقام",
                style: TextStyle(color: Colors.white70)),
            const SizedBox(height: 15),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              maxLength: 4,
              obscureText: true,
              style: const TextStyle(
                  color: Colors.white, fontSize: 24, letterSpacing: 10),
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white.withOpacity(0.05),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text("إلغاء")),
          ElevatedButton(
            onPressed: () async {
              if (controller.text.length == 4) {
                await LocaleApi.savePin(controller.text);
                Get.back();
                onComplete(true);
                Get.snackbar("تم", "تم حفظ الرمز السري بنجاح",
                    backgroundColor: Colors.green);
              }
            },
            child: const Text("حفظ"),
          ),
        ],
      ),
    );
  }

  void _showVerifyPinDialog(String correctPin, Function(bool) onComplete) {
    final controller = TextEditingController();
    Get.dialog(
      AlertDialog(
        backgroundColor: kColorBackDark,
        title: const Text("تأكيد الرمز السري",
            style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("يرجى إدخال الرمز السري للمتابعة",
                style: TextStyle(color: Colors.white70)),
            const SizedBox(height: 15),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              maxLength: 4,
              obscureText: true,
              style: const TextStyle(
                  color: Colors.white, fontSize: 24, letterSpacing: 10),
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white.withOpacity(0.05),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
              autofocus: true,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text("إلغاء")),
          ElevatedButton(
            onPressed: () {
              if (controller.text == correctPin) {
                Get.back();
                onComplete(true);
              } else {
                Get.snackbar("خطأ", "الرمز السري غير صحيح",
                    backgroundColor: Colors.red);
              }
            },
            child: const Text("تأكيد"),
          ),
        ],
      ),
    );
  }

  Widget _buildGeneralSettings() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader("إجراءات النظام", Icons.auto_fix_high_rounded),
        SizedBox(height: 4.h),
        Wrap(
          spacing: 2.w,
          runSpacing: 2.h,
          children: [
            _buildBigButton(
              title: "تحديث البيانات",
              desc: "جلب أحدث القنوات من السيرفر",
              icon: Icons.sync_rounded,
              color: Colors.blueAccent,
              onTap: () {
                _refreshData();
                Get.snackbar("تم", "تم تحديث البيانات",
                    backgroundColor: Colors.green.withOpacity(0.8));
              },
            ),
            _buildBigButton(
              title: "إضافة ملف",
              desc: "العودة لشاشة تسجيل الدخول",
              icon: Icons.group_add_rounded,
              color: Colors.orangeAccent,
              onTap: () {
                context.read<AuthBloc>().add(AuthLogOut());
                Get.offAllNamed("/");
              },
            ),
            _buildBigButton(
              title: "تسجيل الخروج",
              desc: "حذف بيانات المستخدم الحالي",
              icon: Icons.logout_rounded,
              color: Colors.redAccent,
              onTap: () {
                context.read<AuthBloc>().add(AuthLogOut());
                Get.offAllNamed("/");
                Get.reload();
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAbout() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 15.w,
            height: 15.w,
            decoration: const BoxDecoration(
              image: DecorationImage(image: AssetImage(kIconSplash)),
            ),
          ),
          SizedBox(height: 3.h),
          Text(kAppName,
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18.sp)),
          Text("الإصدار 2.5.0",
              style: TextStyle(color: kColorHint, fontSize: 12.sp)),
          SizedBox(height: 5.h),
          Text("@Arix",
              style:
                  TextStyle(color: kColorPrimary, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: kColorPrimary, size: 20.sp),
        SizedBox(width: 1.w),
        Expanded(
          child: Text(
            title,
            style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 15.sp),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildToggleSetting({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Focus(
      child: Builder(builder: (context) {
        bool focused = Focus.of(context).hasFocus;
        return Container(
          decoration: BoxDecoration(
            color:
                focused ? Colors.white.withOpacity(0.05) : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: ListTile(
            title: Text(title,
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)),
            subtitle:
                Text(subtitle, style: const TextStyle(color: Colors.white60)),
            trailing: CupertinoSwitch(
                value: value, onChanged: onChanged, activeColor: kColorPrimary),
            onTap: () => onChanged(!value),
          ),
        );
      }),
    );
  }

  Widget _buildActionTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Focus(
      child: Builder(builder: (context) {
        bool focused = Focus.of(context).hasFocus;
        return Container(
          decoration: BoxDecoration(
            color:
                focused ? Colors.white.withOpacity(0.05) : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: ListTile(
            leading: Icon(icon, color: Colors.white70),
            title: Text(title,
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)),
            subtitle:
                Text(subtitle, style: const TextStyle(color: Colors.white60)),
            trailing: const Icon(Icons.arrow_forward_ios_rounded,
                color: Colors.white24, size: 16),
            onTap: onTap,
          ),
        );
      }),
    );
  }

  Widget _buildBigButton({
    required String title,
    required String desc,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Focus(
      child: Builder(builder: (context) {
        bool focused = Focus.of(context).hasFocus;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 20.w,
          constraints: BoxConstraints(minHeight: 18.h),
          decoration: BoxDecoration(
            color: focused ? color.withOpacity(0.2) : color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
                color: focused ? Colors.white : color.withOpacity(0.3),
                width: 2),
            boxShadow: focused
                ? [BoxShadow(color: color.withOpacity(0.4), blurRadius: 15)]
                : [],
          ),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(20),
            child: Padding(
              padding: EdgeInsets.all(1.w),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, color: color, size: 22.sp),
                  SizedBox(height: 0.5.h),
                  Text(title,
                      style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                      maxLines: 1),
                  const SizedBox(height: 2),
                  Text(desc,
                      textAlign: TextAlign.center,
                      style:
                          const TextStyle(color: Colors.white54, fontSize: 9),
                      maxLines: 2),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }
}
