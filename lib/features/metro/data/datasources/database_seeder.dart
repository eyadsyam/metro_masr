import 'metro_database.dart';
import '../models/station_entity.dart';
import '../models/line_entity.dart';
import '../models/station_connection_entity.dart';

class DatabaseSeeder {
  final AppDatabase database;

  DatabaseSeeder(this.database);

  Future<void> seed() async {
    final count = await database.stationDao.getStationsCount();
    if (count != null && count > 0) {
      return; // Already seeded
    }

    // 1. Insert Lines
    final lines = [
      LineEntity(
        id: 1,
        nameAr: 'الخط الأول',
        nameEn: 'Line 1 (Blue)',
        colorHex: '#0000FF',
      ),
      LineEntity(
        id: 2,
        nameAr: 'الخط الثاني',
        nameEn: 'Line 2 (Red)',
        colorHex: '#FF0000',
      ),
      LineEntity(
        id: 3,
        nameAr: 'الخط الثالث',
        nameEn: 'Line 3 (Green)',
        colorHex: '#00FF00',
      ),
    ];
    await database.stationDao.insertLines(lines);

    // 2. Insert Stations - COMPLETE LIST FROM OFFICIAL MAP
    final rawStations = [
      // === LINE 1 (BLUE): Helwan → New El Marg (35 stations) ===
      {
        'id': 101,
        'nameEn': 'Helwan',
        'nameAr': 'حلوان',
        'lineId': 1,
        'lat': 29.8494,
        'lng': 31.3344,
      },
      {
        'id': 102,
        'nameEn': 'Ain Helwan',
        'nameAr': 'عين حلوان',
        'lineId': 1,
        'lat': 29.8627,
        'lng': 31.3248,
      },
      {
        'id': 103,
        'nameEn': 'Helwan University',
        'nameAr': 'جامعة حلوان',
        'lineId': 1,
        'lat': 29.8695,
        'lng': 31.3201,
      },
      {
        'id': 104,
        'nameEn': 'Wadi Hof',
        'nameAr': 'وادي حوف',
        'lineId': 1,
        'lat': 29.8792,
        'lng': 31.3139,
      },
      {
        'id': 105,
        'nameEn': 'Hadayek Helwan',
        'nameAr': 'حدائق حلوان',
        'lineId': 1,
        'lat': 29.8970,
        'lng': 31.3040,
      },
      {
        'id': 106,
        'nameEn': 'El-Maasara',
        'nameAr': 'المعصرة',
        'lineId': 1,
        'lat': 29.9060,
        'lng': 31.2995,
      },
      {
        'id': 107,
        'nameEn': 'Tora El-Asmant',
        'nameAr': 'طرة الأسمنت',
        'lineId': 1,
        'lat': 29.9258,
        'lng': 31.2878,
      },
      {
        'id': 108,
        'nameEn': 'Kozzika',
        'nameAr': 'كوتسيكا',
        'lineId': 1,
        'lat': 29.9363,
        'lng': 31.2818,
      },
      {
        'id': 109,
        'nameEn': 'Tora El-Balad',
        'nameAr': 'طرة البلد',
        'lineId': 1,
        'lat': 29.9467,
        'lng': 31.2729,
      },
      {
        'id': 110,
        'nameEn': 'Sakanat El-Maadi',
        'nameAr': 'ثكنات المعادي',
        'lineId': 1,
        'lat': 29.9537,
        'lng': 31.2634,
      },
      {
        'id': 111,
        'nameEn': 'Maadi',
        'nameAr': 'المعادي',
        'lineId': 1,
        'lat': 29.9604,
        'lng': 31.2577,
      },
      {
        'id': 112,
        'nameEn': 'Hadayek El-Maadi',
        'nameAr': 'حدائق المعادي',
        'lineId': 1,
        'lat': 29.9703,
        'lng': 31.2506,
      },
      {
        'id': 113,
        'nameEn': 'Dar El-Salam',
        'nameAr': 'دار السلام',
        'lineId': 1,
        'lat': 29.9819,
        'lng': 31.2422,
      },
      {
        'id': 114,
        'nameEn': 'El-Zahraa',
        'nameAr': 'الزهراء',
        'lineId': 1,
        'lat': 29.9955,
        'lng': 31.2314,
      },
      {
        'id': 115,
        'nameEn': 'Mar Girgis',
        'nameAr': 'مار جرجس',
        'lineId': 1,
        'lat': 30.0061,
        'lng': 31.2296,
      },
      {
        'id': 116,
        'nameEn': 'El-Malek El-Saleh',
        'nameAr': 'الملك الصالح',
        'lineId': 1,
        'lat': 30.0174,
        'lng': 31.2313,
      },
      {
        'id': 117,
        'nameEn': 'Al-Sayeda Zeinab',
        'nameAr': 'السيدة زينب',
        'lineId': 1,
        'lat': 30.0293,
        'lng': 31.2355,
      },
      {
        'id': 118,
        'nameEn': 'Saad Zaghloul',
        'nameAr': 'سعد زغلول',
        'landmarkEn': 'Downtown',
        'landmarkAr': 'وسط البلد',
        'lineId': 1,
        'lat': 30.0370,
        'lng': 31.2384,
      },
      {
        'id': 119,
        'nameEn': 'Sadat',
        'nameAr': 'السادات',
        'landmarkEn': 'Tahrir',
        'landmarkAr': 'التحرير',
        'lineId': 1,
        'isInterchange': true,
        'lat': 30.0444,
        'lng': 31.2357,
      },
      {
        'id': 120,
        'nameEn': 'Nasser',
        'nameAr': 'جمال عبد الناصر',
        'lineId': 1,
        'isInterchange': true,
        'lat': 30.0531,
        'lng': 31.2387,
      },
      {
        'id': 121,
        'nameEn': 'Orabi',
        'nameAr': 'عرابي',
        'lineId': 1,
        'lat': 30.0565,
        'lng': 31.2420,
      },
      {
        'id': 122,
        'nameEn': 'Al-Shohada',
        'nameAr': 'الشهداء',
        'landmarkEn': 'Ramses',
        'landmarkAr': 'رمسيس',
        'lineId': 1,
        'isInterchange': true,
        'lat': 30.0611,
        'lng': 31.2461,
      },
      {
        'id': 123,
        'nameEn': 'Ghamra',
        'nameAr': 'غمرة',
        'lineId': 1,
        'lat': 30.0687,
        'lng': 31.2646,
      },
      {
        'id': 124,
        'nameEn': 'El-Demerdash',
        'nameAr': 'الدمرداش',
        'lineId': 1,
        'lat': 30.0773,
        'lng': 31.2777,
      },
      {
        'id': 125,
        'nameEn': 'Manshiet El-Sadr',
        'nameAr': 'منشية الصدر',
        'lineId': 1,
        'lat': 30.0821,
        'lng': 31.2874,
      },
      {
        'id': 126,
        'nameEn': 'Kobri El-Qobba',
        'nameAr': 'كوبري القبة',
        'lineId': 1,
        'lat': 30.0872,
        'lng': 31.2940,
      },
      {
        'id': 127,
        'nameEn': 'Hammamat El-Qobba',
        'nameAr': 'حمامات القبة',
        'lineId': 1,
        'lat': 30.0918,
        'lng': 31.2989,
      },
      {
        'id': 128,
        'nameEn': 'Saray El-Qobba',
        'nameAr': 'سراي القبة',
        'lineId': 1,
        'lat': 30.0976,
        'lng': 31.3045,
      },
      {
        'id': 129,
        'nameEn': 'Hadayek El-Zaitoun',
        'nameAr': 'حدائق الزيتون',
        'lineId': 1,
        'lat': 30.1058,
        'lng': 31.3104,
      },
      {
        'id': 130,
        'nameEn': 'Helmeyet El-Zaitoun',
        'nameAr': 'حلمية الزيتون',
        'lineId': 1,
        'lat': 30.1133,
        'lng': 31.3140,
      },
      {
        'id': 131,
        'nameEn': 'El-Matareya',
        'nameAr': 'المطرية',
        'lineId': 1,
        'lat': 30.1213,
        'lng': 31.3138,
      },
      {
        'id': 132,
        'nameEn': 'Ain Shams',
        'nameAr': 'عين شمس',
        'lineId': 1,
        'lat': 30.1311,
        'lng': 31.3189,
      },
      {
        'id': 133,
        'nameEn': 'Ezbet El-Nakhl',
        'nameAr': 'عزبة النخل',
        'lineId': 1,
        'lat': 30.1391,
        'lng': 31.3244,
      },
      {
        'id': 134,
        'nameEn': 'El-Marg',
        'nameAr': 'المرج',
        'lineId': 1,
        'lat': 30.1521,
        'lng': 31.3359,
      },
      {
        'id': 135,
        'nameEn': 'New El-Marg',
        'nameAr': 'المرج الجديدة',
        'lineId': 1,
        'lat': 30.1636,
        'lng': 31.3385,
      },

      // === LINE 2 (RED): Shobra El Kheima → El Mounib (20 stations) ===
      {
        'id': 201,
        'nameEn': 'Shobra El Kheima',
        'nameAr': 'شبرا الخيمة',
        'lineId': 2,
        'lat': 30.1222,
        'lng': 31.2444,
      },
      {
        'id': 202,
        'nameEn': 'Koleyet El-Zeraa',
        'nameAr': 'كلية الزراعة',
        'lineId': 2,
        'lat': 30.1137,
        'lng': 31.2487,
      },
      {
        'id': 203,
        'nameEn': 'El-Mezallat',
        'nameAr': 'المظلات',
        'lineId': 2,
        'lat': 30.1042,
        'lng': 31.2456,
      },
      {
        'id': 204,
        'nameEn': 'Khalafawy',
        'nameAr': 'الخلفاوي',
        'lineId': 2,
        'lat': 30.0978,
        'lng': 31.2454,
      },
      {
        'id': 205,
        'nameEn': 'St. Teresa',
        'nameAr': 'سانت تريزا',
        'lineId': 2,
        'lat': 30.0880,
        'lng': 31.2454,
      },
      {
        'id': 206,
        'nameEn': 'Rod El-Farag',
        'nameAr': 'روض الفرج',
        'lineId': 2,
        'lat': 30.0806,
        'lng': 31.2454,
      },
      {
        'id': 207,
        'nameEn': 'Masarra',
        'nameAr': 'مسرة',
        'lineId': 2,
        'lat': 30.0706,
        'lng': 31.2454,
      },
      {
        'id': 208,
        'nameEn': 'Al-Shohada',
        'nameAr': 'الشهداء',
        'landmarkEn': 'Ramses',
        'landmarkAr': 'رمسيس',
        'lineId': 2,
        'isInterchange': true,
        'lat': 30.0611,
        'lng': 31.2461,
      },
      {
        'id': 209,
        'nameEn': 'Attaba',
        'nameAr': 'العتبة',
        'lineId': 2,
        'isInterchange': true,
        'lat': 30.0527,
        'lng': 31.2467,
      },
      {
        'id': 210,
        'nameEn': 'Mohamed Naguib',
        'nameAr': 'محمد نجيب',
        'lineId': 2,
        'lat': 30.0454,
        'lng': 31.2441,
      },
      {
        'id': 211,
        'nameEn': 'Sadat',
        'nameAr': 'السادات',
        'landmarkEn': 'Tahrir',
        'landmarkAr': 'التحرير',
        'lineId': 2,
        'isInterchange': true,
        'lat': 30.0444,
        'lng': 31.2357,
      },
      {
        'id': 212,
        'nameEn': 'Opera',
        'nameAr': 'الأوبرا',
        'lineId': 2,
        'lat': 30.0419,
        'lng': 31.2250,
      },
      {
        'id': 213,
        'nameEn': 'Dokki',
        'nameAr': 'الدقي',
        'lineId': 2,
        'lat': 30.0385,
        'lng': 31.2122,
      },
      {
        'id': 214,
        'nameEn': 'El-Bohoth',
        'nameAr': 'البحوث',
        'lineId': 2,
        'lat': 30.0357,
        'lng': 31.2006,
      },
      {
        'id': 215,
        'nameEn': 'Cairo University',
        'nameAr': 'جامعة القاهرة',
        'lineId': 2,
        'isInterchange': true,
        'lat': 30.0260,
        'lng': 31.2012,
      },
      {
        'id': 216,
        'nameEn': 'Faisal',
        'nameAr': 'فيصل',
        'lineId': 2,
        'lat': 30.0172,
        'lng': 31.2038,
      },
      {
        'id': 217,
        'nameEn': 'Giza',
        'nameAr': 'الجيزة',
        'lineId': 2,
        'lat': 30.0107,
        'lng': 31.2069,
      },
      {
        'id': 218,
        'nameEn': 'Omm El-Masryeen',
        'nameAr': 'أم المصريين',
        'lineId': 2,
        'lat': 30.0056,
        'lng': 31.2085,
      },
      {
        'id': 219,
        'nameEn': 'Sakiat Mekky',
        'nameAr': 'ساقية مكي',
        'lineId': 2,
        'lat': 29.9956,
        'lng': 31.2119,
      },
      {
        'id': 220,
        'nameEn': 'El-Mounib',
        'nameAr': 'المنيب',
        'lineId': 2,
        'lat': 29.9816,
        'lng': 31.2124,
      },

      // === LINE 3 (GREEN): Adly Mansour → Rod El Farag Corridor / Cairo University (34 stations) ===
      {
        'id': 301,
        'nameEn': 'Adly Mansour',
        'nameAr': 'عدلي منصور',
        'lineId': 3,
        'lat': 30.1478,
        'lng': 31.4214,
      },
      {
        'id': 302,
        'nameEn': 'El Haykestep',
        'nameAr': 'الهايكستب',
        'lineId': 3,
        'lat': 30.1441,
        'lng': 31.4051,
      },
      {
        'id': 303,
        'nameEn': 'Omar Ibn El-Khattab',
        'nameAr': 'عمر بن الخطاب',
        'lineId': 3,
        'lat': 30.1406,
        'lng': 31.3940,
      },
      {
        'id': 304,
        'nameEn': 'Qobaa',
        'nameAr': 'قباء',
        'lineId': 3,
        'lat': 30.1350,
        'lng': 31.3832,
      },
      {
        'id': 305,
        'nameEn': 'Hesham Barakat',
        'nameAr': 'هشام بركات',
        'lineId': 3,
        'lat': 30.1309,
        'lng': 31.3730,
      },
      {
        'id': 306,
        'nameEn': 'El-Nozha',
        'nameAr': 'النزهة',
        'lineId': 3,
        'lat': 30.1279,
        'lng': 31.3601,
      },
      {
        'id': 307,
        'nameEn': 'Nadi El-Shams',
        'nameAr': 'نادي الشمس',
        'lineId': 3,
        'lat': 30.1213,
        'lng': 31.3455,
      },
      {
        'id': 308,
        'nameEn': 'Alf Maskan',
        'nameAr': 'ألف مسكن',
        'lineId': 3,
        'lat': 30.1190,
        'lng': 31.3400,
      },
      {
        'id': 309,
        'nameEn': 'Heliopolis Square',
        'nameAr': 'ميدان هليوبوليس',
        'lineId': 3,
        'lat': 30.1087,
        'lng': 31.3381,
      },
      {
        'id': 310,
        'nameEn': 'Haroun',
        'nameAr': 'هارون',
        'lineId': 3,
        'lat': 30.1015,
        'lng': 31.3329,
      },
      {
        'id': 311,
        'nameEn': 'Al-Ahram',
        'nameAr': 'الأهرام',
        'lineId': 3,
        'lat': 30.0911,
        'lng': 31.3261,
      },
      {
        'id': 312,
        'nameEn': 'Koleyet El-Banat',
        'nameAr': 'كلية البنات',
        'lineId': 3,
        'lat': 30.0840,
        'lng': 31.3287,
      },
      {
        'id': 313,
        'nameEn': 'Stadium',
        'nameAr': 'الاستاد',
        'lineId': 3,
        'lat': 30.0730,
        'lng': 31.3173,
      },
      {
        'id': 314,
        'nameEn': 'Fair Zone',
        'nameAr': 'أرض المعارض',
        'lineId': 3,
        'lat': 30.0731,
        'lng': 31.3012,
      },
      {
        'id': 315,
        'nameEn': 'Abbassia',
        'nameAr': 'العباسية',
        'lineId': 3,
        'lat': 30.0720,
        'lng': 31.2832,
      },
      {
        'id': 316,
        'nameEn': 'Abdou Pasha',
        'nameAr': 'عبده باشا',
        'lineId': 3,
        'lat': 30.0654,
        'lng': 31.2750,
      },
      {
        'id': 317,
        'nameEn': 'El-Geish',
        'nameAr': 'الجيش',
        'lineId': 3,
        'lat': 30.0615,
        'lng': 31.2671,
      },
      {
        'id': 318,
        'nameEn': 'Bab El-Shaaria',
        'nameAr': 'باب الشعرية',
        'lineId': 3,
        'lat': 30.0540,
        'lng': 31.2562,
      },
      {
        'id': 319,
        'nameEn': 'Attaba',
        'nameAr': 'العتبة',
        'lineId': 3,
        'isInterchange': true,
        'lat': 30.0527,
        'lng': 31.2467,
      },
      {
        'id': 320,
        'nameEn': 'Nasser',
        'nameAr': 'جمال عبد الناصر',
        'lineId': 3,
        'isInterchange': true,
        'lat': 30.0531,
        'lng': 31.2387,
      },
      {
        'id': 321,
        'nameEn': 'Maspero',
        'nameAr': 'ماسبيرو',
        'lineId': 3,
        'lat': 30.0556,
        'lng': 31.2324,
      },
      {
        'id': 322,
        'nameEn': 'Safaa Hegazy',
        'nameAr': 'صفاء حجازي',
        'lineId': 3,
        'lat': 30.0620,
        'lng': 31.2225,
      },
      {
        'id': 323,
        'nameEn': 'Kit Kat',
        'nameAr': 'الكيت كات',
        'lineId': 3,
        'lat': 30.0663,
        'lng': 31.2130,
      },

      // Branch A: Kit Kat → Rod El Farag Corridor
      {
        'id': 324,
        'nameEn': 'Sudan',
        'nameAr': 'السودان',
        'lineId': 3,
        'lat': 30.0698,
        'lng': 31.2048,
      },
      {
        'id': 325,
        'nameEn': 'Imbaba',
        'nameAr': 'إمبابة',
        'lineId': 3,
        'lat': 30.0760,
        'lng': 31.2076,
      },
      {
        'id': 326,
        'nameEn': 'El-Bohy',
        'nameAr': 'البوهي',
        'lineId': 3,
        'lat': 30.0821,
        'lng': 31.2110,
      },
      {
        'id': 327,
        'nameEn': 'El-Qawmia',
        'nameAr': 'القومية العربية',
        'lineId': 3,
        'lat': 30.0897,
        'lng': 31.2089,
      },
      {
        'id': 328,
        'nameEn': 'Ring Road',
        'nameAr': 'الطريق الدائري',
        'lineId': 3,
        'lat': 30.0972,
        'lng': 31.2089,
      },
      {
        'id': 329,
        'nameEn': 'Rod El-Farag Corridor',
        'nameAr': 'محور روض الفرج',
        'lineId': 3,
        'lat': 30.1063,
        'lng': 31.2089,
      },

      // Branch B: Kit Kat → Cairo University
      {
        'id': 330,
        'nameEn': 'Tawfikeya',
        'nameAr': 'التوفيقية',
        'lineId': 3,
        'lat': 30.0606,
        'lng': 31.2080,
      },
      {
        'id': 331,
        'nameEn': 'Wadi El-Nil',
        'nameAr': 'وادي النيل',
        'lineId': 3,
        'lat': 30.0548,
        'lng': 31.2080,
      },
      {
        'id': 332,
        'nameEn': 'Gamaat El-Dowal',
        'nameAr': 'جامعة الدول العربية',
        'lineId': 3,
        'lat': 30.0465,
        'lng': 31.2080,
      },
      {
        'id': 333,
        'nameEn': 'Boulaq El-Dakrour',
        'nameAr': 'بولاق الدكرور',
        'lineId': 3,
        'lat': 30.0380,
        'lng': 31.2080,
      },
      {
        'id': 334,
        'nameEn': 'Cairo University',
        'nameAr': 'جامعة القاهرة',
        'lineId': 3,
        'isInterchange': true,
        'lat': 30.0260,
        'lng': 31.2012,
      },
    ];

    List<StationEntity> stations = rawStations.map((map) {
      return StationEntity(
        id: map['id'] as int,
        nameEn: map['nameEn'] as String,
        nameAr: map['nameAr'] as String,
        landmarkEn: map['landmarkEn'] as String?,
        landmarkAr: map['landmarkAr'] as String?,
        lineId: map['lineId'] as int,
        isInterchange: (map['isInterchange'] ?? false) as bool,
        latitude: (map['lat'] as double),
        longitude: (map['lng'] as double),
      );
    }).toList();

    await database.stationDao.insertStations(stations);

    // 3. Insert Connections (Sequential + Interchanges)
    final connections = <StationConnectionEntity>[];

    void connect(int u, int v, int cost) {
      connections.add(
        StationConnectionEntity(fromStationId: u, toStationId: v, cost: cost),
      );
      connections.add(
        StationConnectionEntity(fromStationId: v, toStationId: u, cost: cost),
      );
    }

    // LINE 1: Sequential connections (101-135)
    for (int i = 101; i < 135; i++) {
      connect(i, i + 1, 1);
    }

    // LINE 2: Sequential connections (201-220)
    for (int i = 201; i < 220; i++) {
      connect(i, i + 1, 1);
    }

    // LINE 3: Main spine (301-323)
    for (int i = 301; i < 323; i++) {
      connect(i, i + 1, 1);
    }

    // LINE 3 Branch A: Kit Kat (323) → Rod El Farag Corridor (324-329)
    for (int i = 323; i < 329; i++) {
      connect(i, i + 1, 1);
    }

    // LINE 3 Branch B: Kit Kat (323) → Cairo University (330-334)
    connect(323, 330, 1); // Kit Kat to Tawfikeya
    for (int i = 330; i < 334; i++) {
      connect(i, i + 1, 1);
    }

    // INTERCHANGES (Transfer cost = 3 minutes)
    connect(119, 211, 3); // Sadat L1 ↔ L2
    connect(120, 320, 3); // Nasser L1 ↔ L3
    connect(122, 208, 3); // Al-Shohada L1 ↔ L2
    connect(209, 319, 3); // Attaba L2 ↔ L3
    connect(215, 334, 3); // Cairo University L2 ↔ L3

    await database.stationDao.insertConnections(connections);
  }
}
