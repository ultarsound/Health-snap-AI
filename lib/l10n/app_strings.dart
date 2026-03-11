class AppStrings {
  final bool isAr;
  const AppStrings._(this.isAr);

  factory AppStrings.from(bool isArabic) => AppStrings._(isArabic);

  String _t(String ar, String en) => isAr ? ar : en;

  // App
  String get appName => _t('حياة صحية', 'Healthy Life');
  String get hello => _t('مرحباً! 👋', 'Hello! 👋');
  String get startToday => _t('ابدأ اليوم', 'Start Today');

  // Bottom nav
  String get navHome => _t('الرئيسية', 'Home');
  String get navCamera => _t('الكاميرا', 'Camera');
  String get navProfile => _t('البروفايل', 'Profile');
  String get navSettings => _t('الإعدادات', 'Settings');

  // Home
  String get homeSubtitle => _t('حياة صحية أفضل', 'A Healthier Life');
  String get searchHint =>
      _t('ابحث عن وجبة أو تمرين...', 'Search meals or exercises...');
  String get tabFood => _t('أكل صحي', 'Healthy Food');
  String get tabExercise => _t('تمارين', 'Exercises');
  String get noResults => _t('لا توجد نتائج', 'No results found');
  String get noExercises => _t('لا توجد تمارين', 'No exercises found');

  // Notifications
  String get notificationsTitle => _t('الإشعارات', 'Notifications');
  String get markAllRead => _t('قراءة الكل', 'Mark all read');
  String get noNotifications => _t('لا توجد إشعارات', 'No notifications');

  String formatAgo(int amount, String unitAr, String unitEn) =>
      isAr ? 'منذ $amount $unitAr' : '$amount $unitEn ago';
  String get minUnit => _t('دقيقة', 'min');
  String get hrUnit => _t('ساعة', 'hr');
  String get dayUnit => _t('يوم', 'day');

  // Camera
  String get cameraTitle => _t('تحليل الوجبات ', 'Meal Analysis ');
  String get cameraSubtitle => _t('صوّر وجبتك وسنحلل سعراتها الحرارية',
      'Photograph your meal — we\'ll analyze its calories');
  String get takePhoto => _t('التقط صورة', 'Take Photo');
  String get takePhotoSub =>
      _t('افتح الكاميرا وصوّر وجبتك', 'Open camera and photograph your meal');
  String get chooseGallery => _t('اختر من المعرض', 'Choose from Gallery');
  String get chooseGallerySub =>
      _t('اختر صورة من ألبوم الصور', 'Select an image from your photo album');
  String get analyzing =>
      _t('🤖 جاري التحليل بالذكاء الاصطناعي', '🤖 Analyzing with AI...');
  String get analyzingDetail => _t('يتم تحليل الوجبة وحساب السعرات...',
      'Analyzing meal and calculating calories...');
  String get caloriesUnit => _t('سعرة حرارية', 'calories');
  String get healthRisks => _t('مخاطر صحية', 'Health Risks');
  String get healthyAlts => _t('بدائل صحية 🥗', 'Healthy Alternatives 🥗');
  String get nutrientsLabel => _t('القيم الغذائية', 'Nutritional Values');
  String get cameraBtn => _t('كاميرا', 'Camera');
  String get galleryBtn => _t('معرض', 'Gallery');
  String get score => _t('النقاط', 'Score');

  // Recipe detail
  String get tabIngredients => _t('المكونات', 'Ingredients');
  String get tabInstructions => _t('طريقة التحضير', 'Instructions');
  String get tabBenefits => _t('الفوائد', 'Benefits');
  String get tabHowTo => _t('كيفية التمرين', 'How-To');
  String get noIngredients => _t('لا توجد مكونات', 'No ingredients');
  String get viewRecipeLabel => _t('اعرف الوصفة', 'View Recipe');
  String get detailsLabel => _t('التفاصيل', 'Details');

  // Settings
  String get settingsTitle => _t('الإعدادات ', 'Settings ');
  String get secLanguage => _t('اللغة', 'Language');
  String get langArabic => 'العربية';
  String get langEnglish => 'English';
  String get secAppearance => _t('المظهر', 'Appearance');
  String get secNotifications => _t('الإشعارات', 'Notifications');
  String get secHealth => _t('بياناتك الصحية', 'Your Health Data');
  String get darkMode => _t('الوضع الليلي', 'Dark Mode');
  String get darkModeOn => _t('مفعّل - وضع داكن', 'Enabled — Dark mode');
  String get darkModeOff => _t('معطّل - وضع فاتح', 'Disabled — Light mode');
  String get muteNotifs => _t('كتم الإشعارات', 'Mute Notifications');
  String get notifsMuted => _t('الإشعارات مكتومة', 'Notifications muted');
  String get notifsActive => _t('الإشعارات مفعّلة', 'Notifications enabled');
  String get weightLabel => _t('وزنك الحالي', 'Your Current Weight');
  String get weightSub => _t('أدخل وزنك لحساب إحصائيات الصحة',
      'Enter your weight to calculate health stats');
  String get weightHint => 'Enter your weight (kg)';
  String get save => _t('حفظ', 'Save');
  String get weightSaved => _t(' تم حفظ وزنك', ' Weight saved');
  String get statsTitle =>
      _t('إحصائيات فقدان الوزن المتوقعة ', 'Estimated Weight Loss Statistics ');
  String get statsTip => _t(
      'تقديرات تقريبية بافتراض نقص 500 سعرة يومياً مع الرياضة 3× أسبوعياً',
      'Approximate: assumes 500-calorie daily deficit with exercise 3×/week');
  String get statsSubtitle => _t('بناءً على نظام غذائي صحي وتمارين منتظمة:',
      'Based on a healthy diet and regular exercise:');
  String get weekLabel => _t('أسبوع', 'Week');
  String get monthLabel => _t('شهر', 'Month');
  String get threeMonthsLabel => _t('3 أشهر', '3 Months');
  String get week1Label => _t('أسبوع 1', 'Week 1');
  String get month1Label => _t('شهر 1', 'Month 1');
  String get threeMonths1 => _t('3 أشهر', '3 Months');
  String get journeyTitle => _t('رحلة فقدان الوزن', 'Weight Loss Journey');
  String get enterWeightHint => _t('أدخل وزنك أعلاه لرؤية إحصائيات فقدان الوزن',
      'Enter your weight above to see weight loss statistics');

  // Profile
  String get profileSoon => _t('البروفايل ', 'Profile ');

  // Benefits extras

  List<String> get extraFoodBenefits => [
        _t(' يوفر الألياف الضرورية للجهاز الهضمي',
            ' Provides dietary fiber for digestion'),
        _t(' يحتوي على فيتامينات ومعادن أساسية',
            ' Contains essential vitamins & minerals'),
        _t(' يساعد في الوقاية من أمراض القلب',
            ' Helps prevent cardiovascular disease'),
        _t(' يساعد في الحفاظ على وزن صحي',
            ' Supports maintaining a healthy weight'),
      ];

  List<String> get extraExerciseBenefits => [
        _t(' يحرق السعرات الحرارية الزائدة',
            ' Burns excess calories effectively'),
        _t(' يقوي العضلات ويزيد المرونة',
            ' Strengthens muscles & improves flexibility'),
        _t(' يحسن المزاج ويقلل التوتر', ' Boosts mood and reduces stress'),
        _t(' يقلل خطر الإصابة بالسكر والضغط',
            ' Lowers risk of diabetes & hypertension'),
      ];

  // ── Camera analysis extras ─────────────────────────────
  List<String> get risks => [
        _t('ارتفاع في السعرات قد يؤدي لزيادة الوزن',
            'High calories may cause weight gain'),
        _t('قد يحتوي على دهون مشبعة', 'May contain saturated fats'),
      ];

  List<String> get alternatives => [
        _t('سلطة خضار طازجة', 'Fresh vegetable salad'),
        _t('فاكهة موسمية', 'Seasonal fruits'),
      ];
}
