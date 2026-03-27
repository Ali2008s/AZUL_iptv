import 'package:get/get.dart';

class AppTranslations extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
        'ar': {
          'app_name': 'عالمنا+',
          'live_tv': 'قنوات لايف',
          'movies': 'أفلام',
          'series': 'مسلسلات',
          'favorites': 'المفضلات',
          'settings': 'الإعدادات',
          'logout': 'تسجيل خروج',
          'search_caty': 'دور بالفئات..',
          'search_channels': 'دور ع القناة..',
          'search_movies': 'دور ع فيلمك المفضل..',
          'search_series': 'دور ع مسلسلك المفضل..',
          'now_watching': 'جاي تتابع',
          'full_screen_hint': 'دوس OK حتى تكبر الشاشة',
          'select_channel_hint': 'اختار قناة حتى تباوع',
          'no_channels': 'ماكو قنوات هنا..',
          'back': 'رجوع',
          'all': 'الكل',
          'username': 'اسمك (اليوزر)',
          'password': 'الرمز (الباسورد)',
          'server_url': 'رابط السيرفر',
          'login': 'طب للتطبيق',
          'loading': 'جاي يحمل..',
          'error': 'صار خطأ، جرب مرة ثانية',
          'exit_confirm': 'تريد تطلع؟',
          'yes': 'اي',
          'no': 'لا',
        }
      };
}
