import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/health_item.dart';

class ApiService {
  static const String _mealBase = 'https://www.themealdb.com/api/json/v1/1';

  // ── Meals ──────────────────────────────────────────────────────────────────
  static Future<List<HealthItem>> fetchHealthyMeals({
    String query = '',
    bool isArabic = true,
  }) async {
    try {
      final url = query.isNotEmpty
          ? '$_mealBase/search.php?s=$query'
          : '$_mealBase/filter.php?c=Vegetarian';

      final res = await http.get(Uri.parse(url));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final meals = data['meals'] as List?;
        if (meals == null) return _fallbackMeals(isArabic);

        if (query.isEmpty) {
          final enriched = <HealthItem>[];
          for (final m in meals.take(50)) {
            final full = await fetchMealDetail(m['idMeal'].toString(),
                isArabic: isArabic);
            if (full != null) enriched.add(full);
          }
          return enriched.isNotEmpty ? enriched : _fallbackMeals(isArabic);
        }

        final benefits = isArabic
            ? ['غني بالفيتامينات', 'يقوي المناعة', 'يساعد في التحكم بالوزن']
            : [
                'Rich in vitamins',
                'Boosts immunity',
                'Supports weight control'
              ];

        return meals
            .take(10)
            .map((m) => HealthItem.fromJson({
                  ...m,
                  'benefits': benefits,
                  'type': 'food',
                }))
            .toList();
      }
    } catch (e) {
      print('Meal API Error: $e');
    }
    return _fallbackMeals(isArabic);
  }

  // ── Full recipe ────────────────────────────────────────────────────────────
  static Future<HealthItem?> fetchMealDetail(String id,
      {bool isArabic = true}) async {
    try {
      final res = await http.get(Uri.parse('$_mealBase/lookup.php?i=$id'));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final meals = data['meals'] as List?;
        if (meals != null && meals.isNotEmpty) {
          final m = meals.first as Map<String, dynamic>;
          final benefits = isArabic
              ? ['غني بالفيتامينات', 'يقوي المناعة', 'يساعد في التحكم بالوزن']
              : [
                  'Rich in vitamins',
                  'Boosts immunity',
                  'Supports weight control'
                ];
          return HealthItem.fromJson(
              {...m, 'benefits': benefits, 'type': 'food'});
        }
      }
    } catch (e) {
      print('Detail fetch error: $e');
    }
    return null;
  }

  // ── Exercises ──────────────────────────────────────────────────────────────
  static Future<List<HealthItem>> fetchExercises({bool isArabic = true}) async {
    return _fallbackExercises(isArabic);
  }

  // ── Notifications ──────────────────────────────────────────────────────────
  static Future<List<HealthNotification>> fetchHealthNotifications(
      {bool isArabic = true}) async {
    if (isArabic) {
      return [
        HealthNotification(
            id: '1',
            title: '💪 تذكير تمرين اليوم',
            body: 'حان وقت تمرين المشي اليومي لمدة 30 دقيقة',
            time: DateTime.now().subtract(const Duration(minutes: 30))),
        HealthNotification(
            id: '2',
            title: '🥗 وجبة صحية مقترحة',
            body: 'جرب سلطة الخضار مع الدجاج المشوي لوجبة الغداء اليوم',
            time: DateTime.now().subtract(const Duration(hours: 2))),
        HealthNotification(
            id: '3',
            title: '💧 شرب الماء',
            body: 'تذكر شرب 8 أكواب من الماء يومياً للحفاظ على الصحة',
            time: DateTime.now().subtract(const Duration(hours: 5))),
        HealthNotification(
            id: '4',
            title: '🩺 نصيحة صحية',
            body: 'الخضروات الورقية تساعد في الوقاية من السكر والضغط',
            time: DateTime.now().subtract(const Duration(hours: 8))),
        HealthNotification(
            id: '5',
            title: '😴 نوم صحي',
            body: 'النوم 7-8 ساعات يومياً يعزز المناعة ويساعد في التحكم بالوزن',
            time: DateTime.now().subtract(const Duration(days: 1))),
      ];
    } else {
      return [
        HealthNotification(
            id: '1',
            title: '💪 Daily Workout Reminder',
            body: 'Time for your 30-minute daily walk — let\'s go!',
            time: DateTime.now().subtract(const Duration(minutes: 30))),
        HealthNotification(
            id: '2',
            title: '🥗 Healthy Meal Suggestion',
            body: 'Try a grilled chicken salad for a nutritious lunch today',
            time: DateTime.now().subtract(const Duration(hours: 2))),
        HealthNotification(
            id: '3',
            title: '💧 Stay Hydrated',
            body: 'Remember to drink 8 glasses of water daily to stay healthy',
            time: DateTime.now().subtract(const Duration(hours: 5))),
        HealthNotification(
            id: '4',
            title: '🩺 Health Tip',
            body: 'Leafy greens help protect against diabetes and hypertension',
            time: DateTime.now().subtract(const Duration(hours: 8))),
        HealthNotification(
            id: '5',
            title: '😴 Healthy Sleep',
            body:
                'Getting 7-8 hours of sleep boosts immunity and controls weight',
            time: DateTime.now().subtract(const Duration(days: 1))),
      ];
    }
  }

  // ── Fallback meals ─────────────────────────────────────────────────────────
  static List<HealthItem> _fallbackMeals(bool ar) => ar
      ? [
          HealthItem(
            id: '1',
            mealDbId: '52772',
            title: 'سلطة الخضروات الطازجة',
            description:
                'سلطة غنية بالفيتامينات والمعادن مع صلصة الليمون والزيتون',
            category: 'سلطات',
            imageUrl:
                'https://www.themealdb.com/images/media/meals/wruvqv1491515292.jpg',
            benefits: ['تخفض الكوليسترول', 'تنظم السكر', 'غنية بالألياف'],
            type: 'food',
            ingredients: [
              'خس',
              'طماطم',
              'خيار',
              'فلفل',
              'زيت زيتون',
              'ليمون',
              'ملح'
            ],
            measures: [
              'حفنة',
              '2 حبة',
              '1 حبة',
              '1/2 حبة',
              '3 ملاعق',
              '1 حبة',
              'رشة'
            ],
            instructions:
                '1. اغسل الخضروات جيداً.\n2. قطّع الخس والطماطم والخيار والفلفل.\n3. ضعها في طبق كبير.\n4. اعصر الليمون وأضف زيت الزيتون والملح.\n5. قلّب جيداً وقدّمها باردة.',
            area: 'عربي',
          ),
          HealthItem(
            id: '2',
            mealDbId: '52959',
            title: 'صدر دجاج مشوي بالأعشاب',
            description:
                'دجاج مشوي منخفض الدهون مع توابل طبيعية مضادة للالتهاب',
            category: 'بروتين',
            imageUrl:
                'https://www.themealdb.com/images/media/meals/xvquge1483528428.jpg',
            benefits: ['بروتين عالي', 'يبني العضلات', 'يشعرك بالشبع'],
            type: 'food',
            ingredients: [
              'صدر دجاج',
              'زعتر',
              'روزماري',
              'ثوم',
              'زيت زيتون',
              'ليمون',
              'ملح وفلفل'
            ],
            measures: [
              '400 غرام',
              '1 ملعقة',
              '1 ملعقة',
              '2 فص',
              '2 ملاعق',
              '1 حبة',
              'حسب الذوق'
            ],
            instructions:
                '1. نظّف صدر الدجاج وجفّفه.\n2. اخلط الأعشاب مع زيت الزيتون وعصير الليمون.\n3. ادهن الدجاج بالخليط وتبّله.\n4. اتركه يتتبّل 30 دقيقة.\n5. اشوِهِ 6-8 دقائق من كل جانب.',
            area: 'متوسطي',
          ),
          HealthItem(
            id: '3',
            mealDbId: '53049',
            title: 'شوفان بالفواكه والعسل',
            description: 'إفطار مغذٍّ يوفر الطاقة ويخفض الكوليسترول',
            category: 'إفطار',
            imageUrl:
                'https://www.themealdb.com/images/media/meals/1550441882.jpg',
            benefits: ['يخفض الكوليسترول', 'يمد بالطاقة', 'يحسن الهضم'],
            type: 'food',
            ingredients: ['شوفان', 'حليب', 'موز', 'فراولة', 'عسل', 'قرفة'],
            measures: ['1 كوب', '2 كوب', '1 حبة', '5 حبات', '2 ملعقة', 'رشة'],
            instructions:
                '1. اطبخ الشوفان مع الحليب 5 دقائق مع التحريك.\n2. قطّع الموز والفراولة.\n3. ضع الفواكه فوق الشوفان.\n4. أضف العسل والقرفة.',
            area: 'غربي',
          ),
          HealthItem(
            id: '4',
            mealDbId: '52819',
            title: 'سمك السالمون المشوي',
            description: 'غني بأوميغا-3 لصحة القلب والمخ',
            category: 'أسماك',
            imageUrl:
                'https://www.themealdb.com/images/media/meals/ysxwuq1487323065.jpg',
            benefits: ['صحة القلب', 'يخفض الضغط', 'يقوي المخ'],
            type: 'food',
            ingredients: [
              'سمك سالمون',
              'زيت زيتون',
              'ثوم',
              'ليمون',
              'شبت',
              'ملح وفلفل'
            ],
            measures: [
              '500 غرام',
              '2 ملاعق',
              '3 فصوص',
              '1 حبة',
              'حفنة',
              'حسب الذوق'
            ],
            instructions:
                '1. سخّن الفرن 200 درجة.\n2. ضع السمك في الصينية.\n3. أضف الزيت والليمون والثوم والشبت.\n4. اخبز 15-18 دقيقة.',
            area: 'بريطاني',
          ),
          HealthItem(
            id: '5',
            mealDbId: '52869',
            title: 'عدس بالسبانخ',
            description: 'حساء مغذٍّ غني بالحديد والبروتين النباتي',
            category: 'حساء',
            imageUrl:
                'https://www.themealdb.com/images/media/meals/wuxrtu1483564410.jpg',
            benefits: ['يرفع الهيموجلوبين', 'يقوي المناعة', 'ينظم السكر'],
            type: 'food',
            ingredients: [
              'عدس أحمر',
              'سبانخ',
              'بصل',
              'ثوم',
              'كمون',
              'كركم',
              'زيت',
              'ملح'
            ],
            measures: [
              '2 كوب',
              '2 كوب',
              '1 حبة',
              '3 فصوص',
              '1 ملعقة',
              '1/2 ملعقة',
              '2 ملاعق',
              'حسب الذوق'
            ],
            instructions:
                '1. حمّر البصل في الزيت.\n2. أضف الثوم والتوابل.\n3. أضف العدس مع 4 أكواب ماء.\n4. اطبخ 20 دقيقة ثم أضف السبانخ.',
            area: 'عربي',
          ),
        ]
      : [
          HealthItem(
            id: '1',
            mealDbId: '52772',
            title: 'Fresh Garden Salad',
            description:
                'A vitamin-rich salad with fresh vegetables, lemon dressing and olive oil',
            category: 'Salads',
            imageUrl:
                'https://www.themealdb.com/images/media/meals/wruvqv1491515292.jpg',
            benefits: [
              'Lowers cholesterol',
              'Regulates blood sugar',
              'High in fiber'
            ],
            type: 'food',
            ingredients: [
              'Lettuce',
              'Tomatoes',
              'Cucumber',
              'Bell pepper',
              'Olive oil',
              'Lemon',
              'Salt'
            ],
            measures: [
              '1 handful',
              '2 pcs',
              '1 pc',
              '1/2 pc',
              '3 tbsp',
              '1 pc',
              'pinch'
            ],
            instructions:
                '1. Wash all vegetables thoroughly.\n2. Chop lettuce, tomatoes, cucumber and pepper into bite-size pieces.\n3. Place in a large bowl.\n4. Squeeze lemon and drizzle with olive oil and salt.\n5. Toss well and serve cold.',
            area: 'Middle Eastern',
          ),
          HealthItem(
            id: '2',
            mealDbId: '52959',
            title: 'Herb Grilled Chicken Breast',
            description:
                'Low-fat grilled chicken with natural anti-inflammatory herbs and spices',
            category: 'Protein',
            imageUrl:
                'https://www.themealdb.com/images/media/meals/xvquge1483528428.jpg',
            benefits: ['High protein', 'Builds muscle', 'Keeps you full'],
            type: 'food',
            ingredients: [
              'Chicken breast',
              'Thyme',
              'Rosemary',
              'Garlic',
              'Olive oil',
              'Lemon',
              'Salt & pepper'
            ],
            measures: [
              '400 g',
              '1 tsp',
              '1 tsp',
              '2 cloves',
              '2 tbsp',
              '1 pc',
              'to taste'
            ],
            instructions:
                '1. Pat chicken dry.\n2. Mix herbs with olive oil and lemon juice.\n3. Coat chicken with the mixture and season.\n4. Marinate 30 minutes.\n5. Grill 6-8 minutes per side until cooked through.',
            area: 'Mediterranean',
          ),
          HealthItem(
            id: '3',
            mealDbId: '53049',
            title: 'Oatmeal with Fruits & Honey',
            description:
                'A nourishing breakfast that provides energy and lowers cholesterol',
            category: 'Breakfast',
            imageUrl:
                'https://www.themealdb.com/images/media/meals/1550441882.jpg',
            benefits: [
              'Lowers cholesterol',
              'Sustained energy',
              'Improves digestion'
            ],
            type: 'food',
            ingredients: [
              'Oats',
              'Milk',
              'Banana',
              'Strawberries',
              'Honey',
              'Cinnamon'
            ],
            measures: ['1 cup', '2 cups', '1 pc', '5 pcs', '2 tbsp', 'pinch'],
            instructions:
                '1. Cook oats with milk over medium heat for 5 minutes, stirring constantly.\n2. Slice banana and strawberries.\n3. Pour oatmeal into a bowl and top with fruit.\n4. Drizzle with honey and a sprinkle of cinnamon.',
            area: 'Western',
          ),
          HealthItem(
            id: '4',
            mealDbId: '52819',
            title: 'Grilled Salmon',
            description:
                'Rich in omega-3 fatty acids for heart and brain health',
            category: 'Seafood',
            imageUrl:
                'https://www.themealdb.com/images/media/meals/ysxwuq1487323065.jpg',
            benefits: [
              'Heart health',
              'Lowers blood pressure',
              'Boosts brain function'
            ],
            type: 'food',
            ingredients: [
              'Salmon fillet',
              'Olive oil',
              'Garlic',
              'Lemon',
              'Dill',
              'Salt & pepper'
            ],
            measures: [
              '500 g',
              '2 tbsp',
              '3 cloves',
              '1 pc',
              '1 handful',
              'to taste'
            ],
            instructions:
                '1. Preheat oven to 200°C.\n2. Place salmon on a greased baking tray.\n3. Drizzle with olive oil and lemon juice.\n4. Add minced garlic, dill, salt and pepper.\n5. Bake 15-18 minutes until salmon flakes easily.',
            area: 'British',
          ),
          HealthItem(
            id: '5',
            mealDbId: '52869',
            title: 'Lentil & Spinach Soup',
            description:
                'A nutritious soup rich in iron and plant-based protein',
            category: 'Soups',
            imageUrl:
                'https://www.themealdb.com/images/media/meals/wuxrtu1483564410.jpg',
            benefits: [
              'Boosts hemoglobin',
              'Strengthens immunity',
              'Regulates blood sugar'
            ],
            type: 'food',
            ingredients: [
              'Red lentils',
              'Spinach',
              'Onion',
              'Garlic',
              'Cumin',
              'Turmeric',
              'Oil',
              'Salt'
            ],
            measures: [
              '2 cups',
              '2 cups',
              '1 pc',
              '3 cloves',
              '1 tsp',
              '1/2 tsp',
              '2 tbsp',
              'to taste'
            ],
            instructions:
                '1. Sauté chopped onion in oil until soft.\n2. Add garlic, cumin and turmeric, stir 1 minute.\n3. Add lentils and 4 cups water, bring to a boil.\n4. Cook 20 minutes then add spinach and season with salt.',
            area: 'Arabic',
          ),
        ];

  // ── Fallback exercises ─────────────────────────────────────────────────────
  static List<HealthItem> _fallbackExercises(bool ar) => ar
      ? [
          HealthItem(
            id: 'e1',
            title: 'المشي السريع',
            description: '30 دقيقة من المشي السريع يومياً يحرق 150-200 سعرة',
            category: 'كارديو',
            imageUrl: '',
            benefits: ['يخفض الضغط', 'يحسن القلب', 'يحرق الدهون'],
            type: 'exercise',
            instructions:
                'ابدأ بالمشي ببطء 5 دقائق للإحماء.\nزِد السرعة تدريجياً.\nحافظ على السرعة 20 دقيقة.\nاختم بمشي بطيء 5 دقائق.\nكرّر 5 مرات أسبوعياً.',
          ),
          HealthItem(
            id: 'e2',
            title: 'تمارين الضغط',
            description: '3 مجموعات × 15 تكرار لتقوية عضلات الجسم العلوي',
            category: 'قوة',
            imageUrl: '',
            benefits: ['يبني العضلات', 'يحرق الدهون', 'يقوي العظام'],
            type: 'exercise',
            instructions:
                'استلقِ على بطنك واسند يديك بعرض الكتفين.\nارفع جسمك حتى تستقيم ذراعاك.\nانزل ببطء.\nكرّر 15 مرة في 3 مجموعات.',
          ),
          HealthItem(
            id: 'e3',
            title: 'اليوغا والتأمل',
            description: '20 دقيقة يومياً لتقليل التوتر وتحسين المرونة',
            category: 'استرخاء',
            imageUrl: '',
            benefits: ['يخفض التوتر', 'يحسن النوم', 'ينظم ضغط الدم'],
            type: 'exercise',
            instructions:
                'ابدأ بالجلوس بشكل مريح وأغمض عينيك.\nتنفّس بعمق 5 مرات.\nافعل وضعية القط-البقرة 10 تكرارات.\nافعل وضعية الطفل دقيقتين.\nأنهِ بالتمدد.',
          ),
          HealthItem(
            id: 'e4',
            title: 'تمارين القرفصاء',
            description: '4 مجموعات × 20 تكرار لتقوية عضلات الساق',
            category: 'قوة',
            imageUrl: '',
            benefits: ['يقوي الساقين', 'يحرق الدهون', 'يحسن التوازن'],
            type: 'exercise',
            instructions:
                'قف بفرد قدميك بعرض الكتفين.\nانزل حتى تتوازى فخذاك مع الأرض.\nارجع للوقوف.\nكرّر 20 مرة في 4 مجموعات.',
          ),
          HealthItem(
            id: 'e5',
            title: 'السباحة',
            description: '30 دقيقة من السباحة تحرق 250-400 سعرة',
            category: 'كارديو',
            imageUrl: '',
            benefits: ['كارديو ممتاز', 'لا يضر المفاصل', 'يقوي كل العضلات'],
            type: 'exercise',
            instructions:
                'ابدأ بالسباحة البطيئة 5 دقائق للإحماء.\nسبح 25 متر ثم استرح 30 ثانية.\nكرّر 10 جولات.\nاختم بتمديدات خفيفة.',
          ),
        ]
      : [
          HealthItem(
            id: 'e1',
            title: 'Brisk Walking',
            description:
                '30 minutes of brisk walking daily burns 150–200 calories',
            category: 'Cardio',
            imageUrl: '',
            benefits: [
              'Lowers blood pressure',
              'Improves heart health',
              'Burns fat'
            ],
            type: 'exercise',
            instructions:
                'Start with a slow 5-minute warm-up walk.\nGradually increase speed until you feel slightly breathless.\nMaintain that pace for 20 minutes.\nCool down with a slow walk for 5 minutes.\nRepeat 5 times a week for best results.',
          ),
          HealthItem(
            id: 'e2',
            title: 'Push-Ups',
            description: '3 sets × 15 reps to strengthen upper body muscles',
            category: 'Strength',
            imageUrl: '',
            benefits: ['Builds muscle', 'Burns fat', 'Strengthens bones'],
            type: 'exercise',
            instructions:
                'Lie face down with hands shoulder-width apart.\nPush your body up until arms are straight.\nLower slowly until chest nearly touches the floor.\nRepeat 15 times for 3 sets with 1-minute rest between sets.\nIf too hard, start with knee push-ups.',
          ),
          HealthItem(
            id: 'e3',
            title: 'Yoga & Meditation',
            description:
                '20 minutes daily to reduce stress and improve flexibility',
            category: 'Relaxation',
            imageUrl: '',
            benefits: [
              'Reduces stress',
              'Improves sleep',
              'Regulates blood pressure'
            ],
            type: 'exercise',
            instructions:
                'Sit comfortably and close your eyes.\nTake 5 deep breaths — inhale 4 seconds, exhale 6 seconds.\nMove into cat-cow pose for 10 reps to stretch the spine.\nHold child\'s pose for 2 minutes to relax.\nFinish with forward and side stretches.',
          ),
          HealthItem(
            id: 'e4',
            title: 'Squats',
            description: '4 sets × 20 reps to strengthen leg and glute muscles',
            category: 'Strength',
            imageUrl: '',
            benefits: ['Strengthens legs', 'Burns fat', 'Improves balance'],
            type: 'exercise',
            instructions:
                'Stand with feet shoulder-width apart, toes slightly out.\nLower slowly as if sitting on a chair until thighs are parallel to the floor.\nPush through your heels to stand back up.\nRepeat 20 times for 4 sets with 90-second rest.\nKeep knees aligned with toes throughout.',
          ),
          HealthItem(
            id: 'e5',
            title: 'Swimming',
            description: '30 minutes of swimming burns 250–400 calories',
            category: 'Cardio',
            imageUrl: '',
            benefits: [
              'Excellent cardio',
              'Joint-friendly',
              'Full body workout'
            ],
            type: 'exercise',
            instructions:
                'Warm up with slow swimming for 5 minutes.\nSwim 25 m at moderate pace then rest 30 seconds.\nRepeat 10 laps for beginners, increase gradually.\nTry freestyle or breaststroke.\nFinish with light stretches outside the pool.',
          ),
        ];
}
